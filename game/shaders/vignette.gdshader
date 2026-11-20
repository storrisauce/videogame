// Angoli scuri morbidi, tinta blu notte del bunker.
shader_type canvas_item;

uniform float strength = 0.6;
uniform vec4 tint : source_color = vec4(0.035, 0.025, 0.09, 1.0);

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= 1.5;
	float d = length(uv);
	float v = smoothstep(0.42, 0.98, d);
	COLOR = vec4(tint.rgb, v * strength);
}
