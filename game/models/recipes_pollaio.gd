extends RefCounted
## Ricette dei modelli 3D: gruppo "pollaio". Usa il kit (models/kit.gd) e le sue convenzioni di taglia e stile.
## Taglie relative: pulcino ~0,45 · gallina ~0,8 · gallo ~1,0 · tacchino ~1,25 · silos ~1,8.


static func build(id: String) -> Node3D:
	match id:
		"pulcino_mitragliere":
			return _pulcino()
		"gallina_uova_bomba":
			return _gallina()
		"gallo_sentinella":
			return _gallo()
		"tacchino_furioso":
			return _tacchino()
		"silos_instabile":
			return _silos()
		_:
			return null


const _FRONT := Vector3(PI / 2.0, 0, 0)   # rotazione che porta la punta di un cono (o l'asse di un cilindro) verso +Z


## Becco: cono che punta verso +Z.
static func _beak(n: Node3D, pos: Vector3, r: float, l: float, color: Color, tilt := 0.0) -> void:
	Kit.cone(n, pos, r, l, color, Vector3(PI / 2.0 + tilt, 0, 0))


## Cresta: tre palline in fila sulla testa (da davanti a dietro).
static func _comb(n: Node3D, pos: Vector3, s: float, color: Color) -> void:
	Kit.blob(n, pos + Vector3(0, 0, s * 0.55), Vector3(s * 0.5, s * 0.75, s * 0.6), color)
	Kit.blob(n, pos + Vector3(0, s * 0.18, 0), Vector3(s * 0.55, s * 0.95, s * 0.65), color)
	Kit.blob(n, pos + Vector3(0, 0, -s * 0.55), Vector3(s * 0.5, s * 0.75, s * 0.6), color)


## Sopracciglio arrabbiato: barretta nera inclinata verso il centro.
static func _brow(n: Node3D, pos: Vector3, w: float, side: float) -> void:
	Kit.box(n, pos, Vector3(w, w * 0.28, w * 0.25), Art.c("inchiostro"), Vector3(0, 0, side * 0.45))


## Uovo-bomba: uovo nero con miccia accesa che brilla.
static func _bomb_egg(n: Node3D, pos: Vector3, s: float, rot := Vector3.ZERO) -> void:
	var e := Node3D.new()
	e.position = pos
	e.rotation = rot
	n.add_child(e)
	Kit.blob(e, Vector3.ZERO, Vector3(0.8, 1.0, 0.8) * s, Art.c("notte"))
	Kit.blob(e, Vector3(-0.17, 0.2, 0.25) * s, Vector3(0.14, 0.22, 0.08) * s, Art.c("ferro_3"))   # riflesso
	Kit.cyl(e, Vector3(0, 0.53, 0) * s, 0.13 * s, 0.1 * s, Art.c("ferro_2"))                     # tappo
	Kit.cyl(e, Vector3(0.05, 0.68, 0) * s, 0.035 * s, 0.22 * s, Art.c("legno_8"), Vector3(0, 0, -0.45))  # miccia
	Kit.blob(e, Vector3(0.11, 0.8, 0) * s, Vector3(0.2, 0.2, 0.2) * s, Art.c("arancio_4"), Vector3.ZERO, 2.8)  # scintilla
	Kit.blob(e, Vector3(0.11, 0.8, 0) * s, Vector3(0.1, 0.32, 0.1) * s, Art.c("giallo_2"), Vector3(0, 0, 0.6), 3.0)


