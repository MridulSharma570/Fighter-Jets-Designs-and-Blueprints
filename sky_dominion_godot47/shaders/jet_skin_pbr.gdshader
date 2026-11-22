shader_type spatial;
render_mode cull_back, depth_draw_opaque;

// Metalstorm-Style Full-Body 3D Multi-Color Skin Shader (Object-Space Seamless Mapping)
uniform int pattern_type = 1; // 0=two_tone, 1=digital_pixel, 2=splinter_geo, 3=tiger_stripes, 4=gradient_ace, 5=tri_tone, 6=carbon_gold, 7=cyber_tron, 8=metallic_chrome, 9=hazard_chevron
uniform vec4 primary_color : source_color = vec4(0.24, 0.30, 0.38, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.14, 0.18, 0.24, 1.0);
uniform vec4 tertiary_color : source_color = vec4(0.45, 0.56, 0.68, 1.0);
uniform vec4 accent_color : source_color = vec4(0.92, 0.22, 0.24, 1.0);
uniform float metallic_strength : hint_range(0.0, 1.0) = 0.48;
uniform float roughness_base : hint_range(0.05, 0.95) = 0.32;
uniform float emission_strength : hint_range(0.0, 2.5) = 0.0;
uniform float pattern_scale = 1.0;

varying vec3 local_pos;
varying vec3 local_norm;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void vertex() {
	local_pos = VERTEX;
	local_norm = NORMAL;
}

void fragment() {
	// Symmetrical X + Longitudinal Z projection so liveries align seamlessly across wings, fuselage, nose, and tail
	vec2 sym_p = vec2(abs(local_pos.x), local_pos.z) * pattern_scale;
	vec3 col = primary_color.rgb;
	float em = 0.0;
	float met = metallic_strength;
	float rgh = roughness_base;

	if (pattern_type == 0) {
		// Two-tone dorsal / ventral & outer-wing contrast
		float wing_mask = smoothstep(0.9, 2.4, abs(local_pos.x));
		float belly_mask = smoothstep(0.12, -0.20, local_pos.y);
		col = mix(primary_color.rgb, secondary_color.rgb, max(wing_mask, belly_mask * 0.85));
		float stripe = step(0.92, fract(sym_p.x * 0.45));
		col = mix(col, accent_color.rgb, stripe * 0.85);
	} else if (pattern_type == 1) {
		// Digital Pixel Camouflage
		vec2 cell = floor(sym_p * 1.45);
		float h = hash21(cell);
		if (h > 0.68) col = secondary_color.rgb;
		else if (h > 0.36) col = tertiary_color.rgb;
		else if (h < 0.06) col = accent_color.rgb;
	} else if (pattern_type == 2) {
		// Geometric Stealth Splinter
		float s1 = step(0.45, fract(sym_p.x * 0.32 + sym_p.y * 0.19));
		float s2 = step(0.55, fract(sym_p.x * 0.21 - sym_p.y * 0.27));
		col = mix(primary_color.rgb, secondary_color.rgb, s1);
		col = mix(col, tertiary_color.rgb, s2 * 0.80);
		float edge_acc = smoothstep(0.04, 0.0, abs(fract(sym_p.x * 0.32 + sym_p.y * 0.19) - 0.45));
		col = mix(col, accent_color.rgb, edge_acc * 0.65);
	} else if (pattern_type == 3) {
		// Predator Tiger Stripes
		float wave = sin(sym_p.y * 2.4 + sym_p.x * 1.35 + sin(sym_p.x * 1.8) * 0.8);
		col = mix(primary_color.rgb, secondary_color.rgb, smoothstep(-0.15, 0.15, wave));
		float trim = smoothstep(0.08, 0.0, abs(wave - 0.35));
		col = mix(col, accent_color.rgb, trim * 0.75);
	} else if (pattern_type == 4) {
		// Smooth Nose-to-Tail + Wingtip Ace Gradient
		float zt = clamp((local_pos.z + 9.0) / 18.0, 0.0, 1.0);
		float xt = clamp(abs(local_pos.x) / 6.5, 0.0, 1.0);
		col = mix(primary_color.rgb, secondary_color.rgb, zt);
		col = mix(col, tertiary_color.rgb, xt * 0.72);
		col = mix(col, accent_color.rgb, smoothstep(0.84, 0.96, xt));
	} else if (pattern_type == 5) {
		// Tri-Tone Tactical (Spine, Wings, Underbelly)
		float belly = smoothstep(0.05, -0.25, local_pos.y);
		float wings = smoothstep(1.1, 2.2, abs(local_pos.x));
		col = mix(primary_color.rgb, secondary_color.rgb, wings);
		col = mix(col, tertiary_color.rgb, belly);
		float spine_line = smoothstep(0.28, 0.18, abs(local_pos.x)) * step(0.05, local_pos.y);
		col = mix(col, accent_color.rgb, spine_line * 0.45);
	} else if (pattern_type == 6) {
		// Carbon Fiber Weave + Metallic Gold/Accent Trim
		vec2 weave = step(0.5, fract(sym_p * 14.0));
		float checker = abs(weave.x - weave.y);
		col = mix(primary_color.rgb, secondary_color.rgb, checker * 0.65);
		float ace_band = smoothstep(0.18, 0.05, abs(fract(sym_p.y * 0.18) - 0.5));
		col = mix(col, accent_color.rgb, ace_band);
		met = mix(0.35, 0.92, ace_band);
		rgh = mix(0.42, 0.16, ace_band);
	} else if (pattern_type == 7) {
		// Futuristic Sci-Fi Cyber Circuit
		vec2 g = abs(fract(sym_p * 0.9) - 0.5);
		float hex_line = 1.0 - smoothstep(0.45, 0.49, max(g.x, g.y));
		float circuit = smoothstep(0.035, 0.0, abs(fract(sym_p.x * 0.4 + sym_p.y * 0.25) - 0.5));
		col = mix(primary_color.rgb, secondary_color.rgb, hex_line * 0.4);
		col = mix(col, accent_color.rgb, circuit);
		em = circuit * max(0.75, emission_strength);
	} else if (pattern_type == 8) {
		// Brushed Aerospace Metallic Chrome
		float brush = hash21(vec2(floor(sym_p.x * 40.0), floor(sym_p.y * 4.0)));
		col = mix(primary_color.rgb, tertiary_color.rgb, brush * 0.35);
		float band = smoothstep(0.08, 0.0, abs(fract(sym_p.y * 0.22) - 0.3));
		col = mix(col, accent_color.rgb, band);
		met = 0.92;
		rgh = 0.16;
	} else {
		// Hazard Chevron
		float chev = step(0.5, fract(sym_p.y * 1.4 - sym_p.x * 1.1));
		col = mix(primary_color.rgb, secondary_color.rgb, chev * 0.85);
		float warn = smoothstep(0.06, 0.0, abs(fract(sym_p.y * 0.4) - 0.2));
		col = mix(col, accent_color.rgb, warn);
	}

	// Crisp Aerospace Panel Seam Grid
	vec2 seam = abs(fract(sym_p * 0.85) - 0.5);
	float panel_edge = 1.0 - smoothstep(0.475, 0.498, max(seam.x, seam.y));
	col *= mix(0.74, 1.04, panel_edge);

	ALBEDO = col;
	METALLIC = met;
	ROUGHNESS = rgh;
	EMISSION = accent_color.rgb * em;
}
