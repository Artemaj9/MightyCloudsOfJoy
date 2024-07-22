//#include <metal_stdlib>
//using namespace metal;
//
//struct VertexOut {
//    float4 position [[position]];
//    float2 texCoord;
//};
//
//vertex VertexOut vertexShader(uint vertexID [[vertex_id]]) {
//    float4 positions[4] = {
//        float4(-1.0, -1.0, 0.0, 1.0),
//        float4(1.0, -1.0, 0.0, 1.0),
//        float4(-1.0, 1.0, 0.0, 1.0),
//        float4(1.0, 1.0, 0.0, 1.0)
//    };
//    
//    float2 texCoords[4] = {
//        float2(0.0, 0.0),
//        float2(1.0, 0.0),
//        float2(0.0, 1.0),
//        float2(1.0, 1.0)
//    };
//    
//    VertexOut out;
//    out.position = positions[vertexID];
//    out.texCoord = texCoords[vertexID];
//    return out;
//}
//
//fragment float4 snowShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]]) {
//    float4 color = float4(0.0, 0.0, 0.0, 1.0);
//    float intensity = 0.0;
//    
//    for (int i = 0; i < 10; i++) {
//        float2 position = float2(sin(time + float(i) * 3.0) * 0.5 + 0.5, fmod(time + float(i) * 0.2, 1.0));
//        float dist = distance(in.texCoord, position);
//        float size = 0.02 + 0.01 * sin(time + float(i));
//        intensity += smoothstep(size, size + 0.01, 1.0 - dist);
//    }
//    
//    color.rgb += intensity * float3(1.0, 1.0, 1.0);
//    return color;
//}
//
//fragment float4 rainShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]]) {
//    float4 color = float4(0.0, 0.0, 0.0, 1.0);
//    float intensity = 0.0;
//    
//    for (int i = 0; i < 20; i++) {
//        float2 position = float2(fmod(time + float(i) * 0.1, 1.0), sin(time + float(i) * 5.0) * 0.5 + 0.5);
//        float dist = distance(in.texCoord, position);
//        float streak = smoothstep(0.02, 0.03, dist) - smoothstep(0.03, 0.04, dist);
//        intensity += streak * (1.0 - dist);
//    }
//    
//    color.rgb += intensity * float3(0.5, 0.5, 1.0);
//    return color;
//}
//

// good
#include <metal_stdlib>
using namespace metal;

constant int NumDrops = 150; // Number of raindrops
constant float WindVariability = 0.02; // Variability in wind effect// Size of each raindrop
float rnd(float2 p) {
    return fract(sin(dot(p, float2(12.1234, 72.8392))) * 45123.2);
}

float hash11(float p) {
    float2 p2 = fract(float2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + float2(21.5351, 14.3137));
    return fract(p2.x * p2.y * 95.4337) * 0.5 + 0.5;
}

float rnd(float w) {
    return fract(sin(w) * 1000.0);
}

float regShape(float2 p, int N) {
    float a = atan2(p.y, p.x) + 0.2;
    float b = 6.28319 / float(N);
    return smoothstep(0.5, 0.51, cos(floor(0.5 + a / b) * b - a) * length(p));
}

float3 circle(float2 p, float size, float decay, float3 color, float3 color2, float dist, float2 mouse) {
    float l = length(p + mouse * (dist * 4.0)) + size / 2.0;
    float l2 = length(p + mouse * (dist * 4.0)) + size / 3.0;

    float c = max(0.01 - pow(length(p + mouse * dist), size * 1.4), 0.0) * 50.0;
    float c1 = max(0.001 - pow(l - 0.3, 1.0 / 40.0) + sin(l * 30.0), 0.0) * 3.0;
    float c2 = max(0.04 / pow(length(p - mouse * dist / 2.0 + 0.09) * 1.0, 1.0), 0.0) / 20.0;
    float s = max(0.01 - pow(regShape(p * 5.0 + mouse * dist * 5.0 + 0.9, 6), 1.0), 0.0) * 5.0;

    color = 0.5 + 0.5 * sin(color);
    color = cos(float3(0.44, 0.24, 0.2) * 8.0 + dist * 4.0) * 0.5 + 0.5;
    float3 f = c * color;
    f += c1 * color;
    f += c2 * color;
    f += s * color;
    return f - 0.01;
}

