extends RefCounted
## Ricette dei modelli 3D: gruppo "eroi" (i sei sopravvissuti). Usa il kit (models/kit.gd) e le sue convenzioni.
## Ritratti grandi negli angoli del tavolo e nel menu: facce e oggetti devono leggersi anche a ~100 px.


static func build(id: String) -> Node3D:
	match id:
		"nonna":
			return _nonna()
		"gianni":
			return _gianni()
		"trattore":
			return _trattore()
		"veterinario":
			return _veterinario()
		"cane":
			return _cane()
		"speaker":
			return _speaker()
		_:
			return null


# --- aiuti privati -------------------------------------------------------------------------------

## Cilindro da `a` a `b` (braccia, canne, tubi).
static func _limb(n: Node3D, a: Vector3, b: Vector3, r: float, color: Color, top := -1.0) -> MeshInstance3D:
	var d := b - a
	var dir := d.normalized()
	var q := Quaternion(Vector3.UP, dir) if dir.dot(Vector3.UP) > -0.999 else Quaternion(Vector3.RIGHT, PI)
	return Kit.cyl(n, (a + b) / 2.0, r, d.length(), color, Basis(q).get_euler(), top)


## Braccio con mano tonda in fondo.
static func _arm(n: Node3D, a: Vector3, b: Vector3, r: float, sleeve: Color, skin: Color) -> void:
	_limb(n, a, b, r, sleeve)
	Kit.blob(n, b, Vector3.ONE * r * 2.6, skin)


## Gambe corte con scarpe.
static func _legs(n: Node3D, gap: float, h: float, leg: Color, shoe: Color, r := 0.055) -> void:
	Kit.legs2(n, gap, h, leg, r)
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * gap / 2.0, 0.04, 0.04), Vector3(r * 2.6, 0.08, r * 3.4), shoe)


## Sopracciglio: barretta inclinata (`tilt` positivo = esterno in alto).
static func _brow(n: Node3D, pos: Vector3, w: float, color: Color, tilt: float) -> void:
	Kit.box(n, pos, Vector3(w, 0.028, 0.03), color, Vector3(0, 0, tilt))


# --- ricette -------------------------------------------------------------------------------------

