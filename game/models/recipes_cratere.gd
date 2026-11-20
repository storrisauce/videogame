extends RefCounted
## Ricette dei modelli 3D: gruppo "cratere". Usa il kit (models/kit.gd) e le sue convenzioni di taglia e stile.


static func build(id: String) -> Node3D:
	match id:
		"mucca_laser":
			return _mucca_laser()
		"nano_da_giardino_sacro":
			return _nano_da_giardino_sacro()
		"pioggia_acida":
			return _pioggia_acida()
		"rana_a_due_teste":
			return _rana_a_due_teste()
		_:
			return null


## Raggio luminoso (cilindro senza contorno) dal punto `a` al punto `b`.
static func _beam(parent: Node3D, a: Vector3, b: Vector3, r: float, color: Color, glow: float) -> MeshInstance3D:
	var d := b - a
	var mi := Kit.cyl(parent, (a + b) * 0.5, r, d.length(), color)
	mi.quaternion = Quaternion(Vector3.UP, d.normalized())
	mi.material_override = Kit.mat(color, glow, false)
	return mi


## Mucca Laser (taglia L, ~1,8): una mucca bianca con le macchie viola, gli occhi radioattivi e due raggi laser
## che sciolgono il terreno davanti a lei. «Fa muuu. Poi scioglie qualcosa.»
static func _mucca_laser() -> Node3D:
	var n := Kit.root("mucca_laser")
	var white := Art.c("ferro_6")
	var spot := Art.c("viola_2")
	Kit.legs4(n, 0.9, 1.2, 0.5, white, 0.11)
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			Kit.cyl(n, Vector3(sx * 0.27, 0.06, sz * 0.36), 0.125, 0.12, Art.c("inchiostro"))   # zoccoli
	Kit.blob(n, Vector3(0, 0.88, -0.12), Vector3(1.0, 0.82, 1.4), white)                   # corpo
	# macchie viola sui fianchi e sul dorso
	Kit.blob(n, Vector3(0.44, 0.95, -0.3), Vector3(0.14, 0.36, 0.42), spot)
	Kit.blob(n, Vector3(-0.44, 0.85, 0.05), Vector3(0.14, 0.3, 0.32), spot)
	Kit.blob(n, Vector3(-0.1, 1.27, -0.45), Vector3(0.36, 0.08, 0.3), spot)
	Kit.blob(n, Vector3(0, 0.5, -0.1), Vector3(0.28, 0.16, 0.24), Art.c("rosa_4"))          # mammella
	# testa grande con muso rosa
	var hy := 1.3
	var hz := 0.68
	Kit.blob(n, Vector3(0, hy, hz), Vector3(0.72, 0.64, 0.6), white)
	Kit.blob(n, Vector3(0.17, hy + 0.11, hz + 0.2), Vector3(0.28, 0.26, 0.16), spot)       # macchia sull'occhio
	Kit.blob(n, Vector3(0, hy - 0.2, hz + 0.27), Vector3(0.58, 0.32, 0.3), Art.c("rosa_4"))
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.1, hy - 0.18, hz + 0.42), Vector3(0.06, 0.08, 0.03), Art.c("rosa_1"))
		Kit.blob(n, Vector3(sx * 0.42, hy + 0.08, hz - 0.08), Vector3(0.24, 0.1, 0.14), white, Vector3(0, 0, sx * -0.4))   # orecchie
		Kit.cone(n, Vector3(sx * 0.24, hy + 0.36, hz - 0.08), 0.06, 0.2, Art.c("legno_9"), Vector3(0, 0, sx * -0.6))    # corna
	# occhi mutanti che sparano: pupilla radio che brilla
	var eye_l := Vector3(-0.16, hy + 0.1, hz + 0.27)
	var eye_r := Vector3(0.16, hy + 0.1, hz + 0.27)
	var look := Vector3(0.3, -0.5, 1)
	Kit.eye(n, eye_l, 0.115, look, true)
	Kit.eye(n, eye_r, 0.115, look, true)
	for sx in [-1.0, 1.0]:   # sopracciglia cattive
		Kit.box(n, Vector3(sx * 0.16, hy + 0.24, hz + 0.31), Vector3(0.17, 0.04, 0.04), Art.c("inchiostro"), Vector3(0, 0, sx * 0.4))
	# due raggi che convergono sul terreno davanti e la chiazza sciolta e fumante
	var hit := Vector3(0.48, 0.03, 0.95)
	var po := look.normalized() * 0.08
	_beam(n, eye_l + po, hit, 0.03, Art.c("radio_2"), 3.0)
	_beam(n, eye_r + po, hit, 0.03, Art.c("radio_2"), 3.0)
	Kit.blob(n, hit, Vector3(0.34, 0.04, 0.26), Art.c("radio_1"), Vector3.ZERO, 2.4)
	Kit.blob(n, hit + Vector3(0.04, 0.16, 0), Vector3(0.12, 0.1, 0.12), Art.c("ferro_5"))
	Kit.blob(n, hit + Vector3(0.1, 0.3, -0.02), Vector3(0.08, 0.07, 0.08), Art.c("ferro_6"))
	# coda con il ciuffo
	Kit.cyl(n, Vector3(0.05, 0.9, -0.84), 0.025, 0.4, white, Vector3(0.4, 0, 0))
	Kit.blob(n, Vector3(0.05, 0.7, -0.92), Vector3(0.09, 0.14, 0.09), spot)
	return n


