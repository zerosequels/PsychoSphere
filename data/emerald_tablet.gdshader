shader_type spatial;
uniform float scan_line_count: hint_range(0,1080) = 100.0;
uniform vec3 line_color: source_color = vec3(1,1,1);
uniform float scroll_speed: hint_range(0.0, 50.0, 1) = 10;
uniform float n: hint_range(0.0,1.0,0.1) = 0.8;

void fragment() {
	float s = sin(SCREEN_UV.y * scan_line_count * PI * 2.0 + (TIME * scroll_speed));
	s = (s * 0.5 + 0.5) * 0.9 + 0.1;
	vec3 scan_line = vec3(pow(s,0.25));
	
	ALBEDO = scan_line * line_color + (NORMAL * n);

}