## La Nonna col Fucile (~1,3): crocchia grigia, occhialoni, grembiule a fiori e doppietta cartoon.
## «Fuori dal mio orto!»
static func _nonna() -> Node3D:
	var n := Kit.root("nonna")
	var skin := Art.c("pelle_4")
	var dress := Art.c("viola_2")
	var hair := Art.c("ferro_5")
	_legs(n, 0.18, 0.2, Art.c("legno_6"), Art.c("legno_1"))
	Kit.cyl(n, Vector3(0, 0.38, 0), 0.24, 0.42, dress, Vector3.ZERO, 0.19)                  # vestito a campana
	Kit.blob(n, Vector3(0, 0.58, 0), Vector3(0.4, 0.2, 0.34), dress)                         # spalle
	Kit.box(n, Vector3(0, 0.36, 0.205), Vector3(0.3, 0.34, 0.03), Art.c("legno_9"), Vector3(-0.08, 0, 0))   # grembiule
	for p in [Vector3(-0.07, 0.42, 0.225), Vector3(0.08, 0.32, 0.225), Vector3(-0.05, 0.25, 0.225)]:
		Kit.blob(n, p, Vector3(0.05, 0.05, 0.02), Art.c("rosso_3"))                          # fiorellini
	# testa
	Kit.blob(n, Vector3(0, 0.88, 0.02), Vector3(0.5, 0.48, 0.44), skin)
	Kit.blob(n, Vector3(0, 0.98, -0.05), Vector3(0.54, 0.38, 0.44), hair)                   # capelli
	Kit.blob(n, Vector3(0, 1.18, -0.08), Vector3(0.24, 0.2, 0.22), hair)                    # crocchia
	Kit.cyl(n, Vector3(0.0, 1.2, -0.08), 0.008, 0.3, Art.c("legno_2"), Vector3(0, 0, 1.2))   # forcina
	Kit.blob(n, Vector3(0, 0.84, 0.25), Vector3(0.09, 0.08, 0.08), Art.c("pelle_2"))        # naso
	Kit.eyes(n, Vector3(0, 0.9, 0.2), 0.18, 0.05, Vector3(0.15, 0, 1))
	for sx in [-0.09, 0.09]:
		Kit.torus(n, Vector3(sx, 0.9, 0.25), 0.065, 0.085, Art.c("ferro_1"), Vector3(PI / 2.0, 0, 0))   # occhiali
	Kit.box(n, Vector3(0, 0.91, 0.26), Vector3(0.05, 0.02, 0.02), Art.c("ferro_1"))
	_brow(n, Vector3(-0.09, 1.0, 0.24), 0.11, hair, -0.35)                                   # cipiglio
	_brow(n, Vector3(0.09, 1.0, 0.24), 0.11, hair, 0.35)
	Kit.box(n, Vector3(0, 0.76, 0.22), Vector3(0.12, 0.025, 0.03), Art.c("rosa_1"), Vector3(0, 0, 0.1))   # bocca storta
	# doppietta tenuta di traverso
	var stock := Art.c("legno_4")
	var steel := Art.c("ferro_2")
	_limb(n, Vector3(-0.22, 0.34, 0.3), Vector3(0.0, 0.48, 0.3), 0.055, stock, 0.045)       # calcio
	Kit.box(n, Vector3(0.02, 0.49, 0.3), Vector3(0.1, 0.07, 0.08), steel, Vector3(0, 0, 0.6))   # bascula
	for dz in [-0.022, 0.022]:
		_limb(n, Vector3(0.04, 0.51, 0.3 + dz), Vector3(0.42, 0.78, 0.3 + dz), 0.022, steel)   # due canne
	Kit.box(n, Vector3(0.24, 0.63, 0.3), Vector3(0.16, 0.05, 0.07), stock, Vector3(0, 0, 0.62))  # astina
	_arm(n, Vector3(-0.18, 0.58, 0.02), Vector3(-0.06, 0.45, 0.3), 0.055, dress, skin)
	_arm(n, Vector3(0.18, 0.58, 0.02), Vector3(0.24, 0.62, 0.32), 0.055, dress, skin)
	return n


