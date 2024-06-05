shader_type spatial;
render_mode unshaded, shadows_disabled;

#include "funcs.gdshaderinc"

uniform float lines1: hint_range(0.0, 200.0, 1.0) = 2.0;
uniform vec3 line_color: source_color = vec3(0.1,0.4,0.2);

void fragment() {

	float n = random2_1(SCREEN_UV);
	float f = fresnel(2.0,NORMAL,VIEW);
	
	float m = f*n + 0.05;
	
	ALBEDO = vec3(m * line_color); 
}




