shader_type spatial;
render_mode unshaded, shadows_disabled;
render_mode cull_disabled; 
#include "funcs.gdshaderinc"

uniform float lines1: hint_range(0.0, 200.0, 1.0) = 2.0;
instance uniform vec3 line_color: source_color = vec3(0.5,0.5,0.5);

uniform float opacity;
uniform float r =1.0;
uniform float g =1.0;
uniform float b =1.0;
instance uniform float mix_color;

void fragment() {
	float n = random2_2(SCREEN_UV.x);
	float f = fresnel(2.0,NORMAL,VIEW);
	
	float m = f*n + 0.05;
	
	ALBEDO = mix(vec3(m * line_color),vec3(r,g,b),mix_color); 
}


