shader_type spatial;

uniform float freq : hint_range(1.0, 100.0, 1.0) = 25.0;
uniform float ampl : hint_range(0.0, 1.0, 0.05) = 0.5;
uniform float vel : hint_range(0.0, 25.0, 0.5) = 5.0;
uniform float tightness : hint_range(0.0, 30.0, 0.1) = 20.0;
uniform bool quality_signal = false;
uniform vec4 modulate : source_color = vec4(0.0, 1.0, 0.0, 1.0);

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec2 uv = vec2((UV.x + 0.5) * freq, (UV.y + 0.5) * 0.5);
    
	float noise = cos(uv.x + TIME * random(uv));
	float res1 = abs(2.5 + noise - uv.y * 5.0);
	
	float wave = cos(uv.x + TIME * vel) * ampl;
	float res2 = abs(2.5 + wave - uv.y * 5.0);
	
	res1 = max(res1, float(quality_signal));
	
	float res = res1 * res2;
    
	float color = 1.0 - (res * tightness);
	ALBEDO =  color * modulate.rgb;
	ALPHA = modulate.a;
}