float sun(float2 p, float2 mouse) {
    float2 sunp = p + mouse;
    return 1.0 - length(sunp) * 8.0;
}

// Vertex Shader
struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]], constant float2 *vertices [[buffer(0)]]) {
    VertexOut out;
    out.position = float4(vertices[vertexID] * 2.0 - 1.0, 0.0, 1.0);
    out.texCoord = vertices[vertexID];
    return out;
}

 //Sun Shader
fragment float4 sunShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]], constant float4 &iMagic [[buffer(2)]]) {
    float2 uv = in.texCoord - 0.5;
    uv.x *= iResolution.x / iResolution.y;

    float2 mm = iMagic.xy / iResolution.xy - 0.5;
    mm.x *= iResolution.x / iResolution.y;

    if (iMagic.z < 1.0) {
        mm = float2(sin(time / 6.0) / 1.0, cos(time / 8.0) / 2.0) / 2.0;
    }

    float3 circColor = float3(0.9, 0.2, 0.1);
    float3 circColor2 = float3(0.3, 0.1, 0.9);

    float3 color = mix(float3(0.3, 0.2, 0.02) / 0.9, float3(0.2, 0.5, 0.8), uv.y) * 3.0 - 0.52 * sin(time);

    for (float i = 0.0; i < 10.0; i++) {
        color += circle(uv, pow(rnd(i * 2000.0) * 1.8, 2.0) + 1.41, 0.0, circColor + i, circColor2 + i, rnd(i * 20.0) * 3.0 + 0.2 - 0.5, mm);
    }

    float a = atan2(uv.y - mm.y, uv.x - mm.x);
    float l = max(1.0 - length(uv - mm) - 0.84, 0.0);
    float bright = 0.1;

    color += max(0.1 / pow(length(uv - mm) * 5.0, 5.0), 0.0) * abs(sin(a * 5.0 + cos(a * 9.0))) / 20.0;
    color += max(0.1 / pow(length(uv - mm) * 10.0, 1.0 / 20.0), 0.0) + abs(sin(a * 3.0 + cos(a * 9.0))) / 8.0 * (abs(sin(a * 9.0))) / 1.0;
    color += (max(bright / pow(length(uv - mm) * 4.0, 1.0 / 2.0), 0.0) * 4.0) * float3(0.2, 0.21, 0.3) * 4.0;
    color *= exp(1.0 - length(uv - mm)) / 5.0;

    return float4(color, 1.0);
}
///

// Fragment shader for rain
fragment float4 rainShader5(VertexOut in [[stage_in]], constant float &iTime [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float rain_speed = 0.5;
    float rain_streak = 0.4;
    float2 uv = in.texCoord;
    float2 i = in.position.xy;

    // Calculate the adjusted uv coordinates
    uv = 1.0 + i / iResolution;

    // Use hash function to determine rain pattern
    float hashValue = hash11(floor((-uv.y * 50.0) + (uv.x * 150.0)));
    float c = 1.0 - fract((-uv.y * 0.5 + iTime * rain_speed + 0.1) * hashValue * 0.5) * rain_streak;
    float3 droplet = float3(0.4, 0.2, 0.5) * 0.5;

    // Mix the background and raindrop color based on calculated intensity
    float3 color = mix(float3(0.4, 0.4, 0), droplet, c * 0.9);
    return float4(color, 1.0);
}

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

fragment float4 rainShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord;  // Normalized coordinates
    float4 color = float4(0.0, 0.0, 0.0, 1.0);  // Initial color

    float rain_speed = 0.3;  // Control the speed of falling rain
    float rainFactor = hash(uv.x * 100.0);  // Pseudo-random factor based on x coordinate

    // Adjust vertical position by time to simulate falling
    float rainMotion = fract(-uv.y - (rainFactor + time * rain_speed));

    // Simple threshold to create lines
    if (rainMotion < 0.02) {
        color += float4(0.5, 0.7, 0.8, 1.0) * (0.02 - rainMotion) * 50.0;  // Fading effect
    }
    color.rgb += float3(0.1, 0.1, 0.2);  // Constant color addition for aesthetic reasons

    return color;
}