## Contadino Gianni in Mutande (~1,2): canottiera, boxer a pois, cappello di paglia, faccia confusa e un «?».
## «Oggi è lunedì?»
static func _gianni() -> Node3D:
	var n := Kit.root("gianni")
	var skin := Art.c("pelle_3")
	var shirt := Art.c("bianco")
	var boxers := Art.c("rosso_2")
	_legs(n, 0.2, 0.22, skin, Art.c("legno_4"), 0.05)
	Kit.cyl(n, Vector3(0, 0.27, 0), 0.22, 0.14, boxers)                                      # mutande
	for p in [Vector3(-0.1, 0.28, 0.2), Vector3(0.08, 0.25, 0.21), Vector3(0.15, 0.3, 0.15), Vector3(-0.17, 0.25, 0.12)]:
		Kit.blob(n, p, Vector3(0.05, 0.05, 0.03), Art.c("bianco"))                            # pois
	Kit.blob(n, Vector3(0, 0.46, 0.02), Vector3(0.48, 0.42, 0.44), shirt)                   # canottiera e pancia
	Kit.blob(n, Vector3(0, 0.66, 0.0), Vector3(0.22, 0.08, 0.2), skin)                       # collo/scollo
	# testa
	Kit.blob(n, Vector3(0, 0.88, 0.02), Vector3(0.5, 0.46, 0.44), skin)
	Kit.blob(n, Vector3(0, 0.82, 0.25), Vector3(0.1, 0.1, 0.1), Art.c("pelle_1"))           # naso a patata
	Kit.eye(n, Vector3(-0.1, 0.92, 0.2), 0.06, Vector3(-0.5, 0.4, 1))                        # occhi storti
	Kit.eye(n, Vector3(0.1, 0.9, 0.2), 0.045, Vector3(0.5, -0.2, 1))
	_brow(n, Vector3(-0.1, 1.02, 0.22), 0.1, Art.c("legno_2"), -0.4)                        # un sopracciglio su
	_brow(n, Vector3(0.1, 0.98, 0.22), 0.1, Art.c("legno_2"), 0.0)
	Kit.blob(n, Vector3(0.03, 0.74, 0.22), Vector3(0.05, 0.06, 0.03), Art.c("legno_0"))    # bocca a «o»
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.25, 0.88, 0.0), Vector3(0.07, 0.1, 0.06), skin)           # orecchie
	# cappello di paglia
	var straw := Art.c("giallo_1")
	Kit.cyl(n, Vector3(0, 1.06, -0.01), 0.36, 0.03, straw, Vector3(-0.12, 0, 0.1))
	Kit.cyl(n, Vector3(0, 1.13, -0.02), 0.17, 0.13, straw, Vector3(-0.12, 0, 0.1), 0.15)
	Kit.cyl(n, Vector3(0, 1.09, -0.02), 0.175, 0.035, Art.c("rosso_1"), Vector3(-0.12, 0, 0.1))
	# braccia: una gratta la testa
	_arm(n, Vector3(-0.2, 0.56, 0.02), Vector3(-0.3, 0.3, 0.08), 0.05, skin, skin)
	_limb(n, Vector3(0.2, 0.56, 0.02), Vector3(0.36, 0.8, 0.02), 0.05, skin)
	_arm(n, Vector3(0.36, 0.8, 0.02), Vector3(0.24, 1.0, 0.0), 0.05, skin, skin)
	# punto di domanda che fluttua
	var q := Art.c("giallo_2")
	var qo := Vector3(-0.42, 1.12, 0.1)
	var pts := [Vector3(-0.09, 0.12, 0), Vector3(-0.06, 0.22, 0), Vector3(0.03, 0.26, 0),
		Vector3(0.1, 0.19, 0), Vector3(0.07, 0.09, 0), Vector3(0.0, 0.04, 0), Vector3(0.0, -0.04, 0)]
	for i in pts.size() - 1:
		_limb(n, qo + pts[i], qo + pts[i + 1], 0.03, q)
		Kit.blob(n, qo + pts[i + 1], Vector3.ONE * 0.06, q)
	Kit.blob(n, qo + Vector3(0, -0.13, 0), Vector3.ONE * 0.075, q)
	return n


