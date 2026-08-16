#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uRefraction;
uniform float uChromatic;
uniform float uNoise;

out vec4 fragColor;

float hash(vec2 p) {
    p = 50.0 * fract(p * 0.3183099 + vec2(0.71, 0.113));
    return -1.0 + 2.0 * fract(p.x * p.y * (p.x + p.y));
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;

    // Procedural Liquid Pattern (Simulating refraction)
    float n1 = noise(uv * 3.0 + uTime * 0.1);
    float n2 = noise(uv * 6.0 - uTime * 0.05);
    float combined = n1 * 0.7 + n2 * 0.3;

    // Shift UV based on noise to simulate internal refraction
    vec2 refractedUv = uv + vec2(combined) * uRefraction;

    // Generate organic color drift
    float r = noise(refractedUv * 2.0 + uTime * 0.02 + vec2(uChromatic));
    float g = noise(refractedUv * 2.1 + uTime * 0.02);
    float b = noise(refractedUv * 2.2 + uTime * 0.02 - vec2(uChromatic));

    vec3 color = vec3(r, g, b) * 0.05; // Extremely subtle internal liquid color

    // Add grain/noise
    float grain = (fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * uNoise;
    color += grain;

    // Output a subtle, shifting liquid layer
    fragColor = vec4(color, color.r * 2.0 + 0.02);
}
