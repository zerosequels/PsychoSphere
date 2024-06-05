shader_type canvas_item;

uniform vec2 center;
uniform float force;

uniform float hue_shift : hint_range(0.0,1.0) = 0.0;
uniform vec3 line_color: source_color = vec3(0.1,0.4,0.2);


void fragment() {
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 scaled_uv = (SCREEN_UV - vec2(0.5,0.0))/vec2(ratio,1.0) + vec2(0.5,0.0);
	vec2 disp = normalize(scaled_uv - center) * force;
	//COLOR = vec4(disp,0.0,1.0);
	COLOR = texture(TEXTURE,UV - disp) * vec4(line_color,1.0);
	
}

