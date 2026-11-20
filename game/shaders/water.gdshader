// Acqua cartoon dello stagno: due toni di azzurro, increspature chiare che scorrono piano, bordo di schiuma.
shader_type spatial;
render_mode cull_back, specular_disabled, unshaded;

uniform vec4 deep : source_color = vec4(0.0, 0.6, 0.86, 1.0);
uniform vec4 shallow : source_color = vec4(0.2, 0.72, 0.91, 1.0);
uniform vec4 foam : source_color = vec4(0.87, 0.95, 1.0, 1.0);
uniform float speed = 1.0;   // 0 = ferma (Meno movimento)

varying vec3 lp;

void vertex() {
	lp = VERTEX;   // disco di raggio 0,5 (scalato dal nodo)
}

void fragment() {
	vec2 p = (lp.xz + 0.5) * vec2(5.0, 7.0);
	float t = TIME * 0.35 * speed;
	// due onde che si incrociano: dove si sommano nasce una lineetta chiara
	float w = sin(p.x * 2.1 + t * 2.0 + sin(p.y * 1.3 + t)) + sin(p.y * 2.6 - t * 1.6 + cos(p.x * 1.7));
	vec3 c = mix(deep.rgb, shallow.rgb, step(0.2, w));
	c = mix(c, foam.rgb, step(1.55, w));
	// schiuma sul bordo (UV del disco: distanza dal centro)
	float r = length(lp.xz) * 2.0;
	c = mix(c, foam.rgb, step(0.93, r));
	ALBEDO = c * 0.92;
}
