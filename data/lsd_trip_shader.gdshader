shader_type canvas_item;

uniform sampler2D noise: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform vec2 scroll = vec2(0.05,0.05);
uniform vec2 scroll2 = vec2(-0.05,-0.05);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float distortion_strength : hint_range(-1,1) = 0.0;

void fragment() {
	float depth = texture(noise,UV + scroll * TIME).r * texture(noise2,UV + scroll2 * TIME).r;
	vec4 screen_col = texture(SCREEN_TEXTURE,SCREEN_UV + distortion_strength * vec2(depth));
	COLOR = screen_col;
}