## Pulcino Mitragliere (minuscolo, ~0,45): palla gialla con il mitra in braccio e la cartucciera a tracolla.
## «Pio. Ratatatà. Pio.»
static func _pulcino() -> Node3D:
	var n := Kit.root("pulcino_mitragliere", -0.3)
	var yel := Art.c("giallo_2")
	var yel2 := Art.c("arancio_4")
	var org := Art.c("arancio_2")
	Kit.legs2(n, 0.1, 0.07, org, 0.022)
	for sx in [-0.05, 0.05]:
		Kit.box(n, Vector3(sx, 0.012, 0.035), Vector3(0.06, 0.024, 0.08), org)          # piedini
	Kit.blob(n, Vector3(0, 0.2, 0), Vector3(0.36, 0.3, 0.34), yel)                       # corpo
	Kit.blob(n, Vector3(0, 0.33, 0.03), Vector3(0.3, 0.27, 0.28), yel)                   # testa
	for i in 3:
		Kit.cone(n, Vector3((i - 1) * 0.03, 0.47, 0.02), 0.025, 0.08, yel2, Vector3(-0.2, 0, (1 - i) * 0.5))   # ciuffo
	Kit.eyes(n, Vector3(0, 0.36, 0.14), 0.12, 0.055, Vector3(0.1, -0.05, 1))
	_brow(n, Vector3(-0.065, 0.42, 0.16), 0.07, -1.0)
	_brow(n, Vector3(0.065, 0.42, 0.16), 0.07, 1.0)
	_beak(n, Vector3(0, 0.3, 0.19), 0.035, 0.07, org)
	# mitra tenuto all'altezza del petto, canna verso chi guarda
	var g := Node3D.new()
	g.position = Vector3(0.09, 0.2, 0.2)
	g.rotation = Vector3(-0.1, 0.12, 0)
	n.add_child(g)
	Kit.box(g, Vector3(0, 0, 0), Vector3(0.09, 0.09, 0.2), Art.c("ferro_1"))                # castello
	Kit.cyl(g, Vector3(0, 0.01, 0.15), 0.045, 0.12, Art.c("ferro_2"), _FRONT)                 # manicotto
	Kit.cyl(g, Vector3(0, 0.01, 0.25), 0.022, 0.1, Art.c("ferro_3"), _FRONT)                  # canna
	Kit.cyl(g, Vector3(0, 0.01, 0.3), 0.032, 0.025, Art.c("inchiostro"), _FRONT)             # bocca
	Kit.box(g, Vector3(0, -0.07, -0.04), Vector3(0.04, 0.08, 0.04), Art.c("legno_4"), Vector3(0.3, 0, 0))   # impugnatura
	Kit.box(g, Vector3(0.07, -0.01, 0.0), Vector3(0.05, 0.1, 0.06), Art.c("ferro_3"))       # caricatore di lato
	# nastro di proiettili che pende dal mitra fino a terra
	for i in 5:
		var t := float(i) / 4.0
		var bp := Vector3(-0.07 - t * 0.06, -0.03 - t * 0.15, 0.06 - t * t * 0.05)
		Kit.box(g, bp, Vector3(0.035, 0.03, 0.015), Art.c("legno_3"), Vector3(0, 0, 0.3 + t * 0.6))
		Kit.cyl(g, bp + Vector3(0, 0, 0.03), 0.012, 0.05, Art.c("arancio_4"), _FRONT)
	# alucce che stringono il mitra
	Kit.blob(n, Vector3(-0.15, 0.21, 0.07), Vector3(0.08, 0.13, 0.15), yel2, Vector3(0.6, 0, 0.5))
	Kit.blob(n, Vector3(0.05, 0.16, 0.2), Vector3(0.08, 0.1, 0.12), yel2, Vector3(0.3, 0, -0.9))
	Kit.radio_spot(n, Vector3(-0.12, 0.3, -0.08), 0.035)
	return n


## Gallina Uova-Bomba (~0,8): chioccia covata sul nido, con uova-bomba nere dalla miccia accesa.
## «Non chiederle la frittata.»
static func _gallina() -> Node3D:
	var n := Kit.root("gallina_uova_bomba")
	var body := Art.c("legno_7")
	var dark := Art.c("legno_5")
	var red := Art.c("rosso_2")
	Kit.torus(n, Vector3(0, 0.08, 0), 0.22, 0.42, Art.c("legno_9"), Vector3.ZERO)      # nido di paglia
	Kit.cyl(n, Vector3(0, 0.05, 0), 0.3, 0.08, Art.c("legno_8"))
	for i in 7:
		var a := i * TAU / 7.0 + 0.2
		Kit.box(n, Vector3(sin(a) * 0.32, 0.17, cos(a) * 0.32), Vector3(0.14, 0.025, 0.025), Art.c("legno_7"), Vector3(0.0, a + 1.2, 0.25))
	Kit.blob(n, Vector3(0, 0.36, -0.05), Vector3(0.6, 0.5, 0.62), body)                 # corpo
	Kit.blob(n, Vector3(0, 0.35, 0.18), Vector3(0.42, 0.38, 0.3), Art.c("legno_8"))      # petto chiaro
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.27, 0.38, -0.05), Vector3(0.12, 0.3, 0.42), dark, Vector3(0.2, 0, sx * 0.15))   # ali
	for i in 3:
		Kit.blob(n, Vector3((i - 1) * 0.07, 0.55, -0.33), Vector3(0.1, 0.32, 0.1), dark, Vector3(-0.6, 0, (i - 1) * 0.35))   # coda
	Kit.blob(n, Vector3(0, 0.66, 0.16), Vector3(0.3, 0.3, 0.28), body)                   # testa
	_comb(n, Vector3(0, 0.83, 0.15), 0.1, red)
	Kit.eyes(n, Vector3(0, 0.7, 0.27), 0.13, 0.055, Vector3(0.15, 0, 1))
	_beak(n, Vector3(0, 0.63, 0.33), 0.04, 0.08, Art.c("arancio_3"))
	Kit.blob(n, Vector3(0, 0.56, 0.29), Vector3(0.06, 0.09, 0.05), red)                  # bargiglio
	# palpebre a mezz'asta: sguardo furbo
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.065, 0.73, 0.28), Vector3(0.12, 0.05, 0.08), dark)
	# uova-bomba nel nido
	_bomb_egg(n, Vector3(0.2, 0.25, 0.33), 0.26, Vector3(0.15, 0, -0.2))
	_bomb_egg(n, Vector3(-0.2, 0.22, 0.34), 0.21, Vector3(0.2, 0, 0.3))
	Kit.radio_spot(n, Vector3(0.22, 0.5, -0.15), 0.05)
	return n


