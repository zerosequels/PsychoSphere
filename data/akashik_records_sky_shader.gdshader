shader_type sky;

uniform vec3 skyColor : source_color;
uniform vec3 horizonColor: source_color;
uniform vec3 auroraColor1: source_color = vec3(0.1, 0.8, 0.4);  // Green aurora
uniform vec3 auroraColor2: source_color = vec3(0.1, 0.2, 0.8);  // Blue aurora
uniform float time;
uniform float noise_scale = 10.0;
uniform float aurora_speed = 0.2;
uniform float aurora_intensity = 1.5;
uniform float aurora_scale = 1.0;  // Controls the size of aurora patterns
uniform float star_intensity = 0.8;
uniform float star_speed = 1.0;  // Controls star movement speed

// Hash function for noise
vec2 hash(vec2 p) {
    p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

// Star hash function
float star_hash(vec2 p) {
    float h = dot(p, vec2(127.1,311.7));
    return fract(sin(h)*43758.5453123);
}

// Gradient noise function
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(dot(hash(i + vec2(0.0,0.0)), f - vec2(0.0,0.0)),
                   dot(hash(i + vec2(1.0,0.0)), f - vec2(1.0,0.0)), u.x),
               mix(dot(hash(i + vec2(0.0,1.0)), f - vec2(0.0,1.0)),
                   dot(hash(i + vec2(1.0,1.0)), f - vec2(1.0,1.0)), u.x), u.y);
}

// FBM (Fractal Brownian Motion) for layered noise
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for(int i = 0; i < 6; i++) {
        value += amplitude * noise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    
    return value;
}

// Star field function with movement
float stars(vec2 uv, float t) {
    // Add movement to the stars
    vec2 moving_uv = uv + vec2(t * star_speed * 0.2, t * star_speed * 0.1);
    
    vec2 grid = fract(moving_uv * 1000.0);
    float star_val = star_hash(floor(moving_uv * 1000.0));
    
    // Twinkle effect
    //float twinkle = sin(t * 3.0 + star_val * 10.0) * 0.5 + 0.5;
    //twinkle *= sin(t * 2.0 + star_val * 5.0) * 0.5 + 0.5;  // Additional twinkle layer
    
    // Star shape and glow
    float star = step(0.97, star_val);// * twinkle;
    float glow = (1.0 - length(grid - 0.5) * 2.0);
    glow = pow(glow, 3.0);  // Sharper glow falloff
    star *= glow;
    
    // Add pulsing glow
    //float pulse = sin(t * 2.0 + star_val * 20.0) * 0.5 + 0.5;
    star *= 1.0;
    
    return star * star_intensity;
}

// Aurora effect function
vec3 aurora(vec2 uv, float t) {
    // Scale the UV coordinates to control aurora size
    uv *= aurora_scale;
    
    // Create base wave pattern with scaled coordinates
    float wave = fbm(vec2(uv.x * 2.0 + t * 0.5, uv.y * 2.0));
    
    // Create vertical bands with movement (adjusted for scale)
    float bands = sin(uv.x * 3.0 + wave * 2.0 + t * 0.5) * 0.5 + 0.5;
    
    // Modified falloff to allow aurora to extend higher (adjusted for scale)
    float falloff = exp(-abs(uv.y / aurora_scale) * 2.0);
    
    // Create dancing effect with scaled coordinates
    vec2 dance_uv = uv + vec2(
        sin(t * 0.5 + uv.y * 2.0) * 0.2,
        cos(t * 0.3 + uv.x * 3.0) * 0.1
    ) * aurora_scale;
    
    float dance = fbm(dance_uv * 4.0 + t * 0.2);
    
    // Combine effects
    float aurora_mask = bands * falloff * dance;
    
    // Color variation based on position with smoother transition
    float height_factor = smoothstep(-1.0, 1.0, uv.y / aurora_scale);
    vec3 aurora = mix(auroraColor1, auroraColor2, height_factor);
    
    return aurora * aurora_mask * aurora_intensity;
}

void sky() {
    // Create smoother base gradient with wider transition zone
    float gradient = smoothstep(-0.2, 0.3, EYEDIR.y);
    
    // Calculate UV coordinates for effects
    vec2 uv = vec2(EYEDIR.x, EYEDIR.z) * noise_scale;
    
    // Base sky color with smoother transition
    vec3 final_color = mix(horizonColor, skyColor, gradient);
    
    // Add stars
    float star_field = stars(vec2(EYEDIR.x, EYEDIR.y) * 0.5, TIME);
    final_color += vec3(star_field);
    
    // Add aurora across entire sky with varying intensity
    vec2 aurora_uv = vec2(EYEDIR.x, EYEDIR.y) * 0.5;
    vec3 aurora_effect = aurora(aurora_uv, TIME);
    
    // Blend aurora with sky using a custom falloff
    float aurora_blend = smoothstep(-1.0, 1.0, EYEDIR.y);
    aurora_blend = mix(0.5, 1.0, aurora_blend);
    
    final_color += aurora_effect * aurora_blend;
    
    COLOR = final_color;
}
