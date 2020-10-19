shader_type spatial;
uniform float TimeScale;
render_mode unshaded, cull_disabled;
 
varying vec4 varying_color;

void vertex() {
	float time = TIME * TimeScale;
	float angle = time + VERTEX.z;
	float y = VERTEX.y + 0.2*cos(angle);
	mat2 twist_matrix = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
	VERTEX.y = y;
	VERTEX.xy = twist_matrix * VERTEX.xy;
	varying_color = COLOR;
}
 
void fragment() {
// Output:0
	ALBEDO = varying_color.rgb;
	ALPHA = varying_color.a;
}
 
void light() {
// Output:0
 
}