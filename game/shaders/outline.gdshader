// Contorno nero cartoon, uniforme e compatto (D-020).
// - Lo spessore è misurato sullo schermo (frazione dell'altezza della vista): uguale per oggetti vicini e lontani,
//   grandi e piccoli, a qualsiasi risoluzione.
// - La direzione di spinta è "dal centro dell'oggetto" (radial = 1) per le forme del kit, che sono centrate:
//   così agli spigoli di casse e cilindri il guscio resta chiuso, senza buchi né pezzi staccati.
//   Per le mesh non centrate (modelli importati, ciambelle) si usa la normale liscia (radial = 0).
shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled, depth_draw_opaque;

uniform vec4 color : source_color = vec4(0.094, 0.078, 0.145, 1.0);
uniform float thickness = 0.0058;   // frazione dell'altezza della vista
uniform float radial = 1.0;

void vertex() {
	vec3 dir = normalize(mix(NORMAL, normalize(VERTEX + vec3(1e-5)), radial));
	vec4 clip = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 n_view = normalize((MODELVIEW_MATRIX * vec4(dir, 0.0)).xyz);
	vec2 n_clip = (PROJECTION_MATRIX * vec4(n_view, 0.0)).xy;
	float len = length(n_clip);
	if (len > 1e-5) {
		n_clip /= len;
		float aspect = VIEWPORT_SIZE.y / max(VIEWPORT_SIZE.x, 1.0);
		clip.xy += n_clip * vec2(aspect, 1.0) * thickness * 2.0 * clip.w;
	}
	POSITION = clip;
}

void fragment() {
	ALBEDO = color.rgb;
}
