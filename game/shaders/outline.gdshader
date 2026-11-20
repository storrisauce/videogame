// Contorno nero cartoon, uniforme e compatto (D-020).
// - Lo spessore è misurato sullo schermo (frazione dell'altezza della vista): uguale per oggetti vicini e lontani,
//   grandi e piccoli, a qualsiasi risoluzione.
// - Il guscio si gonfia lungo la normale MEDIA del vertice, salvata nel colore dei vertici da Kit.prepare_outlines:
//   agli spigoli di casse, cilindri e modelli low-poly il guscio resta chiuso, senza buchi né pezzi staccati.
// - La normale passa per la matrice delle normali: anche le forme schiacciate o allungate (paletti, zampe)
//   hanno il contorno sui lati, non solo in punta.
shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled, depth_draw_opaque;

uniform vec4 color : source_color = vec4(0.094, 0.078, 0.145, 1.0);
uniform float thickness = 0.0058;   // frazione dell'altezza della vista

void vertex() {
	vec3 dir = COLOR.rgb * 2.0 - 1.0;
	if (dot(dir, dir) < 0.01) {
		dir = NORMAL;
	}
	vec4 clip = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 n_view = normalize(MODELVIEW_NORMAL_MATRIX * normalize(dir));
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
