shader_type spatial;
uniform sampler2D texture_albedo : hint_albedo;
uniform vec4 out_color : hint_color = vec4(0, 0.317647, 0.443137, 0.584314);
uniform float amount : hint_range(0.2, 1.5) = 0.8;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform float beer_factor = 0.04;

float generate_offset(float x, float z, float val1, float val2, float time){
	float speed = 1.0;
	
	float radiansX = ((mod( x + z * x * val1, amount) / amount) + (time * speed) * mod(x * 0.8 + z, 1.5)) * 2.0 * 3.14;
	float radiansZ = ((mod(val2 * (z * x + x * z), amount) / amount) + (time * speed) * 2.0 * mod(x,2.0)) * 2.0 * 3.14;
	
	return amount * 0.5 * (sin(radiansZ) + cos(radiansX));
}

vec3 apply_distortion(vec3 vertext, float time){
	float xd = generate_offset(vertext.x, vertext.z, 0.2, 0.1, time);
	float yd = generate_offset(vertext.x, vertext.z, 0.1, 0.3, time);
	float zd = generate_offset(vertext.x, vertext.z, 0.15, 0.2, time);
	return vertext + vec3(xd,yd,zd);
}

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	VERTEX = apply_distortion(VERTEX, TIME * 0.2);
}

void fragment() {
	//METALLIC = 0.4;
	SPECULAR = 0.3;
	ROUGHNESS = 0.2;
	ALBEDO = out_color.xyz;
	
//	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
//
//	depth = depth * 2.0 - 1.0;
//	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
//	depth = depth + VERTEX.z;
//	depth = exp(-depth * beer_factor);
//	ALPHA = clamp(1.0 - depth, 0.0, 1.0);
	
}