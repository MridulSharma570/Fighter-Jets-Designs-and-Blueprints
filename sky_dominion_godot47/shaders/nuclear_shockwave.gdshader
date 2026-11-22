shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;

uniform vec4 shock_color : source_color = vec4(1.0, 0.78, 0.32, 1.0);
uniform float power : hint_range(0.0, 10.0) = 4.5;

void fragment() {
	float fresnel = pow(1.0 - abs(dot(NORMAL, VIEW)), 2.2);
	ALBEDO = shock_color.rgb * power * (0.6 + fresnel);
	ALPHA = clamp(fresnel * 0.9, 0.05, 0.92);
}