## Gallo Sentinella (~1,0): gallo impettito con elmetto militare e un manico di scopa come fucile in spalla.
## «Canta all'alba. E a mezzanotte. E quando vede un'ombra.»
static func _gallo() -> Node3D:
	var n := Kit.root("gallo_sentinella", -0.3)
	var body := Art.c("ruggine_2")
	var chest := Art.c("arancio_3")
	var tail := Art.c("verde_0")
	var red := Art.c("rosso_2")
	var leg := Art.c("arancio_4")
	Kit.legs2(n, 0.16, 0.2, leg, 0.035)
	for sx in [-0.08, 0.08]:
		Kit.box(n, Vector3(sx, 0.015, 0.05), Vector3(0.09, 0.03, 0.14), leg)
	Kit.blob(n, Vector3(0, 0.39, -0.04), Vector3(0.44, 0.4, 0.48), body)                 # corpo
	Kit.blob(n, Vector3(0, 0.43, 0.12), Vector3(0.32, 0.36, 0.22), chest)                # petto in fuori
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.21, 0.44, -0.04), Vector3(0.1, 0.24, 0.32), Art.c("ruggine_1"), Vector3(0.15, 0, sx * 0.1))   # ali
	# coda alta a falce
	for i in 4:
		var a := -0.5 + i * 0.33
		Kit.blob(n, Vector3(sin(a) * 0.08, 0.64 + cos(a) * 0.05, -0.3), Vector3(0.08, 0.42, 0.09), tail, Vector3(-0.45, 0, -a * 0.7))
	Kit.cyl(n, Vector3(0, 0.66, 0.06), 0.1, 0.22, body)                                   # collo
	Kit.blob(n, Vector3(0, 0.82, 0.08), Vector3(0.27, 0.27, 0.27), body)                 # testa
	# elmetto militare
	Kit.blob(n, Vector3(0, 0.93, 0.06), Vector3(0.34, 0.24, 0.34), Art.c("verde_1"))
	Kit.cyl(n, Vector3(0, 0.9, 0.07), 0.21, 0.025, Art.c("verde_1"))
	Kit.box(n, Vector3(0, 0.96, 0.22), Vector3(0.06, 0.03, 0.02), Art.c("giallo_1"))   # mostrina
	Kit.blob(n, Vector3(0, 0.89, -0.15), Vector3(0.05, 0.12, 0.1), red)                 # cresta che spunta dietro
	Kit.blob(n, Vector3(0, 0.83, -0.16), Vector3(0.045, 0.08, 0.08), red)
	Kit.eyes(n, Vector3(0, 0.81, 0.19), 0.12, 0.05, Vector3(0.35, 0, 1))                # occhiata di lato: sospettoso
	_brow(n, Vector3(-0.055, 0.865, 0.22), 0.07, -1.0)
	_brow(n, Vector3(0.055, 0.865, 0.22), 0.07, 1.0)
	_beak(n, Vector3(0, 0.75, 0.24), 0.04, 0.09, Art.c("arancio_4"))
	Kit.blob(n, Vector3(0, 0.7, 0.18), Vector3(0.06, 0.1, 0.05), red)                    # bargiglio
	# manico di scopa in spalla (fucile da sentinella)
	Kit.cyl(n, Vector3(0.25, 0.6, 0.0), 0.022, 0.75, Art.c("legno_4"), Vector3(0.25, 0, -0.1))
	Kit.cyl(n, Vector3(0.28, 0.97, -0.09), 0.03, 0.06, Art.c("ferro_3"), Vector3(0.25, 0, -0.1))   # punta di latta
	Kit.blob(n, Vector3(0.23, 0.48, 0.05), Vector3(0.1, 0.16, 0.12), Art.c("ruggine_1"))         # ala che lo stringe
	return n