## Il Trattore Senziente (~1,4, largo): fari-occhi, griglia-bocca, fascia tricolore da sindaco.
## «Ordinanza del sindaco»
static func _trattore() -> Node3D:
	var n := Kit.root("trattore", -0.45)
	var red := Art.c("rosso_2")
	var dark := Art.c("rosso_1")
	var tyre := Art.c("notte")
	var hub := Art.c("giallo_2")
	# ruote: grandi dietro, piccole davanti (asse lungo x)
	for sx in [-1.0, 1.0]:
		Kit.cyl(n, Vector3(sx * 0.42, 0.36, -0.22), 0.36, 0.2, tyre, Vector3(0, 0, PI / 2.0))
		Kit.cyl(n, Vector3(sx * 0.53, 0.36, -0.22), 0.16, 0.02, hub, Vector3(0, 0, PI / 2.0))
		Kit.cyl(n, Vector3(sx * 0.33, 0.2, 0.36), 0.2, 0.16, tyre, Vector3(0, 0, PI / 2.0))
		Kit.cyl(n, Vector3(sx * 0.41, 0.2, 0.36), 0.09, 0.02, hub, Vector3(0, 0, PI / 2.0))
	Kit.box(n, Vector3(0, 0.37, 0.18), Vector3(0.5, 0.3, 0.56), red)                     # cofano
	Kit.box(n, Vector3(0, 0.55, -0.24), Vector3(0.62, 0.62, 0.42), red)                   # cabina
	Kit.box(n, Vector3(0, 0.89, -0.24), Vector3(0.66, 0.06, 0.46), dark)                   # tetto
	for sx in [-1.0, 1.0]:
		Kit.cyl(n, Vector3(sx * 0.28, 1.0, -0.24), 0.025, 0.2, Art.c("ferro_2"))            # paletti del tettuccio
	Kit.box(n, Vector3(0, 1.12, -0.24), Vector3(0.7, 0.05, 0.5), Art.c("giallo_1"))        # tettuccio
	# faccia sul cofano
	Kit.box(n, Vector3(0, 0.3, 0.465), Vector3(0.38, 0.12, 0.02), Art.c("ferro_1"))       # griglia-bocca
	for i in 4:
		Kit.box(n, Vector3(-0.135 + i * 0.09, 0.3, 0.48), Vector3(0.035, 0.09, 0.02), Art.c("ferro_5"))   # denti
	for sx in [-1.0, 1.0]:
		Kit.cyl(n, Vector3(sx * 0.14, 0.44, 0.46), 0.085, 0.04, Art.c("ferro_3"), Vector3(PI / 2.0, 0, 0))   # cornice faro
		Kit.eye(n, Vector3(sx * 0.14, 0.44, 0.47), 0.07, Vector3(0.15, 0.1, 1))
		_brow(n, Vector3(sx * 0.14, 0.555, 0.465), 0.13, Art.c("notte"), sx * -0.25)        # sopracciglia autoritarie
	# marmitta con fumetto radioattivo
	Kit.cyl(n, Vector3(0.17, 0.75, 0.3), 0.035, 0.44, Art.c("ferro_2"))
	Kit.blob(n, Vector3(0.19, 1.12, 0.3), Vector3(0.14, 0.11, 0.14), Art.c("radio_2"), Vector3.ZERO, 1.6)
	Kit.blob(n, Vector3(0.26, 1.24, 0.28), Vector3(0.1, 0.08, 0.1), Art.c("radio_2"), Vector3.ZERO, 1.6)
	# fascia tricolore sulla cabina (diagonale)
	var cols := [Art.c("verde_3"), Art.c("bianco"), Art.c("rosso_1")]
	for i in 3:
		var off := (i - 1) * 0.07
		Kit.box(n, Vector3(off * 0.7, 0.6 - off * 0.7, -0.24), Vector3(0.07, 0.9, 0.44), cols[i], Vector3(0, 0, -0.8))
	Kit.cyl(n, Vector3(-0.17, 0.72, -0.015), 0.07, 0.03, Art.c("giallo_2"), Vector3(PI / 2.0, 0, 0))   # medaglia
	return n


