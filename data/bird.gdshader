shader_type spatial;

uniform float animation_speed = 0.5;
uniform vec4 flame_color: source_color = vec4(1.0);
uniform sampler2D noise_texture: filter_nearest, repeat_enable, hint_default_black;

uniform vec2 resolution = vec2(600.0,400.0);
uniform float density: hint_range(1.0,100.0,1) = 20;



void fragment() {
	vec2 uv = UV;
	uv.x *= resolution.x / resolution.y;
	float stars = 0.0;
	stars += pow(texture(noise_texture, uv).r,density);
	ALBEDO = vec3(stars);
	ALPHA = 1.0;

}

