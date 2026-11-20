// Ombre a gradini (3 livelli) per lo stile cartoon low-poly (strada A). Colore pieno o texture a palette.
shader_type spatial;
render_mode cull_back, specular_disabled;

uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D albedo_tex : source_color, filter_nearest, repeat_enable;
uniform bool use_tex = false;
uniform vec4 emission : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_energy = 0.0;   // > 1 fa scattare il bagliore (bloom) solo dove serve
instance uniform float flash = 0.0;    // lampo bianco quando la creatura viene colpita (per singolo oggetto)
instance uniform float dim = 0.0;      // scurito quando la creatura è inerme

void fragment() {
	vec3 c = albedo.rgb;
	if (use_tex) {
		c *= texture(albedo_tex, UV).rgb;
	}
	c = mix(c, vec3(1.0), flash) * (1.0 - dim * 0.45);
	ALBEDO = c;
	ROUGHNESS = 1.0;
	EMISSION = emission.rgb * emission_energy + vec3(flash * 1.4);
}

uniform float rim_amount = 0.9;        // bordo di luce sulle sagome (luci da dietro)

void light() {
	float ndl = dot(NORMAL, LIGHT);
	float a = ATTENUATION;
	float band = a > 0.55 ? 1.0 : (a > 0.22 ? 0.62 : (a > 0.05 ? 0.3 : 0.0));
	// Una luce che arriva da dietro (verso la telecamera) non illumina le facce che vediamo: disegna solo
	// un bordo netto sulle sagome, come nei cartoni (rim light). Le altre luci danno le ombre a gradini.
	float back = dot(LIGHT, -VIEW);
	if (back > 0.3) {
		float fres = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
		float rim = step(0.55, fres) * step(-0.25, ndl) * band;
		DIFFUSE_LIGHT += rim * rim_amount * LIGHT_COLOR / 3.14159;
	} else {
		// ombre a gradini sia sull'angolo della luce sia sulla distanza (pozze di luce a "cerchi")
		float lit = ndl > 0.45 ? 1.0 : (ndl > 0.05 ? 0.62 : 0.3);
		DIFFUSE_LIGHT += lit * band * LIGHT_COLOR / 3.14159;
	}
}
