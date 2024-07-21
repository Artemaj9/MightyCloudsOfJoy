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
//fragment float4 sunShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]]) {
//    float2 uv = in.texCoord;
//    float2 center = float2(0.5, 0.5);
//    float dist = distance(uv, center);
//    
//    // Blue background
//    float4 color = float4(0.0, 0.5, 1.0, 1.0);
//    
//    // Central sun glow
//    float sunGlow = smoothstep(0.2, 0.0, dist);
//    color.rgb += sunGlow * float3(1.0, 0.0, 0.0);
//    
//    // Animated rays
//    float angle = atan2(uv.y - center.y, uv.x - center.x);
//    float rays = sin(10.0 * angle + time * 2.0) * smoothstep(0.4, 0.0, dist);
//    color.rgb += rays * float3(1.0, 0.8, 0.0) * 0.5;
//    
//    return color;
//}
// good
#include <metal_stdlib>
using namespace metal;

// Utility functions
float rnd(float2 p) {
    return fract(sin(dot(p, float2(12.1234, 72.8392))) * 45123.2);
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

// Sun Shader
fragment float4 sunShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]], constant float4 &iMouse [[buffer(2)]]) {
    float2 uv = in.texCoord - 0.5;
    uv.x *= iResolution.x / iResolution.y;

    float2 mm = iMouse.xy / iResolution.xy - 0.5;
    mm.x *= iResolution.x / iResolution.y;

    if (iMouse.z < 1.0) {
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

//// Snow Shader
//fragment float4 snowShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]]) {
//    float2 uv = in.texCoord;
//    float4 color = float4(0.0, 0.0, 0.0, 1.0);
//    
//    // Generate multiple layers of snowflakes
//    for (int i = 0; i < 10; ++i) {
//        float speed = float(i) * 0.1 + 0.2;
//        float size = float(i) * 0.02 + 0.01;
//        float opacity = 1.0 / float(i + 1);
//        
//        float2 position = float2(fract(sin(dot(uv * 10.0 + float2(time * speed, time * speed * 1.5), float2(12.9898, 78.233))) * 43758.5453),
//                                 fract(sin(dot(uv * 10.0 + float2(time * speed * 1.5, time * speed), float2(12.9898, 78.233))) * 43758.5453));
//        
//        float dist = distance(uv, position);
//        float intensity = smoothstep(size, size + 0.01, 1.0 - dist);
//        color.rgb += intensity * float3(1.0) * opacity;
//    }
//    
//    return color;
//}



fragment float4 snowShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {
    float2 uv = in.texCoord;
    float4 color = float4(0.0, 0.0, 0.0, 1.0);
    
    // Lightning effect
    float lightning = 0.0;
    float lightningFrequency = 1.0; // Frequency of lightning flashes
    if (sin(time * lightningFrequency) > 0.95) { // Flash occurs when sine wave is near its peak
        lightning = 1.0;
    }

    // Generate multiple layers of raindrops
    for (int i = 0; i < 20; ++i) {
        float speed = float(i) * 0.2 + 0.5;
        float length = float(i) * 0.02 + 0.05;
        float opacity = 1.0 / float(i + 1);
        
        float2 position = float2(fract(uv.x + time * speed), fract(uv.y + time * speed * 0.5));
        
        float dist = distance(uv, position);
        float streak = smoothstep(0.02, 0.03, dist) - smoothstep(0.03, 0.04, dist);
        color.rgb += streak * float3(0.5, 0.5, 1.0) * opacity;
        
        // Simulate splashes
        float splash = smoothstep(0.0, 0.02, dist) * smoothstep(length, 0.0, dist);
        color.rgb += splash * float3(0.2, 0.4, 0.6) * opacity;
    }
    
    // Apply lightning effect by increasing the brightness
    color.rgb += lightning * 0.8;
    
    return color;
}

// Rain Shader
//fragment float4 rainShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]]) {
//    float2 uv = in.texCoord;
//    float4 color = float4(0.0, 0.0, 0.0, 1.0);
//    
//    // Generate multiple layers of raindrops
//    for (int i = 0; i < 20; ++i) {
//        float speed = float(i) * 0.2 + 0.5;
//        float length = float(i) * 0.02 + 0.05;
//        float opacity = 1.0 / float(i + 1);
//        
//        float2 position = float2(fract(uv.x + time * speed), fract(uv.y + time * speed * 0.5));
//        
//        float dist = distance(uv, position);
//        float streak = smoothstep(0.02, 0.03, dist) - smoothstep(0.03, 0.04, dist);
//        color.rgb += streak * float3(0.5, 0.5, 1.0) * opacity;
//        
//        // Simulate splashes
//        float splash = smoothstep(0.0, 0.02, dist) * smoothstep(length, 0.0, dist);
//        color.rgb += splash * float3(0.2, 0.4, 0.6) * opacity;
//    }
//    
//    return color;
//}

//fragment float4 rainShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]]) {
//    float2 uv = in.texCoord;
//    float4 color = float4(0.0, 0.0, 0.0, 1.0);
//    
//    // Lightning effect
//    float lightning = 0.0;
//    float lightningFrequency = 1.0; // Frequency of lightning flashes
//    if (sin(time * lightningFrequency) > 0.95) { // Flash occurs when sine wave is near its peak
//        lightning = 1.0;
//    }
//
//    // Generate multiple layers of raindrops
//    for (int i = 0; i < 20; ++i) {
//        float speed = float(i) * 0.2 + 0.5;
//        float length = float(i) * 0.02 + 0.05;
//        float opacity = 1.0 / float(i + 1);
//        
//        float2 position = float2(fract(uv.x + time * speed), fract(uv.y + time * speed * 0.5));
//        
//        float dist = distance(uv, position);
//        float streak = smoothstep(0.02, 0.03, dist) - smoothstep(0.03, 0.04, dist);
//        color.rgb += streak * float3(0.5, 0.5, 1.0) * opacity;
//        
//        // Simulate splashes
//        float splash = smoothstep(0.0, 0.02, dist) * smoothstep(length, 0.0, dist);
//        color.rgb += splash * float3(0.2, 0.4, 0.6) * opacity;
//    }
//    
//    // Apply lightning effect by increasing the brightness
//    color.rgb += lightning * 0.8;
//    
//    return color;
//}