## Il Veterinario Terrorizzato (~1,4, il più alto): magro, camice bianco, stetoscopio, siringone di siero verde.
## «Stai fermo, ti prego»
static func _veterinario() -> Node3D:
	var n := Kit.root("veterinario")
	var skin := Art.c("pelle_5")
	var coat := Art.c("ferro_6")
	var hair := Art.c("legno_1")
	_legs(n, 0.14, 0.34, Art.c("ferro_1"), Art.c("notte"), 0.045)
	Kit.cyl(n, Vector3(0, 0.5, 0), 0.17, 0.42, coat, Vector3.ZERO, 0.14)                    # camice lungo e stretto
	Kit.box(n, Vector3(0, 0.5, 0.155), Vector3(0.015, 0.4, 0.02), Art.c("ferro_4"))          # abbottonatura
	Kit.box(n, Vector3(0.07, 0.54, 0.15), Vector3(0.07, 0.06, 0.02), Art.c("ferro_4"))       # taschino
	Kit.cyl(n, Vector3(0, 0.75, 0), 0.05, 0.1, skin)                                         # collo lungo
	# testa
	Kit.blob(n, Vector3(0, 1.0, 0.02), Vector3(0.44, 0.48, 0.4), skin)
	for i in 5:
		var a := -0.7 + i * 0.35
		Kit.cone(n, Vector3(sin(a) * 0.14, 1.24, -0.02), 0.06, 0.2, hair, Vector3(0.0, 0, -a * 0.9))   # capelli dritti
	Kit.blob(n, Vector3(0, 1.17, -0.04), Vector3(0.44, 0.18, 0.38), hair)
	Kit.eyes(n, Vector3(0, 1.03, 0.19), 0.16, 0.075, Vector3(0.25, 0.1, 1))                  # occhi sbarrati
	for sx in [-1.0, 1.0]:
		_brow(n, Vector3(sx * 0.08, 1.14, 0.2), 0.08, hair, sx * -0.5)                        # sopracciglia preoccupate
	Kit.blob(n, Vector3(0, 0.84, 0.19), Vector3(0.1, 0.07, 0.04), Art.c("legno_0"))          # bocca tremante
	Kit.blob(n, Vector3(0.22, 1.1, 0.08), Vector3(0.05, 0.08, 0.05), Art.c("acqua_5"))      # goccia di sudore
	# stetoscopio
	Kit.torus(n, Vector3(0, 0.71, 0.0), 0.08, 0.1, Art.c("ferro_1"), Vector3(0.25, 0, 0))
	_limb(n, Vector3(-0.07, 0.68, 0.1), Vector3(-0.07, 0.5, 0.16), 0.012, Art.c("ferro_1"))
	Kit.cyl(n, Vector3(-0.07, 0.48, 0.17), 0.035, 0.02, Art.c("ferro_4"), Vector3(PI / 2.0, 0, 0))
	# siringone tenuto con le due mani, puntato avanti
	var a := Vector3(-0.1, 0.55, 0.24)
	var b := Vector3(0.28, 0.7, 0.36)
	var d := (b - a).normalized()
	_limb(n, a, b, 0.06, Art.c("radio_1")).material_override = Kit.mat(Art.c("radio_1"), 1.6)   # siero verde
	for t in [0.0, 1.0]:
		Kit.cyl(n, a.lerp(b, t), 0.072, 0.03, Art.c("ferro_6"), Basis(Quaternion(Vector3.UP, d)).get_euler())   # ghiere
	for t in [0.3, 0.5, 0.7]:
		Kit.cyl(n, a.lerp(b, t), 0.064, 0.012, Art.c("ferro_2"), Basis(Quaternion(Vector3.UP, d)).get_euler())  # tacche
	_limb(n, b, b + d * 0.06, 0.03, Art.c("ferro_6"), 0.015)
	_limb(n, b + d * 0.06, b + d * 0.2, 0.01, Art.c("ferro_4"))                                       # ago
	_limb(n, a - d * 0.1, a, 0.015, Art.c("ferro_4"))                                        # stantuffo
	Kit.cyl(n, a - d * 0.1, 0.05, 0.015, Art.c("ferro_4"), Basis(Quaternion(Vector3.UP, d)).get_euler())
	_arm(n, Vector3(-0.15, 0.68, 0.0), a + d * 0.05 + Vector3(0, -0.03, 0), 0.04, coat, skin)
	_arm(n, Vector3(0.15, 0.68, 0.0), a + d * 0.2 + Vector3(0, -0.05, 0), 0.04, coat, skin)
	return n