// Fragment shader for snowfall using rounded snowflakes
// Fragment shader for simple snowfall using the given template

// MARK: Snow

fragment float4 snowShader19(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord;  // Normalized coordinates
    float4 color = float4(0.5, 0.5, 0.8, 1.0);  // Initial darker night sky color

    float snow_speed = 0.05;  // Slower falling speed for snow
    float snowFactor = hash(uv.x * 100.0);  // Pseudo-random factor based on x coordinate

    // Adjust vertical position by time to simulate gentle falling
    float snowMotion = fract(-uv.y - (snowFactor + time * snow_speed));

    // Create round, soft snowflakes instead of lines
    if (snowMotion < 0.001) {  // Larger threshold for softer appearance
        float flakeIntensity = (0.03 - snowMotion) * (10.0 / 0.03);  // Normalize intensity
        color += float4(0.9, 0.9, 1.0, 1.0) * flakeIntensity;  // Soft, bright snowflakes
    }

    return color;
}
fragment float4 snowShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord;  // Normalized coordinates
    float4 color = float4(0.4, 0.6, 0.8, 1.0);  // Dark night sky as initial color

    float star_speed = 0.05;  // Slower speed for a gentle falling effect
    float starFactor = hash(uv.x * 100.0 + time);  // Pseudo-random factor based on x coordinate and time

    // Adjust vertical position by time to simulate falling
    float starPosition = fract(uv.y - (starFactor + 2*time * star_speed));

    // Create a star when its position matches a small threshold
    if (starPosition < 0.005) {  // Small value for precise star location
        color += float4(0.4, 0.4, 1.0, 1.0);  // Bright white color for stars
    }

    return color;
}
// Fragment Shader for Falling Rain
fragment float4 rainShader4(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord;
    float4 color = float4(0.15, 0.15, 0.2, 1.0); // Dark, moody background

    for (int i = 0; i < NumDrops; ++i) {
        float dropSize = 0.002 + rnd(float(i) * 991.1) * 0.001; // Size of each raindrop
        float xPosition = rnd(float(i) * 7861.1); // Horizontal start position of the raindrop
        float dropSpeed = 0.8 + rnd(float(i) * 1321.1) * 0.4; // Speed of each raindrop

        // Calculate the current position of the drop
        float xDrift = sin(time * 0.5 + float(i)) * WindVariability; // Horizontal wind drift
        float yPosition = fract(uv.y - (time * dropSpeed + rnd(float(i) * 4321.1))); // Vertical position with wrap around

        // Draw each drop as a vertical streak
        float intensity = smoothstep(dropSize, 0.0, abs(uv.x - (xPosition + xDrift)));
        float alpha = smoothstep(0.01, 0.0, abs(uv.y - yPosition));

        // Blend the drop into the scene
        color.rgb += float3(0.5, 0.5, 0.65) * intensity * alpha; // Light blue-gray color for the rain
    }

    return color;
}


fragment float4 mistyShader1(VertexOut in [[stage_in]], constant float &time [[buffer(0)]]) {
    float2 uv = in.texCoord;
    float2 center = float2(0.5, 0.5);
    float dist = distance(uv, center);

    // Blue background
    float4 color = float4(0.0, 0.5, 1.0, 1.0);

    // Central sun glow
    float sunGlow = smoothstep(0.2, 0.0, dist);
    color.rgb += sunGlow * float3(1.0, 0.0, 0.0);

    // Animated rays
    float angle = atan2(uv.y - center.y, uv.x - center.x);
    float rays = sin(10.0 * angle + time * 2.0) * smoothstep(0.4, 0.0, dist);
    color.rgb += rays * float3(1.0, 0.8, 0.0) * 0.5;

    return color;
}

