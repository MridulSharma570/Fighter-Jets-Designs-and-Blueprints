shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_never;

uniform vec4 xray_color : source_color = vec4(0.12, 0.88, 1.0, 1.0);
uniform float rim_power : hint_range(0.5, 5.0) = 2.0;
uniform float grid_scale : hint_range(1.0, 30.0) = 8.0;

varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	float fresnel = pow(1.0 - abs(dot(NORMAL, VIEW)), rim_power);
	float grid_x = abs(fract(local_pos.x * grid_scale) - 0.5);
	float grid_z = abs(fract(local_pos.z * grid_scale) - 0.5);
	float line = step(0.45, max(grid_x, grid_z));
	ALBEDO = xray_color.rgb * (0.45 + fresnel * 1.4 + line * 0.65);
	ALPHA = clamp(0.16 + fresnel * 0.68 + line * 0.25, 0.12, 0.92);
}