## Tacchino Furioso (M, ~1,25): tacchino rabbioso con la ruota spiegata, il fumo dalla testa e una forchetta piantata nella coda.
## «Ha saltato il pranzo delle feste. Non lo perdona.»
static func _tacchino() -> Node3D:
	var n := Kit.root("tacchino_furioso")
	var body := Art.c("legno_3")
	var dark := Art.c("legno_1")
	var leg := Art.c("arancio_3")
	Kit.legs2(n, 0.2, 0.2, leg, 0.045)
	for sx in [-0.1, 0.1]:
		Kit.box(n, Vector3(sx, 0.02, 0.06), Vector3(0.11, 0.04, 0.17), leg)
	# ruota della coda, a ventaglio dietro al corpo
	var colors := [Art.c("legno_4"), Art.c("legno_7"), Art.c("legno_4"), Art.c("ruggine_2")]
	var cen := Vector3(0, 0.45, -0.3)
	var k := 9
	for i in k:
		var a := -1.35 + i * 2.7 / (k - 1)
		var d := Vector3(sin(a), cos(a), 0)
		Kit.blob(n, cen + d * 0.42, Vector3(0.24, 0.72, 0.07), colors[i % colors.size()], Vector3(-0.15, 0, -a))
		Kit.blob(n, cen + d * 0.7 + Vector3(0, 0, 0.04), Vector3(0.15, 0.13, 0.04), Art.c("legno_9"), Vector3(0, 0, -a))   # punta chiara
	# forchetta piantata nella ruota
	var fork := Node3D.new()
	fork.position = Vector3(0.36, 0.88, -0.26)
	fork.rotation = Vector3(0.35, 0, -0.7)
	n.add_child(fork)
	Kit.cyl(fork, Vector3(0, 0.16, 0), 0.022, 0.28, Art.c("ferro_5"))
	Kit.box(fork, Vector3(0, 0.0, 0), Vector3(0.1, 0.035, 0.025), Art.c("ferro_5"))
	for sx in [-0.04, 0.0, 0.04]:
		Kit.cyl(fork, Vector3(sx, -0.06, 0), 0.011, 0.12, Art.c("ferro_5"))
	# corpo
	Kit.blob(n, Vector3(0, 0.5, 0), Vector3(0.62, 0.58, 0.6), body)
	Kit.blob(n, Vector3(0, 0.48, 0.2), Vector3(0.44, 0.46, 0.26), dark)                  # petto scuro
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.3, 0.48, 0.0), Vector3(0.12, 0.34, 0.42), Art.c("legno_2"), Vector3(0.1, 0, sx * 0.2))   # ali a pugno
	# collo e testa nuda
	Kit.cyl(n, Vector3(0, 0.84, 0.15), 0.09, 0.22, Art.c("ferro_5"), Vector3(0.2, 0, 0), 0.07)
	Kit.blob(n, Vector3(0, 1.0, 0.2), Vector3(0.28, 0.27, 0.27), Art.c("ferro_5"))
	Kit.eyes(n, Vector3(0, 1.02, 0.31), 0.13, 0.055, Vector3(0, -0.15, 1))
	_brow(n, Vector3(-0.065, 1.08, 0.34), 0.09, -1.0)
	_brow(n, Vector3(0.065, 1.08, 0.34), 0.09, 1.0)
	_beak(n, Vector3(0, 0.96, 0.36), 0.04, 0.09, Art.c("giallo_1"), 0.15)
	# caruncola rossa che pende sul becco e bargigli
	Kit.blob(n, Vector3(0.04, 0.93, 0.39), Vector3(0.045, 0.14, 0.045), Art.c("rosso_2"), Vector3(0, 0, 0.2))
	Kit.blob(n, Vector3(0, 0.86, 0.3), Vector3(0.1, 0.14, 0.08), Art.c("rosso_2"))
	# guance rosse di rabbia
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.11, 0.96, 0.28), Vector3(0.06, 0.04, 0.03), Art.c("rosso_4"))
	# sbuffi di fumo dalla testa
	Kit.blob(n, Vector3(-0.13, 1.18, 0.16), Vector3(0.12, 0.1, 0.1), Art.c("ferro_6"))
	Kit.blob(n, Vector3(-0.2, 1.27, 0.14), Vector3(0.15, 0.13, 0.13), Art.c("ferro_6"))
	Kit.blob(n, Vector3(0.13, 1.18, 0.16), Vector3(0.12, 0.1, 0.1), Art.c("ferro_6"))
	Kit.blob(n, Vector3(0.21, 1.28, 0.14), Vector3(0.16, 0.14, 0.14), Art.c("ferro_6"))
	Kit.radio_spot(n, Vector3(-0.22, 0.62, 0.12), 0.06)
	return n