## Il Cane da Pastore che Ha Visto Troppo (~0,8): seduto, sguardo perso nel vuoto, un orecchio piegato, peli grigi.
## «Raduno.»
static func _cane() -> Node3D:
	var n := Kit.root("cane")
	var fur := Art.c("legno_3")
	var light := Art.c("legno_9")
	var grey := Art.c("ferro_5")
	# corpo seduto
	Kit.blob(n, Vector3(0, 0.17, -0.12), Vector3(0.44, 0.3, 0.42), fur)                     # cosce
	Kit.blob(n, Vector3(0, 0.34, 0.0), Vector3(0.36, 0.48, 0.32), fur, Vector3(-0.3, 0, 0))   # busto
	Kit.blob(n, Vector3(0, 0.36, 0.13), Vector3(0.24, 0.32, 0.14), light, Vector3(-0.3, 0, 0))   # petto chiaro
	for sx in [-1.0, 1.0]:
		Kit.cyl(n, Vector3(sx * 0.09, 0.12, 0.12), 0.045, 0.24, fur)                         # zampe davanti
		Kit.blob(n, Vector3(sx * 0.09, 0.025, 0.15), Vector3(0.1, 0.05, 0.13), light)
		Kit.blob(n, Vector3(sx * 0.19, 0.05, -0.02), Vector3(0.1, 0.07, 0.18), fur)          # zampe dietro
	Kit.cone(n, Vector3(0.0, 0.1, -0.36), 0.05, 0.28, fur, Vector3(-1.9, 0, 0))              # coda a terra
	# testa
	Kit.blob(n, Vector3(0, 0.62, 0.04), Vector3(0.4, 0.36, 0.36), fur)
	Kit.blob(n, Vector3(0, 0.56, 0.22), Vector3(0.2, 0.15, 0.2), light)                      # muso
	Kit.blob(n, Vector3(0, 0.6, 0.32), Vector3(0.07, 0.05, 0.05), Art.c("inchiostro"))      # tartufo
	Kit.box(n, Vector3(0, 0.51, 0.3), Vector3(0.08, 0.015, 0.02), Art.c("legno_0"))         # bocca piatta
	for p in [Vector3(-0.05, 0.53, 0.29), Vector3(0.06, 0.54, 0.29), Vector3(0.0, 0.5, 0.28)]:
		Kit.blob(n, p, Vector3(0.035, 0.035, 0.025), grey)                                   # peli grigi sul muso
	# occhi persi nel vuoto: palpebre a metà, pupille piccole dritte avanti, occhiaie
	for sx in [-1.0, 1.0]:
		var ep := Vector3(sx * 0.085, 0.67, 0.18)
		Kit.eye(n, ep, 0.052, Vector3(0, 0, 1))
		Kit.blob(n, ep + Vector3(0, 0.025, 0.006), Vector3(0.115, 0.06, 0.1), Art.c("legno_2"))   # palpebra
		Kit.blob(n, ep + Vector3(0, -0.05, 0.0), Vector3(0.1, 0.03, 0.06), Art.c("viola_1"))      # occhiaia
		Kit.blob(n, ep + Vector3(sx * 0.0, 0.07, 0.0), Vector3(0.07, 0.03, 0.05), grey)          # sopracciglio grigio
	# orecchie: sinistra dritta, destra piegata
	Kit.cone(n, Vector3(-0.13, 0.82, 0.0), 0.07, 0.18, Art.c("legno_1"), Vector3(-0.1, 0, 0.25))
	Kit.cone(n, Vector3(0.14, 0.81, 0.0), 0.07, 0.1, Art.c("legno_1"), Vector3(-0.1, 0, -0.25))
	Kit.cone(n, Vector3(0.2, 0.83, 0.06), 0.06, 0.12, Art.c("legno_1"), Vector3(0.6, 0, -2.0))   # punta piegata
	Kit.blob(n, Vector3(-0.05, 0.79, 0.06), Vector3(0.08, 0.04, 0.06), grey)                 # ciuffo grigio
	Kit.radio_spot(n, Vector3(0.14, 0.42, -0.06), 0.05)
	return n


