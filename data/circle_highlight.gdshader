shader_type spatial;

uniform float scan_line_count: hint_range(0,1080) = 20.0;
uniform vec3 circle_color: source_color = vec3(1,1,1);
uniform float scroll_speed: hint_range(0.0, 50.0, 1) = 10;
uniform float circle_opacity: hint_range(0.0, 1.0, 0.1) = 1.0;

void fragment() {
	vec2 uv = UV - 0.5;
	float d = length(uv);
	float r = 0.5;
	float l = 0.495;
	float c = 0.0;

	if(d<r) c = 1.0;
	if(d<l) c = 0.0;
	
	float s = sin(SCREEN_UV.y * scan_line_count * PI * 2.0 + (TIME * scroll_speed));
	s = (s * 0.5 + 0.5) * 0.9 + 0.1;
	vec3 scan_line = vec3(pow(s,0.55));



	
	ALBEDO = scan_line * (circle_color * 0.8);

	ALPHA = c * circle_opacity;
}