## Nano da Giardino Sacro (struttura, ~1,25): un nano da giardino di gesso su un piedistallo di pietra, con
## l'aureola che brilla, due candele e gli occhi fissi su chi gioca. «Pregatelo. Lui vi guarda. Sempre.»
static func _nano_da_giardino_sacro() -> Node3D:
	var n := Kit.root("nano_da_giardino_sacro", -0.2)
	var stone := Art.c("ferro_4")
	# piedistallo a due gradini
	Kit.box(n, Vector3(0, 0.08, 0), Vector3(0.8, 0.16, 0.8), Art.c("ferro_3"))
	Kit.box(n, Vector3(0, 0.25, 0), Vector3(0.6, 0.18, 0.6), stone)
	Kit.box(n, Vector3(0, 0.25, 0.305), Vector3(0.3, 0.06, 0.01), Art.c("giallo_1"))     # targhetta
	# candele sul gradino davanti
	for sx in [-1.0, 1.0]:
		Kit.cyl(n, Vector3(sx * 0.3, 0.24, 0.3), 0.04, 0.16, Art.c("legno_9"))
		Kit.blob(n, Vector3(sx * 0.3, 0.36, 0.3), Vector3(0.045, 0.08, 0.045), Art.c("arancio_4"), Vector3.ZERO, 2.2)
	var b := 0.34   # base del nano
	# stivaletti e corpo (giacca blu, cintura)
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.1, b + 0.04, 0.05), Vector3(0.14, 0.09, 0.2), Art.c("legno_2"))
	Kit.blob(n, Vector3(0, b + 0.2, 0), Vector3(0.44, 0.4, 0.4), Art.c("acqua_2"))
	Kit.cyl(n, Vector3(0, b + 0.15, 0), 0.215, 0.06, Art.c("legno_1"))
	Kit.box(n, Vector3(0, b + 0.15, 0.21), Vector3(0.08, 0.07, 0.02), Art.c("giallo_2"))
	# mani giunte in preghiera
	Kit.blob(n, Vector3(0, b + 0.27, 0.2), Vector3(0.1, 0.12, 0.08), Art.c("pelle_4"))
	# testa: faccia, barba bianca a punta, nasone, occhi fissi
	var hy := b + 0.5
	Kit.blob(n, Vector3(0, hy, 0.02), Vector3(0.4, 0.34, 0.34), Art.c("pelle_4"))
	Kit.cone(n, Vector3(0, hy - 0.16, 0.1), 0.17, 0.26, Art.c("bianco"), Vector3(PI - 0.25, 0, 0))
	Kit.blob(n, Vector3(0, hy - 0.03, 0.19), Vector3(0.1, 0.09, 0.09), Art.c("pelle_1"))
	Kit.eyes(n, Vector3(0, hy + 0.06, 0.14), 0.15, 0.055, Vector3(0, 0, 1))
	# cappello rosso a punta, piegato
	Kit.cone(n, Vector3(0, hy + 0.24, -0.04), 0.21, 0.34, Art.c("rosso_2"), Vector3(-0.25, 0, 0.12))
	# aureola dorata che brilla
	Kit.torus(n, Vector3(0, hy + 0.44, -0.12), 0.15, 0.2, Art.c("giallo_2"), Vector3(0.35, 0, 0)).material_override = Kit.mat(Art.c("giallo_2"), 1.8)
	return n