## Lo Speaker della Radio (~1,2): cuffie, microfono gigante, baffoni, camicia hawaiana sgargiante, bocca spalancata.
## «Notizia dell'ultima ora!»
static func _speaker() -> Node3D:
	var n := Kit.root("speaker")
	var skin := Art.c("pelle_3")
	var shirt := Art.c("acqua_5")
	var hair := Art.c("inchiostro")
	_legs(n, 0.2, 0.2, Art.c("ferro_1"), Art.c("legno_1"))
	Kit.blob(n, Vector3(0, 0.42, 0), Vector3(0.5, 0.48, 0.42), shirt)                       # camicia
	for p in [Vector3(-0.12, 0.5, 0.19), Vector3(0.1, 0.36, 0.2), Vector3(0.15, 0.55, 0.14), Vector3(-0.16, 0.32, 0.15), Vector3(0.0, 0.25, 0.18)]:
		Kit.blob(n, p, Vector3(0.08, 0.08, 0.03), Art.c("rosa_4"))                            # fiori
		Kit.blob(n, p + Vector3(0, 0, 0.012), Vector3(0.03, 0.03, 0.02), Art.c("giallo_2"))
	Kit.box(n, Vector3(0, 0.62, 0.16), Vector3(0.12, 0.08, 0.04), Art.c("arancio_2"), Vector3(0.3, 0, 0))   # colletto
	# testa
	Kit.blob(n, Vector3(0, 0.88, 0.02), Vector3(0.5, 0.46, 0.44), skin)
	Kit.blob(n, Vector3(0, 1.04, -0.04), Vector3(0.46, 0.2, 0.4), hair, Vector3(0, 0, 0.1))     # capelli impomatati
	Kit.blob(n, Vector3(0.1, 1.08, 0.12), Vector3(0.2, 0.1, 0.12), hair, Vector3(0, 0, -0.3))  # ciuffo
	Kit.eyes(n, Vector3(0, 0.93, 0.2), 0.17, 0.055, Vector3(0.1, 0.05, 1))
	for sx in [-1.0, 1.0]:
		_brow(n, Vector3(sx * 0.085, 1.01, 0.21), 0.09, hair, sx * 0.3)                       # sopracciglia alzate
	Kit.blob(n, Vector3(0, 0.86, 0.25), Vector3(0.09, 0.08, 0.08), Art.c("pelle_1"))        # naso
	Kit.blob(n, Vector3(0, 0.74, 0.2), Vector3(0.14, 0.1, 0.06), Art.c("legno_0"))         # bocca spalancata
	Kit.blob(n, Vector3(0, 0.72, 0.215), Vector3(0.08, 0.04, 0.04), Art.c("rosso_3"))       # lingua
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.08, 0.8, 0.24), Vector3(0.15, 0.06, 0.07), hair, Vector3(0, 0, sx * -0.35))   # baffoni
	# cuffie
	var arc: Array[Vector3] = []
	for i in 7:
		var t := PI * i / 6.0
		arc.append(Vector3(-cos(t) * 0.27, 0.9 + sin(t) * 0.27, -0.02))
	for i in 6:
		_limb(n, arc[i], arc[i + 1], 0.025, Art.c("ferro_1"))
	for sx in [-1.0, 1.0]:
		Kit.cyl(n, Vector3(sx * 0.26, 0.88, 0.0), 0.09, 0.08, Art.c("rosso_2"), Vector3(0, 0, PI / 2.0))
	# microfono gigante in mano
	var mic_top := Vector3(0.2, 0.74, 0.34)
	_limb(n, Vector3(0.24, 0.42, 0.28), mic_top + Vector3(0, -0.06, 0), 0.03, Art.c("notte"))   # manico
	Kit.blob(n, mic_top, Vector3(0.15, 0.17, 0.15), Art.c("ferro_4"))                        # griglia
	Kit.cyl(n, mic_top + Vector3(0, -0.07, 0), 0.06, 0.04, Art.c("rosso_2"))                  # anello
	_arm(n, Vector3(0.2, 0.56, 0.02), Vector3(0.24, 0.52, 0.28), 0.05, shirt, skin)
	_arm(n, Vector3(-0.2, 0.56, 0.02), Vector3(-0.36, 0.7, 0.1), 0.05, shirt, skin)          # braccio che gesticola
	return n