fragment float4 snowShader1(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord - 0.5;
    uv.x *= iResolution.x / iResolution.y;
    float3 color = mix(float3(0.8, 0.5, 0.2), float3(0.2, 0.5, 0.8), uv.y);
    return float4(color, 1.0);
}

// Lightning Shader
fragment float4 lightningShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord;
    float4 color = float4(0.2, 0.2, 0.25, 1.0); // Dark stormy sky base

    float flash = abs(sin(time * 10.0)); // Simplified flash calculation
    if (flash > 0.95) {
        color += float4(0.8, 0.8, 0.9, 1.0) * (flash - 0.95) * 10.0; // Intense flash
    }
    
    return color;
}

// Define random function
float random(float2 uv) {
    return fract(sin(dot(uv, float2(135.0, 263.0))) * 1e4);
}

fragment float4 snowShader5(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord - 0.5;
    uv.x *= iResolution.x / iResolution.y; // Correct for aspect ratio

    // Falling snow effect
    float2 p = uv;
    p.y += time * 0.15;  // Control the speed of the snowfall
    p.y = fract(p.y);  // Wrap around to create a tiling effect

    // Drift effect due to wind
    p.x += 0.05 * sin(time * 0.1 + p.y * 10.0);

    // Create snowflake pattern using a simple function
    float size = 0.02;  // Size of the snowflakes
    float snowflake = smoothstep(size, size + 0.005, abs(fract(p.x * 50.0) - 0.5));
    snowflake *= smoothstep(size, size + 0.005, abs(fract(p.y * 50.0) - 0.5));

    // Final snowflake color, combining the above pattern
    float3 color = float3(snowflake);

    return float4(color, 1.0);
}

// Define snow drawing function
float4 drawSnow9(float2 curid, float2 uv, float4 fragColor, float r, float c, float layer, texture2d<float, access::sample> iChannel0, sampler textureSampler, float TILES, float iTime) {
    float maxoff = 2.0 / TILES; // Max offset a particle can have
    float windStrength = sin(iTime * 0.5 + layer * 2.0) * 0.05 * layer; // Variable wind effect based on layer

    for (int x = -2; x <= 1; x++) {
        for (int y = -2; y <= 0; y++) {
            float rad = (1.0 / (TILES * 5.0)) * r; // Default radius
            float2 id = curid + float2(x, y);
            float2 pos = id / TILES;
            float xmod = fmod(random(pos), maxoff);
            pos.x += xmod;
            pos.y += fmod(random(pos + float2(4.0, 3.0)), maxoff);
            rad *= fmod(random(pos), 10.0);
            pos.x += windStrength + 0.5 * (maxoff - xmod) * sin(iTime * r + random(pos) * 100.0);
            
            float len = length(uv - pos);
            float v = smoothstep(0.0, 1.0, (rad - len) / rad * 0.75);
            float3 colorVariation = float3(c) * (0.9 + 0.1 * sin(layer * pos.y * 100.0));
            fragColor = mix(fragColor, float4(colorVariation, 1.0), v);
        }
    }
    return fragColor;
}

fragment float4 snowShader55(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = 0.2*in.texCoord;  // Normalized coordinates
    float4 color = float4(0.0, 0.0, 0.0, 1.0);  // Initial color

    float rain_speed = 0.1;  // Control the speed of falling rain
    float rainFactor = hash(0.5*uv.x * 100.0);  // Pseudo-random factor based on x coordinate

    // Adjust vertical position by time to simulate falling
    float rainMotion = fract(-uv.y - (rainFactor + time * rain_speed));

    // Simple threshold to create lines
    if (rainMotion < 0.001) {
        color += float4(0.5, 0.7, 0.8, 1.0) * (0.02 - rainMotion) * 10.0;  // Fading effect
    }
    color.rgb += float3(0.5, 0.5, 0.7);  // Constant color addition for aesthetic reasons

    return color;
}


