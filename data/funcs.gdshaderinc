float random(float x,float y){
	return fract(sin(x * 1239.9898 + 78.233 + (TIME * 0.1)) * (y*2.5) - (TIME * 0.1));
}

float random2_2(float x){
	return fract(sin(x * 1239.9898 + 78.233 + (TIME * 0.1)) * 43758.0 - (TIME * 0.1));
}

float random2_1(vec2 uv){
	return fract(sin(dot(uv.xy + vec2(sin(TIME),cos(TIME)),vec2(12.9898,78.233))) * 43758.5432321);
}

float fresnel(float amount, vec3 normal,vec3 view){
	return pow((1.5 - clamp(dot(normalize(normal),normalize(view)),0.3,2.0)),amount);
}