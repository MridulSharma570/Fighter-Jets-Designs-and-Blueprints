shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_opaque;

uniform vec4 core_color : source_color = vec4(0.4, 0.9, 1.0, 1.0);
uniform vec4 outer_color : source_color = vec4(1.0, 0.45, 0.12, 1.0);
uniform float intensity : hint_range(0.0, 3.0) = 1.2;
uniform float mach_diamonds : hint_range(1.0, 10.0) = 6.0;

void fragment() {
	float v = UV.y;
	float pulse = 0.85 + 0.15 * sin(TIME * 48.0 + v * 12.0);
	float diamond = pow(abs(sin(v * mach_diamonds * 3.14159)), 3.0);
	vec3 col = mix(outer_color.rgb, core_color.rgb, diamond * (1.0 - v));
	float fade = smoothstep(1.0, 0.05, v) * smoothstep(0.0, 0.08, v);
	ALBEDO = col * intensity * pulse * (1.4 + diamond);
	ALPHA = fade * clamp(intensity, 0.15, 1.0);
}
