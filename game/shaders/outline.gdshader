// Contorno nero a "guscio rovesciato": la stessa mesh un po' gonfiata, vista da dietro.
shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled;

uniform vec4 color : source_color = vec4(0.094, 0.078, 0.145, 1.0);
uniform float width = 0.035;

void vertex() {
	VERTEX += NORMAL * width;
}

void fragment() {
	ALBEDO = color.rgb;
}