## Pioggia Acida (evento, ~1,7): una nuvola viola arrabbiata che piove gocce radioattive su una pozzanghera
## che brilla. «Prendete l'ombrello. Anzi, no.»
static func _pioggia_acida() -> Node3D:
	var n := Kit.root("pioggia_acida", -0.2)
	var cloud := Art.c("viola_3")
	var cy := 1.35
	# nuvola a sbuffi
	Kit.blob(n, Vector3(0, cy, 0), Vector3(0.8, 0.55, 0.6), cloud)
	Kit.blob(n, Vector3(-0.42, cy - 0.06, 0), Vector3(0.5, 0.4, 0.5), cloud)
	Kit.blob(n, Vector3(0.42, cy - 0.04, 0), Vector3(0.52, 0.44, 0.5), cloud)
	Kit.blob(n, Vector3(-0.16, cy + 0.24, -0.05), Vector3(0.44, 0.38, 0.44), cloud)
	Kit.blob(n, Vector3(0.22, cy + 0.2, -0.05), Vector3(0.4, 0.36, 0.4), cloud)
	Kit.blob(n, Vector3(0, cy - 0.2, 0.02), Vector3(1.0, 0.18, 0.5), Art.c("viola_1"))   # pancia scura
	# faccia arrabbiata: occhi, sopracciglia a V, bocca storta
	Kit.eyes(n, Vector3(0, cy + 0.04, 0.27), 0.26, 0.08, Vector3(0, -0.3, 1))
	for sx in [-1.0, 1.0]:
		Kit.box(n, Vector3(sx * 0.14, cy + 0.16, 0.31), Vector3(0.16, 0.04, 0.03), Art.c("inchiostro"), Vector3(0, 0, sx * 0.45))
	Kit.box(n, Vector3(0, cy - 0.12, 0.29), Vector3(0.16, 0.035, 0.03), Art.c("inchiostro"), Vector3(0, 0, 0.15))
	# gocce che cadono (allungate, luminose)
	var drops := [Vector3(-0.42, 0.85, 0.05), Vector3(-0.15, 0.6, 0.12), Vector3(0.12, 0.9, -0.05),
		Vector3(0.38, 0.55, 0.08), Vector3(-0.3, 0.35, -0.08), Vector3(0.2, 0.28, 0.15)]
	for d: Vector3 in drops:
		Kit.blob(n, d, Vector3(0.1, 0.12, 0.1), Art.c("radio_1"), Vector3.ZERO, 2.2)
		Kit.cone(n, d + Vector3(0, 0.09, 0), 0.042, 0.1, Art.c("radio_1")).material_override = Kit.mat(Art.c("radio_1"), 2.2)
	# pozzanghera che brilla, con un anello di schizzo
	Kit.blob(n, Vector3(0, 0.015, 0.05), Vector3(1.0, 0.03, 0.6), Art.c("radio_2"), Vector3.ZERO, 1.4)
	Kit.torus(n, Vector3(0.2, 0.03, 0.15), 0.06, 0.1, Art.c("radio_1"))
	return n


## Rana a Due Teste (taglia S/M, ~0,9): una rana verde tozza con due teste che si danno le spalle e guardano
## in direzioni opposte, una offesa e una annoiata. «Le due teste non si parlano.»
static func _rana_a_due_teste() -> Node3D:
	var n := Kit.root("rana_a_due_teste", -0.15)
	var green := Art.c("verde_4")
	var dark := Art.c("verde_2")
	var belly := Art.c("verde_5")
	# cosce piegate ai lati e zampe palmate
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.32, 0.17, -0.12), Vector3(0.24, 0.3, 0.46), green, Vector3(0, sx * 0.3, 0))
		Kit.blob(n, Vector3(sx * 0.4, 0.03, 0.1), Vector3(0.2, 0.06, 0.24), dark)
		Kit.cyl(n, Vector3(sx * 0.17, 0.12, 0.2), 0.045, 0.24, green, Vector3(0, 0, sx * 0.2))   # braccini
		Kit.blob(n, Vector3(sx * 0.19, 0.02, 0.25), Vector3(0.14, 0.04, 0.14), dark)
	# corpo a pera con la pancia chiara
	Kit.blob(n, Vector3(0, 0.3, -0.05), Vector3(0.62, 0.52, 0.62), green)
	Kit.blob(n, Vector3(0, 0.26, 0.17), Vector3(0.42, 0.36, 0.2), belly)
	Kit.radio_spot(n, Vector3(0, 0.55, -0.1), 0.06)        # dove si biforca il collo
	# due teste, ciascuna girata dalla sua parte
	for sx in [-1.0, 1.0]:
		var h := Node3D.new()
		h.position = Vector3(sx * 0.2, 0.6, 0.0)
		h.rotation = Vector3(0, sx * 0.6, sx * -0.18)
		n.add_child(h)
		Kit.blob(h, Vector3(0, 0, 0.04), Vector3(0.36, 0.26, 0.38), green)
		# occhi sporgenti in cima alla testa, che guardano ancora più in fuori
		for ex in [-1.0, 1.0]:
			Kit.blob(h, Vector3(ex * 0.1, 0.11, 0.06), Vector3(0.14, 0.12, 0.14), green)
			Kit.eye(h, Vector3(ex * 0.1, 0.15, 0.1), 0.065, Vector3(sx * 0.5, 0, 1))
		# bocca larga, una storta (offesa) e una dritta (annoiata)
		Kit.box(h, Vector3(0, -0.04, 0.23), Vector3(0.2, 0.025, 0.02), Art.c("inchiostro"), Vector3(0, 0, sx * 0.18))
	return n