// Noise function for cloud patterns
float noise(float2 st) {
    return fract(sin(dot(st.xy, float2(12.9898,78.233))) * 43758.5453123);
}

// Interpolation function to smooth the noise
float interpolate(float a, float b, float t) {
    return (1.0 - t) * a + t * b;
}

// Fragment shader for cloud rendering
// Function to simulate cloud texture using noise

// Simple hash function for pseudo-randomness
float hash2(float2 p) {
    float h = dot(p, float2(127.1,311.7));
    return fract(sin(h) * 43758.5453123);
}

// Simple noise function using smooth interpolation
float noise2(float2 st) {
    float2 i = floor(st);
    float2 f = fract(st);

    // Four corners in 2D of a tile
    float a = hash2(i);
    float b = hash2(i + float2(1.0, 0.0));
    float c = hash2(i + float2(0.0, 1.0));
    float d = hash2(i + float2(1.0, 1.0));

    // Smooth Interpolation
    float2 u = f*f*(3.0-2.0*f);
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

// Fragment shader for cloud rendering
// Fragment shader for animated cloud rendering
fragment float4 cloudShader(VertexOut in [[stage_in]],
                            constant float &time [[buffer(0)]],
                            constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord;  // Normalized coordinates
    uv.x *= iResolution.x / iResolution.y;  // Adjust for aspect ratio

    // Add time-dependent horizontal translation for cloud movement
    float translation = time * 0.1;  // Slowly move the clouds over time
    float n = noise2((uv + float2(translation, 0.0)) * 3.0); // Adjust the scale to control detail

    float cloudDensity = smoothstep(0.5, 0.2, n); // Adjust these thresholds to fine-tune cloud appearance

    float4 bgColor = float4(0.5, 0.6, 0.8, 1.0); // Light blue sky
    float4 cloudColor = float4(0.8, 0.8, 0.9, 1.0); // Almost white clouds

    float4 color = mix(bgColor, cloudColor, cloudDensity); // Blend sky and clouds based on noise density

    return color;
}



// Function to interpolate between colors
float3 interpolateColors(float3 colorA, float3 colorB, float factor) {
    return mix(colorA, colorB, factor);
}

// Fragment shader for rendering clouds, sun, and a dynamic background
fragment float4 cloudSunShader1(VertexOut in [[stage_in]],
                               constant float &time [[buffer(0)]],
                               constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord - 0.5;
    uv.x *= iResolution.x / iResolution.y; // Correct aspect ratio

    // Time-based background color change
    float dayCycle = sin(time * 0.1) * 0.5 + 0.5; // Normalized day cycle [0, 1]
    float3 morningColor = float3(0.8, 0.4, 0.1); // Warm morning
    float3 noonColor = float3(0.2, 0.5, 0.8); // Clear blue sky
    float3 eveningColor = float3(0.1, 0.2, 0.5); // Darker blue

    // Interpolate between different times of day
    float3 bgColor = interpolateColors(morningColor, noonColor, clamp(dayCycle * 2.0, 0.0, 1.0));
    if (dayCycle > 0.5) {
        bgColor = interpolateColors(noonColor, eveningColor, clamp((dayCycle - 0.5) * 2.0, 0.0, 1.0));
    }

    // Clouds logic
    float translation = time * 0.1; // Clouds move over time
    float n = noise2((uv + float2(translation, 0.0)) * 3.0); // Cloud pattern generation
    float cloudDensity = smoothstep(0.5, 0.2, n); // Adjust cloud visibility

    // Sun effect (optional, remove if not needed)
    float sunPosition = sin(time * 0.1) * 0.5 + 0.5;  // Sun's vertical position over time, simulating day cycle
    float sunSize = 0.1;  // Size of the sun
    float sunIntensity = smoothstep(sunSize, sunSize - 0.05, length(uv - float2(0.5, sunPosition)));  // Intensity of the sun

    float4 sunColor = float4(1.0, 0.9, 0.6, 1.0); // Sun color
    float4 color = float4(bgColor, 1.0); // Background sky color
    color = mix(color, float4(0.8, 0.8, 0.9, 1.0), cloudDensity); // Blend in clouds
    color = mix(color, sunColor, sunIntensity); // Blend in sun

    return color;
}


//fragment float4 cloudSunShader(VertexOut in [[stage_in]],
//                               constant float &time [[buffer(0)]],
//                               constant float2 &iResolution [[buffer(1)]]) {
//    float2 uv = in.texCoord - 0.5;
//    uv.x *= iResolution.x / iResolution.y; // Correct aspect ratio
//
//    // Background gradient (sunny sky)
//    float3 bgColor = mix(float3(0.8, 0.5, 0.2), float3(0.2, 0.5, 0.8), uv.y + 0.5);
//
//    // Clouds logic
//    float translation = time * 0.1; // Clouds move over time
//    float n = noise2((uv + float2(translation, 0.0)) * 3.0); // Cloud pattern generation
//    float cloudDensity = smoothstep(0.5, 0.2, n); // Adjust cloud visibility
//
//    // Cloud colors
//    float4 cloudColor = float4(0.8, 0.8, 0.9, 1.0); // Almost white clouds
//
//    // Blend sky and clouds based on noise density
//    float4 color = mix(float4(bgColor, 1.0), cloudColor, cloudDensity);
//
//    return color;
//}


// Function to interpolate between colors over time
float3 timeBasedColor(float time) {
    float dayCycle = sin(time * 0.5) * 0.5 + 0.5; // Normalized day cycle [0, 1]
    float3 morningColor = float3(0.8, 0.4, 0.1); // Warm morning
    float3 noonColor = float3(0.8, 0.6, 0.8); // Clear blue sky
    float3 eveningColor = float3(0.5, 0.5, 0.8); // Darker blue

    // Interpolate between different times of day
    float3 color = mix(morningColor, noonColor, clamp(dayCycle * 2.0, 0.0, 1.0));
    if (dayCycle > 0.5) {
        color = mix(noonColor, eveningColor, clamp((dayCycle - 0.5) * 2.0, 0.0, 1.0));
    }

    return color;
}

// Fragment shader for rendering the combined sunny sky and clouds
fragment float4 cloudSunShader(VertexOut in [[stage_in]],
                               constant float &time [[buffer(0)]],
                               constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord - 0.5;
    uv.x *= iResolution.x / iResolution.y; // Correct aspect ratio

    // Dynamic background gradient based on time
    float3 bgColor = timeBasedColor(time);

    // Clouds logic
    float translation = time * 0.1; // Clouds move over time
    float n = noise2((uv + float2(translation, 0.0)) * 3.0); // Cloud pattern generation
    float cloudDensity = smoothstep(0.5, 0.2, n); // Adjust cloud visibility

    // Cloud colors
    float4 cloudColor = float4(0.8, 0.8, 0.9, 1.0); // Almost white clouds
    float3 bgColor2 = mix(float3(0.8, 0.5, 0.2), float3(0.2, 0.5, 0.8), uv.y + 0.5);
   //
    float3 bgColor3 = mix(bgColor, bgColor2, uv.y + 0.5);
    

    // Blend sky and clouds based on noise density
    float4 color = mix(float4(bgColor3, 1), cloudColor, cloudDensity);

    return color;
}

fragment float4 mistyShader(VertexOut in [[stage_in]],
                               constant float &time [[buffer(0)]],
                               constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord - 0.5;
    uv.x *= iResolution.x / iResolution.y; // Correct aspect ratio

    // Sun color logic
    float3 sunColor = mix(float3(0.8, 0.5, 0.2), float3(0.2, 0.5, 0.8), uv.y + 0.5);

    // Clouds logic
    float translation = time * 0.1; // Clouds move over time
    float n = noise2((uv + float2(translation, 0.0)) * 3.0); // Cloud pattern generation
    float cloudDensity = smoothstep(0.5, 0.2, n); // Adjust cloud visibility

    float4 bgColor = float4(sunColor, 1.0); // Background color from sun logic
    float4 cloudColor = float4(0.8, 0.8, 0.9, 1.0); // Cloud color

    // Mix cloud and background color based on cloud density
    float4 color = mix(bgColor, cloudColor, cloudDensity);

    return color;
}

// Fragment shader for a sunny sky

//fragment float4 snowShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
//    float2 uv = in.texCoord - 0.5;
//    uv.x *= iResolution.x / iResolution.y; // Aspect ratio correction
//
//    float4 bgColor = float4(0.8, 0.8, 0.9, 1.0); // Light blue-gray background
//
//    // Parameters for snowflake rendering
//    float flakeCount = 200.0; // Total number of snowflakes
//    float4 color = bgColor;
//
//    for (int i = 0; i < int(flakeCount); ++i) {
//        float2 flakePosition = float2(random(float2(float(i), time)), random(float2(time, float(i)))); // Random position
//        float2 p = uv * float2(iResolution.x / iResolution.y, 1.0) + flakePosition; // Position adjusted by UV and randomness
//        p = fract(p); // Wrap around effect for continuous tiling
//
//        float size = 0.01 + 0.02 * random(float2(float(i), time)); // Random size for each flake
//        float distance = length(p - 0.5); // Distance from the center of each flake
//        float alpha = smoothstep(size, size - 0.005, distance); // Soft edges for flakes
//
//        color.rgb += (1.0 - alpha) * float3(1.0, 1.0, 1.0); // Adding white flakes over the background
//    }
//
//    return color;
//}
//#include <metal_stdlib>
//using namespace metal;
//
//constant int SnowflakeAmount = 50; // Number of snowflakes
//constant float BlizzardFactor = 0.2;
//constant float DropSpeed = 1.2; // Speed at which raindrops fall
//constant float DropWidth = 0.0015; // Width of the raindrops
//constant int NumDrops = 100; // Number of raindrops for performance balance// Fury of the storm!
//// Utility function for random number generation
//float rnd(float x) {
//    return fract(sin(x) * 43758.5453123);
//}
//
//float rnd(float2 p) {
//    return fract(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
//}
//// Noise function for smoke/mist effect
//float noise(float2 st) {
//    float2 i = floor(st);
//    float2 f = fract(st);
//    float a = rnd(i);
//    float b = rnd(i + float2(1.0, 0.0));
//    float c = rnd(i + float2(0.0, 1.0));
//    float d = rnd(i + float2(1.0, 1.0));
//    float2 u = f * f * (3.0 - 2.0 * f);
//    return mix(a, b, u.x) +
//           (c - a) * u.y * (1.0 - u.x) +
//           (d - b) * u.x * u.y;
//}
//
//// Function to draw a circle
//float drawCircle(float2 center, float radius, float2 uv) {
//    return 1.0 - smoothstep(0.0, radius, length(uv - center));
//}
//
//// Vertex Shader
//struct VertexOut {
//    float4 position [[position]];
//    float2 texCoord;
//};
//
//vertex VertexOut vertexShader(uint vertexID [[vertex_id]], constant float2 *vertices [[buffer(0)]]) {
//    VertexOut out;
//    out.position = float4(vertices[vertexID] * 2.0 - 1.0, 0.0, 1.0);
//    out.texCoord = vertices[vertexID];
//    return out;
//}
//
// Sun Shader
fragment float4 sunShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord - 0.5;
    uv.x *= iResolution.x / iResolution.y;
    float3 color = mix(float3(0.8, 0.5, 0.2), float3(0.2, 0.5, 0.8), uv.y);
    return float4(color, 1.0);
}

