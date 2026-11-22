shader_type canvas_item;

uniform float emp_glitch : hint_range(0.0, 1.0) = 0.0;
uniform float scanline_strength : hint_range(0.0, 0.3) = 0.08;

void fragment() {
	vec2 uv = UV;
	if (emp_glitch > 0.01) {
		float line = floor(uv.y * 120.0);
		float jitter = sin(line * 17.3 + TIME * 40.0) * 0.025 * emp_glitch;
		uv.x += jitter;
	}
	vec4 tex = texture(TEXTURE, uv);
	float scan = 1.0 - scanline_strength * (0.5 + 0.5 * sin(uv.y * 900.0));
	COLOR = vec4(tex.rgb * scan, tex.a);
}