## Silos Instabile (struttura, ~1,8): silos di lamiera ondulata che pende, cupola rossa, cartello di pericolo,
## crepa verde che brilla e una trave che lo tiene su a fatica.
## «Vietato fumare. Vietato respirare forte.»
static func _silos() -> Node3D:
	var n := Kit.root("silos_instabile", -0.25)
	var metal := Art.c("ferro_4")
	Kit.box(n, Vector3(0, 0.05, 0), Vector3(0.8, 0.1, 0.8), Art.c("ferro_2"))            # basamento
	var s := Node3D.new()                                                                 # tutto il silos pende
	s.position = Vector3(0, 0.1, 0)
	s.rotation = Vector3(0.05, 0, -0.13)
	n.add_child(s)
	Kit.cyl(s, Vector3(0, 0.62, 0), 0.3, 1.24, metal)
	for i in 5:                                                                            # lamiera ondulata
		Kit.torus(s, Vector3(0, 0.12 + i * 0.25, 0), 0.29, 0.325, Art.c("ferro_3"))
	Kit.blob(s, Vector3(0, 1.24, 0), Vector3(0.66, 0.5, 0.66), Art.c("rosso_2"))         # cupola
	Kit.cyl(s, Vector3(0, 1.24, 0), 0.33, 0.04, Art.c("rosso_1"))
	Kit.cyl(s, Vector3(0, 1.52, 0), 0.04, 0.1, Art.c("ferro_2"))                          # sfiatatoio
	Kit.cone(s, Vector3(0, 1.6, 0), 0.08, 0.07, Art.c("rosso_1"))
	# toppe di ruggine
	Kit.box(s, Vector3(-0.2, 0.35, 0.22), Vector3(0.14, 0.12, 0.02), Art.c("ruggine_2"), Vector3(0, -0.75, 0))
	Kit.box(s, Vector3(0.22, 0.95, 0.2), Vector3(0.1, 0.1, 0.02), Art.c("ruggine_3"), Vector3(0, 0.8, 0.2))
	# crepa radioattiva a zig-zag sul davanti
	var crack := [Vector3(0.06, 0.25, 0.31), Vector3(-0.02, 0.42, 0.31), Vector3(0.05, 0.58, 0.31), Vector3(-0.03, 0.74, 0.31)]
	for i in crack.size() - 1:
		var a: Vector3 = crack[i]
		var b: Vector3 = crack[i + 1]
		var d := b - a
		Kit.box(s, (a + b) / 2.0, Vector3(0.04, d.length() + 0.03, 0.02), Art.c("radio_1"), Vector3(0, 0, -atan2(d.x, d.y)), 2.6)
	Kit.blob(s, Vector3(0.0, 0.5, 0.33), Vector3(0.05, 0.05, 0.04), Art.c("radio_2"), Vector3.ZERO, 3.0)   # goccia che cola
	# cartello di pericolo a rombo
	Kit.box(s, Vector3(0.0, 1.0, 0.31), Vector3(0.22, 0.22, 0.02), Art.c("giallo_2"), Vector3(0, 0, PI / 4.0))
	Kit.box(s, Vector3(0.0, 1.03, 0.325), Vector3(0.03, 0.09, 0.01), Art.c("inchiostro"))
	Kit.box(s, Vector3(0.0, 0.95, 0.325), Vector3(0.03, 0.03, 0.01), Art.c("inchiostro"))
	# scaletta sul fianco
	for sz in [-0.07, 0.07]:
		Kit.cyl(s, Vector3(-0.31, 0.6, sz), 0.012, 1.1, Art.c("ferro_2"))
	for i in 6:
		Kit.box(s, Vector3(-0.31, 0.15 + i * 0.18, 0), Vector3(0.02, 0.015, 0.15), Art.c("ferro_2"))
	# trave di legno che lo puntella (dal lato verso cui pende)
	Kit.box(n, Vector3(0.6, 0.52, 0.12), Vector3(0.08, 1.02, 0.08), Art.c("legno_5"), Vector3(0, 0, 0.3))
	Kit.box(n, Vector3(0.75, 0.05, 0.12), Vector3(0.16, 0.1, 0.14), Art.c("legno_3"))     # zeppa
	return n
