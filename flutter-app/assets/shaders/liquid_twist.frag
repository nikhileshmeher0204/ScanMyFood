#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 u_resolution;
uniform float u_time;
uniform vec3 u_bgColor;
uniform sampler2D u_image;

out vec4 fragColor;

// ─── Tuning ──────────────────────────────────────────────────────────────────
const float rotSpeed     = 0.04; 
const float swirlMag     = 5.20;  // High swirl strength for tight twists
const float edgeSoftness = 0.02; // Sharp opaque edges
// ─────────────────────────────────────────────────────────────────────────────

// Boost vibrancy/saturation and contrast of layer colors to prevent muting under blur
vec3 adjustColor(vec3 rgb) {
    // 1. Saturation boost (vibrancy factor = 1.45)
    float luma = dot(rgb, vec3(0.299, 0.587, 0.114));
    vec3 saturated = mix(vec3(luma), rgb, 1.45);
    
    // 2. Contrast boost (contrast factor = 1.10)
    return clamp((saturated - 0.5) * 1.10 + 0.5, 0.0, 1.0);
}

// Compute the image UV for a given screen fragment with 3D tilt and multiple folds:
vec2 layerUV3D(vec2 st, vec2 center, float scale, float angle, vec2 tilt,
               float swirl, vec2 swirlPivot) {
    float asp = u_resolution.x / u_resolution.y;

    // 1. Center and aspect-ratio correct the screen coordinate
    vec2 p = st - center;
    p.x *= asp;

    // 2. Apply 3D perspective tilt (yaw and pitch)
    float divisor = 1.0 + p.x * tilt.x + p.y * tilt.y;
    vec2 uv = p / divisor;

    // 3. Rotate around Z-axis (2D roll)
    float c = cos(angle), s = sin(angle);
    uv = vec2(uv.x * c - uv.y * s,
              uv.x * s + uv.y * c);

    // Restore aspect ratio and map to [0, 1] texture coordinates
    uv.x /= asp;
    uv = uv / scale + vec2(0.5);

    // 4. Z-axis deformation (Smooth organic wave fold)
    vec2 d = uv - vec2(0.5);
    float dist = length(d);
    
    // A single large, smooth organic wave fold across the surface (frequency = 5.0)
    float Z = sin(dist * 5.0) * 0.12;
    
    // Displace texture coordinate along the viewing direction by Z-depth fold
    uv += d * Z * 1.2;

    // 5. Swirl twist (pre-distortion applied relative to texture coords)
    vec2 sd = uv - swirlPivot;
    float r = length(sd * vec2(asp, 1.0));
    float ta = swirl * (1.0 - smoothstep(0.0, 0.70, r));
    float ct = cos(ta), st2 = sin(ta);
    sd = vec2(sd.x * ct - sd.y * st2, sd.x * st2 + sd.y * ct);
    uv = swirlPivot + sd;

    return uv;
}

// Stack a 3D layer on top of 'base'.
vec4 stackLayer3D(vec4 base, vec2 st, vec2 center, float scale, float angle, vec2 tilt,
                  float swirl, vec2 swirlPivot) {
    vec2 uv = layerUV3D(st, center, scale, angle, tilt, swirl, swirlPivot);

    // Mask: 1.0 inside [0, 1] texture bounds, 0.0 outside
    float mx = smoothstep(0.0, edgeSoftness, uv.x) *
               smoothstep(0.0, edgeSoftness, 1.0 - uv.x);
    float my = smoothstep(0.0, edgeSoftness, uv.y) *
               smoothstep(0.0, edgeSoftness, 1.0 - uv.y);
    float mask = mx * my;

    vec4 col = texture(u_image, clamp(uv, 0.0, 1.0));
    col.rgb = adjustColor(col.rgb); // Apply color adjustments
    return mix(base, col, mask);
}

void main() {
    vec2 st = FlutterFragCoord().xy / u_resolution.xy;
    float t  = u_time * rotSpeed;

    // All layers are strictly 1.0 scale (no scaling)
    const float layerScale = 1.0;

    // ── Dynamic Background Color ─────────────────────────────────────────────
    vec4 baseBgColor = vec4(u_bgColor, 1.0);

    // ── Layer 1 — Center Layer (shows face, scale: 1.0) ───────────────────────
    vec2 c1 = vec2(0.40, 0.50);
    vec2 tilt1 = vec2(0.12 * sin(u_time * 0.15), 0.15 * cos(u_time * 0.12));
    vec2 uvBase = layerUV3D(st, c1, layerScale, t * 1.0, tilt1, swirlMag * 0.80, vec2(0.50, 0.50));
    
    // Mask for Layer 1
    float mx1 = smoothstep(0.0, edgeSoftness, uvBase.x) *
                smoothstep(0.0, edgeSoftness, 1.0 - uvBase.x);
    float my1 = smoothstep(0.0, edgeSoftness, uvBase.y) *
                smoothstep(0.0, edgeSoftness, 1.0 - uvBase.y);
    float mask1 = mx1 * my1;
    
    vec4 col1 = texture(u_image, clamp(uvBase, 0.0, 1.0));
    col1.rgb = adjustColor(col1.rgb); // Apply color adjustments
    vec4 result = mix(baseBgColor, col1, mask1);

    // ── Layer 2 — Corner 1 (Opaque, no face, scale: 1.0) ──────────────────────
    // Shifted slightly towards the top-center (from X=-0.18 to X=-0.05, Y=-0.05 to Y=-0.08)
    vec2 c2 = vec2(-0.05, -0.08);
    vec2 tilt2 = vec2(-0.25, -0.20);
    result = stackLayer3D(result, st, c2, layerScale, -t * 0.80, tilt2, swirlMag * 0.85, vec2(0.50, 0.50));

    // ── Layer 3 — Corner 2 (Opaque, no face, scale: 1.0) ──────────────────────
    vec2 c3 = vec2(1.18, -0.05);
    vec2 tilt3 = vec2(0.25, -0.20);
    result = stackLayer3D(result, st, c3, layerScale, t * 0.90, tilt3, swirlMag * 0.90, vec2(0.50, 0.50));

    // ── Layer 4 — Edge Layer (Opaque, no face, scale: 1.0) ────────────────────
    vec2 c4 = vec2(0.50, 1.05);
    vec2 tilt4 = vec2(0.00, 0.25);
    result = stackLayer3D(result, st, c4, layerScale, -t * 1.10, tilt4, swirlMag * 0.95, vec2(0.50, 0.50));

    // ── Layer 5 — Corner 3 (Opaque, no face, scale: 1.0) ──────────────────────
    vec2 c5 = vec2(1.18, 0.50);
    vec2 tilt5 = vec2(0.20, 0.20);
    result = stackLayer3D(result, st, c5, layerScale, t * 0.75, tilt5, swirlMag * 0.80, vec2(0.50, 0.50));

    fragColor = result;
}
