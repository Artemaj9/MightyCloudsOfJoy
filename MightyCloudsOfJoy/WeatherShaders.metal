#include <metal_stdlib>
using namespace metal;

float rnd(float w) {
    return fract(sin(w) * 1000.0);
}

// MARK: Vertex Shader

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

 // MARK: Sun Shader

float regShape(float2 p, int N) {
    float a = atan2(p.y, p.x) + 0.2;
    float b = 6.28319 / float(N);
    return smoothstep(0.5, 0.51, cos(floor(0.5 + a / b) * b - a) * length(p));
}

float3 circle(float2 p, float size, float decay, float3 color, float3 color2, float dist, float2 m) {
    float l = length(p + m * (dist * 4.0)) + size / 2.0;
    float c = max(0.01 - pow(length(p + m * dist), size * 1.4), 0.0) * 50.0;
    float c1 = max(0.001 - pow(l - 0.3, 1.0 / 40.0) + sin(l * 30.0), 0.0) * 3.0;
    float c2 = max(0.04 / pow(length(p - m * dist / 2.0 + 0.09) * 1.0, 1.0), 0.0) / 20.0;
    float s = max(0.01 - pow(regShape(p * 5.0 + m * dist * 5.0 + 0.9, 6), 1.0), 0.0) * 5.0;

    color = 0.5 + 0.5 * sin(color);
    color = cos(float3(0.44, 0.24, 0.2) * 8.0 + dist * 4.0) * 0.5 + 0.5;
    float3 f = c * color;
    f += c1 * color;
    f += c2 * color;
    f += s * color;
    return f - 0.01;
}

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
    float bright = 0.1;

    color += max(0.1 / pow(length(uv - mm) * 5.0, 5.0), 0.0) * abs(sin(a * 5.0 + cos(a * 9.0))) / 20.0;
    color += max(0.1 / pow(length(uv - mm) * 10.0, 1.0 / 20.0), 0.0) + abs(sin(a * 3.0 + cos(a * 9.0))) / 8.0 * (abs(sin(a * 9.0))) / 1.0;
    color += (max(bright / pow(length(uv - mm) * 4.0, 1.0 / 2.0), 0.0) * 4.0) * float3(0.2, 0.21, 0.3) * 4.0;
    color *= exp(1.0 - length(uv - mm)) / 5.0;

    return float4(color, 1.0);
}

// MARK: Rain Shader

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

fragment float4 rainShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord;
    float4 color = float4(0.0, 0.0, 0.0, 1.0);

    float rain_speed = 0.3;
    float rainFactor = hash(uv.x * 100.0);

    float rainMotion = fract(-uv.y - (rainFactor + time * rain_speed));

    // Simple threshold to create lines
    if (rainMotion < 0.02) {
        color += float4(0.5, 0.7, 0.8, 1.0) * (0.02 - rainMotion) * 50.0;  // Fading effect
    }
    color.rgb += float3(0.1, 0.1, 0.2);  // add constant color

    return color;
}

// MARK: Snow Shader

fragment float4 snowShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord; 
    float4 color = float4(0.4, 0.6, 0.8, 1.0);  // Sky color

    float star_speed = 0.05;
    float starFactor = hash(uv.x * 100.0 + time);
    
    float starPosition = fract(uv.y - (starFactor + 2*time * star_speed));

    if (starPosition < 0.005) {
        color += float4(0.4, 0.4, 1.0, 1.0);
    }

    return color;
}

// MARK: Lightning Shader

fragment float4 lightningShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float4 color = float4(0.2, 0.2, 0.25, 1.0); // Stormy sky bg

    float flash = abs(sin(time * 10.0)); // Flash calculation
    if (flash > 0.95) {
        color += float4(0.8, 0.8, 0.9, 1.0) * (flash - 0.95) * 10.0; // Intense flash
    }
    
    return color;
}

// MARK: Cloud shader

float hashCloud(float2 p) {
    float h = dot(p, float2(127.1,311.7));
    return fract(sin(h) * 43758.5453123);
}

// Simple noise function using smooth interpolation
float noiseCloud(float2 st) {
    float2 i = floor(st);
    float2 f = fract(st);

    // Four corners in 2D of a tile
    float a = hashCloud(i);
    float b = hashCloud(i + float2(1.0, 0.0));
    float c = hashCloud(i + float2(0.0, 1.0));
    float d = hashCloud(i + float2(1.0, 1.0));

    // Smooth Interpolation
    float2 u = f*f*(3.0-2.0*f);
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

fragment float4 cloudShader(VertexOut in [[stage_in]],
                            constant float &time [[buffer(0)]],
                            constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord;
    uv.x *= iResolution.x / iResolution.y;

    // horizontal translation for cloud
    float translation = time * 0.1;
    float n = noiseCloud((uv + float2(translation, 0.0)) * 3.0);

    float cloudDensity = smoothstep(0.5, 0.2, n); // Adjust cloud appearance

    float4 bgColor = float4(0.5, 0.6, 0.8, 1.0); // Light blue sky
    float4 cloudColor = float4(0.8, 0.8, 0.9, 1.0); // Almost white clouds

    float4 color = mix(bgColor, cloudColor, cloudDensity); // Blend sky and clouds based on density

    return color;
}

// MARK: CloudySun shader

// Interpolate between colors
float3 interpolateColors(float3 colorA, float3 colorB, float factor) {
    return mix(colorA, colorB, factor);
}

// Interpolate between colors over time
float3 timeBasedColor(float time) {
    float dayCycle = sin(time * 0.5) * 0.5 + 0.5;
    float3 morningColor = float3(0.8, 0.4, 0.1); // Warm
    float3 noonColor = float3(0.8, 0.6, 0.8); // Clear
    float3 eveningColor = float3(0.5, 0.5, 0.8); // Darker

    // Interpolate between different times
    float3 color = mix(morningColor, noonColor, clamp(dayCycle * 2.0, 0.0, 1.0));
    if (dayCycle > 0.5) {
        color = mix(noonColor, eveningColor, clamp((dayCycle - 0.5) * 2.0, 0.0, 1.0));
    }

    return color;
}

fragment float4 cloudSunShader(VertexOut in [[stage_in]],
                               constant float &time [[buffer(0)]],
                               constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord - 0.5;
    uv.x *= iResolution.x / iResolution.y;

    // Dynamic background gradient based on time
    float3 bgColor = timeBasedColor(time);

    // Clouds logic
    float translation = time * 0.1;
    float n = noiseCloud((uv + float2(translation, 0.0)) * 3.0);
    float cloudDensity = smoothstep(0.5, 0.2, n); // Adjust cloud visibility

    // Adjust cloud colors
    float4 cloudColor = float4(0.8, 0.8, 0.9, 1.0); // Almost white clouds
    float3 bgColor2 = mix(float3(0.8, 0.5, 0.2), float3(0.2, 0.5, 0.8), uv.y + 0.5);
    float3 bgColor3 = mix(bgColor, bgColor2, uv.y + 0.5);

    // Blend sky and clouds
    float4 color = mix(float4(bgColor3, 1), cloudColor, cloudDensity);

    return color;
}
