extends RefCounted
## Ricette dei modelli 3D: gruppo "discarica". Usa il kit (models/kit.gd) e le sue convenzioni di taglia e stile.


static func build(id: String) -> Node3D:
	match id:
		"procione_con_lo_scolapasta":
			return _procione()
		"capra_baratto":
			return _capra()
		"ratto_accumulatore":
			return _ratto()
		"gazza_armaiola":
			return _gazza()
		"baracca_di_copertoni":
			return _baracca()
		"hai_preso_tu_l_apriscatole":
			return _apriscatole()
		_:
			return null


## Cilindro tra due punti (code, manici, forchette, punti di domanda).
static func _seg(parent: Node3D, a: Vector3, b: Vector3, r: float, color: Color, top := -1.0) -> MeshInstance3D:
	var d := b - a
	var mi := Kit.cyl(parent, (a + b) / 2.0, r, d.length(), color, Vector3.ZERO, top)
	var y := d.normalized()
	var ref := Vector3.FORWARD if absf(y.dot(Vector3.FORWARD)) < 0.9 else Vector3.RIGHT
	var x := ref.cross(y).normalized()
	var z := x.cross(y).normalized()
	mi.basis = Basis(x, y, z)
	return mi


## Procione con lo Scolapasta (taglia S, ~0,85): procione seduto, mascherina nera, scolapasta in testa, coda ad anelli.
## «Ha trovato un elmo. E una lasagna vecchissima.»
static func _procione() -> Node3D:
	var n := Kit.root("procione_con_lo_scolapasta")
	var fur := Art.c("ferro_3")
	var dark := Art.c("ferro_1")
	var light := Art.c("ferro_6")
	var metal := Art.c("arancio_3")
	# zampe posteriori (seduto) e anteriori
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.17, 0.07, 0.08), Vector3(0.16, 0.12, 0.26), dark)
		Kit.cyl(n, Vector3(sx * 0.12, 0.2, 0.17), 0.05, 0.22, dark, Vector3(0.25, 0, 0))
	Kit.blob(n, Vector3(0, 0.27, -0.02), Vector3(0.5, 0.5, 0.42), fur)                    # corpo a pera
	Kit.blob(n, Vector3(0, 0.27, 0.12), Vector3(0.3, 0.34, 0.2), light)                   # pancia chiara
	Kit.blob(n, Vector3(0, 0.58, 0.06), Vector3(0.5, 0.4, 0.4), fur)                      # testa grande
	Kit.blob(n, Vector3(0, 0.56, 0.17), Vector3(0.44, 0.13, 0.22), Art.c("notte"))        # mascherina
	Kit.blob(n, Vector3(0, 0.5, 0.22), Vector3(0.2, 0.14, 0.2), light)                    # muso bianco
	Kit.blob(n, Vector3(0, 0.52, 0.32), Vector3(0.06, 0.045, 0.04), Art.c("inchiostro"))  # naso
	Kit.eyes(n, Vector3(0, 0.58, 0.25), 0.18, 0.055, Vector3(0.15, 0.05, 1))
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.2, 0.72, 0.02), Vector3(0.12, 0.13, 0.06), fur)       # orecchie (sporgono dallo scolapasta)
	# scolapasta: cupola di metallo con buchi e due manici
	Kit.blob(n, Vector3(0, 0.72, 0.04), Vector3(0.44, 0.26, 0.42), metal)
	Kit.cyl(n, Vector3(0, 0.7, 0.04), 0.225, 0.04, Art.c("arancio_1"))                    # bordo
	for p in [Vector3(-0.1, 0.79, 0.19), Vector3(0.0, 0.8, 0.21), Vector3(0.1, 0.79, 0.19), Vector3(-0.05, 0.84, 0.13), Vector3(0.05, 0.84, 0.13), Vector3(-0.17, 0.77, 0.1), Vector3(0.17, 0.77, 0.1)]:
		Kit.blob(n, p, Vector3(0.035, 0.035, 0.035), Art.c("inchiostro"))
	for sx in [-1.0, 1.0]:
		Kit.torus(n, Vector3(sx * 0.25, 0.71, 0.04), 0.025, 0.05, Art.c("arancio_1"), Vector3(0, 0, PI / 2.0))
	# coda ad anelli che sale dietro
	var pts := [Vector3(0, 0.12, -0.2), Vector3(0.12, 0.18, -0.34), Vector3(0.24, 0.3, -0.38), Vector3(0.3, 0.44, -0.36)]
	for i in 3:
		var c := fur if i % 2 == 0 else dark
		_seg(n, pts[i], pts[i + 1], 0.075 - i * 0.008, c)
		Kit.blob(n, pts[i + 1], Vector3(0.14, 0.14, 0.14) * (1.0 - i * 0.1), dark if i % 2 == 0 else fur)
	return n


## Capra Baratto (taglia M, ~1,15): capra bianca con barbetta e una sedia legata sulla schiena, da scambiare.
## «Ti do questa sedia per mezza scatoletta.»
static func _capra() -> Node3D:
	var n := Kit.root("capra_baratto")
	var coat := Art.c("ferro_6")
	var shade := Art.c("ferro_4")
	var hoof := Art.c("ferro_1")
	var wood := Art.c("legno_5")
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			Kit.cyl(n, Vector3(sx * 0.18, 0.2, sz * 0.24), 0.08, 0.36, coat)
			Kit.cyl(n, Vector3(sx * 0.18, 0.04, sz * 0.24), 0.085, 0.08, hoof)
	Kit.blob(n, Vector3(0, 0.54, -0.04), Vector3(0.66, 0.52, 0.88), coat)                 # corpo
	Kit.cyl(n, Vector3(0, 0.76, 0.33), 0.11, 0.3, coat, Vector3(-0.5, 0, 0))             # collo
	Kit.blob(n, Vector3(0, 0.92, 0.44), Vector3(0.38, 0.38, 0.42), coat)                 # testa
	Kit.blob(n, Vector3(0, 0.84, 0.62), Vector3(0.22, 0.18, 0.2), Art.c("rosa_4"))      # muso
	for sx in [-0.04, 0.04]:
		Kit.blob(n, Vector3(sx, 0.86, 0.72), Vector3(0.03, 0.04, 0.02), Art.c("rosa_1"))
	Kit.cone(n, Vector3(0, 0.67, 0.6), 0.06, 0.2, shade, Vector3(PI, 0, 0))              # barbetta
	Kit.eyes(n, Vector3(0, 0.97, 0.6), 0.2, 0.065, Vector3(0.1, 0, 1))
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.24, 0.95, 0.42), Vector3(0.2, 0.07, 0.11), shade, Vector3(0, sx * 0.3, sx * -0.3))   # orecchie
		Kit.cone(n, Vector3(sx * 0.09, 1.12, 0.38), 0.05, 0.22, Art.c("legno_3"), Vector3(-0.6, 0, sx * -0.25))      # corna
	Kit.cone(n, Vector3(0, 0.66, -0.47), 0.06, 0.14, coat, Vector3(-1.1, 0, 0))         # codina
	# sedia legata sulla schiena (la merce da barattare), dritta e un po' storta
	var ch := Node3D.new()
	ch.position = Vector3(0, 0.8, -0.08)
	ch.rotation = Vector3(0, 0.5, 0.12)
	n.add_child(ch)
	Kit.box(ch, Vector3(0, 0, 0), Vector3(0.32, 0.05, 0.3), wood)                        # seduta
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			Kit.cyl(ch, Vector3(sx * 0.13, -0.06, sz * 0.12), 0.022, 0.12, Art.c("legno_3"))  # gambe (spuntano sui fianchi)
		Kit.cyl(ch, Vector3(sx * 0.13, 0.17, -0.13), 0.024, 0.34, Art.c("legno_3"))        # montanti dello schienale
	Kit.box(ch, Vector3(0, 0.28, -0.13), Vector3(0.3, 0.1, 0.03), wood)                  # schienale
	Kit.box(ch, Vector3(0, 0.15, -0.13), Vector3(0.3, 0.05, 0.03), wood)
	Kit.box(n, Vector3(0, 0.72, -0.08), Vector3(0.64, 0.05, 0.08), Art.c("rosso_2"))     # cinghia
	# cartellino del prezzo
	Kit.cyl(n, Vector3(0.24, 0.84, -0.06), 0.006, 0.14, Art.c("ferro_1"), Vector3(0, 0, -0.5))
	Kit.box(n, Vector3(0.29, 0.76, -0.04), Vector3(0.13, 0.09, 0.015), Art.c("legno_9"), Vector3(0, -0.4, 0.1))
	Kit.box(n, Vector3(0.29, 0.76, -0.03), Vector3(0.07, 0.025, 0.01), Art.c("rosso_2"), Vector3(0, -0.4, 0.1))
	return n


## Ratto Accumulatore (taglia S, ~0,7 col mucchio): ratto grigio seduto su un mucchio di tappi, ne stringe uno.
## «Ha 400 tappi di bottiglia. Non te ne dà neanche uno.»
static func _ratto() -> Node3D:
	var n := Kit.root("ratto_accumulatore")
	var fur := Art.c("ferro_2")
	var pink := Art.c("rosa_4")
	var caps := [Art.c("rosso_2"), Art.c("giallo_2"), Art.c("acqua_4"), Art.c("ferro_5"), Art.c("verde_4")]
	# mucchio di tappi: monticello di terra con i tappi incastrati sopra
	Kit.blob(n, Vector3(0, 0, 0), Vector3(0.7, 0.26, 0.7), Art.c("legno_1"))
	var i := 0
	for ring in [[0.28, 8, 0.0], [0.16, 5, 0.4]]:
		var rr: float = ring[0]
		var cnt: int = ring[1]
		for k in cnt:
			var a: float = TAU * k / cnt + ring[2]
			var y := 0.13 * sqrt(maxf(0.0, 1.0 - pow(rr / 0.35, 2.0)))
			var tilt := rr * 1.8
			Kit.cyl(n, Vector3(cos(a) * rr, y, sin(a) * rr), 0.065, 0.03, caps[i % caps.size()], Vector3(sin(a) * tilt, 0, -cos(a) * tilt))
			i += 1
	for k in 4:   # torretta di tappi impilati, ordinata (è la sua collezione buona)
		Kit.cyl(n, Vector3(0.26 + 0.008 * k, 0.1 + k * 0.04, 0.16), 0.06, 0.035, caps[(k + 1) % caps.size()])
	# ratto seduto in cima
	var by := 0.1
	Kit.blob(n, Vector3(0, by + 0.18, -0.02), Vector3(0.34, 0.36, 0.32), fur)           # corpo
	Kit.blob(n, Vector3(0, by + 0.16, 0.08), Vector3(0.2, 0.24, 0.16), Art.c("ferro_4")) # pancia
	Kit.blob(n, Vector3(0, by + 0.42, 0.06), Vector3(0.32, 0.28, 0.3), fur)             # testa
	Kit.cone(n, Vector3(0, by + 0.39, 0.26), 0.09, 0.18, fur, Vector3(PI / 2.0, 0, 0))   # muso a punta
	Kit.blob(n, Vector3(0, by + 0.39, 0.35), Vector3(0.05, 0.04, 0.04), pink)            # naso
	Kit.eyes(n, Vector3(0, by + 0.46, 0.18), 0.13, 0.045, Vector3(0.2, 0, 1))
	for sx in [-1.0, 1.0]:
		Kit.cyl(n, Vector3(sx * 0.15, by + 0.56, 0.02), 0.08, 0.02, pink, Vector3(PI / 2.0, 0, sx * -0.4))   # orecchie
		Kit.blob(n, Vector3(sx * 0.1, by + 0.03, 0.08), Vector3(0.1, 0.06, 0.14), pink)  # piedi
	# zampette che stringono un tappo d'oro
	Kit.cyl(n, Vector3(0, by + 0.24, 0.18), 0.075, 0.035, Art.c("giallo_2"), Vector3(PI / 2.0, 0, 0))
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.07, by + 0.25, 0.17), Vector3(0.06, 0.06, 0.06), pink)
	# coda rosa che si arriccia
	var pts := [Vector3(0, by + 0.06, -0.16), Vector3(0.1, by + 0.03, -0.3), Vector3(0.24, by + 0.05, -0.3), Vector3(0.3, by + 0.12, -0.18)]
	for k in 3:
		_seg(n, pts[k], pts[k + 1], 0.025 - k * 0.005, pink)
	return n


## Gazza Armaiola (taglia S, ~0,85): gazza bianca e nera con cartucciera a tracolla e un coltello rubato nel becco.
## «Ruba coltelli e li regala agli amici.»
static func _gazza() -> Node3D:
	var n := Kit.root("gazza_armaiola")
	var black := Art.c("notte")
	var white := Art.c("ferro_6")
	var blue := Art.c("acqua_1")
	Kit.legs2(n, 0.14, 0.16, Art.c("ferro_1"), 0.03)
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.07, 0.01, 0.05), Vector3(0.08, 0.03, 0.14), Art.c("ferro_1"))
	Kit.blob(n, Vector3(0, 0.38, -0.02), Vector3(0.42, 0.48, 0.4), black)                # corpo
	Kit.blob(n, Vector3(0, 0.34, 0.08), Vector3(0.3, 0.36, 0.24), white)                 # pancia bianca
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.2, 0.4, -0.04), Vector3(0.1, 0.32, 0.28), blue, Vector3(0.2, 0, sx * 0.15))   # ali
		Kit.blob(n, Vector3(sx * 0.21, 0.36, 0.0), Vector3(0.08, 0.14, 0.14), white, Vector3(0.2, 0, sx * 0.15))  # macchia bianca
	Kit.box(n, Vector3(0, 0.26, -0.36), Vector3(0.12, 0.04, 0.42), black, Vector3(-0.5, 0, 0))     # coda lunga
	Kit.box(n, Vector3(0, 0.25, -0.37), Vector3(0.08, 0.042, 0.3), blue, Vector3(-0.5, 0, 0))
	Kit.blob(n, Vector3(0, 0.7, 0.04), Vector3(0.36, 0.34, 0.34), black)                 # testa
	Kit.eyes(n, Vector3(0, 0.74, 0.18), 0.15, 0.06, Vector3(0.25, 0, 1))
	Kit.cone(n, Vector3(0, 0.66, 0.28), 0.055, 0.17, Art.c("ferro_2"), Vector3(PI / 2.0, 0, 0))   # becco
	# coltello rubato, alzato con l'ala destra come un trofeo
	var kn := Node3D.new()
	kn.position = Vector3(0.27, 0.5, 0.08)
	kn.rotation = Vector3(0.2, 0, -0.35)
	n.add_child(kn)
	Kit.box(kn, Vector3(0, 0, 0), Vector3(0.045, 0.13, 0.045), Art.c("legno_3"))         # manico
	Kit.box(kn, Vector3(0, 0.075, 0), Vector3(0.08, 0.025, 0.06), Art.c("ferro_3"))     # guardia
	Kit.box(kn, Vector3(0.008, 0.2, 0), Vector3(0.06, 0.24, 0.014), Art.c("ferro_5"))   # lama
	Kit.cone(kn, Vector3(0.008, 0.345, 0), 0.03, 0.05, Art.c("ferro_5"))                  # punta
	Kit.blob(n, Vector3(0.25, 0.47, 0.1), Vector3(0.1, 0.1, 0.1), Art.c("acqua_1"))      # punta dell'ala che lo stringe
	# cartucciera a tracolla, aderente alla pancia
	var st := Node3D.new()
	st.position = Vector3(0, 0.38, 0.2)
	st.rotation = Vector3(0.2, 0, 0.7)
	n.add_child(st)
	Kit.box(st, Vector3.ZERO, Vector3(0.05, 0.36, 0.03), Art.c("legno_3"))
	for k in 4:
		Kit.cyl(st, Vector3(0, (k - 1.5) * 0.075, 0.025), 0.016, 0.07, Art.c("giallo_2"), Vector3(0, 0, PI / 2.0))
	return n


## Baracca di Copertoni (struttura, ~1,4 col fumo): pareti di copertoni impilati, tetto di lamiera, tubo della stufa che fuma.
## «Non brucia. Fuma soltanto, da undici anni.»
static func _baracca() -> Node3D:
	var n := Kit.root("baracca_di_copertoni", -0.3)
	var tire := Art.c("ferro_1")
	# pareti: pile di copertoni (fianchi e retro), ognuna un po' storta
	var cols := [Vector3(-0.36, 0, 0.16), Vector3(0.36, 0, 0.16), Vector3(-0.38, 0, -0.1), Vector3(0.38, 0, -0.1), Vector3(-0.36, 0, -0.36), Vector3(0.36, 0, -0.36)]
	for ci in cols.size():
		for k in 4:
			var wob := 0.02 * sin(k * 2.3 + ci)
			Kit.torus(n, cols[ci] + Vector3(wob, 0.06 + k * 0.125, -wob), 0.07, 0.17, tire, Vector3(0.06 * sin(k + ci), 0, 0.06 * cos(k * 1.7)))
	Kit.box(n, Vector3(0, 0.4, -0.42), Vector3(0.84, 0.8, 0.05), Art.c("legno_2"))      # parete di fondo
	Kit.box(n, Vector3(0, 0.5, 0.16), Vector3(0.6, 0.07, 0.07), Art.c("legno_3"), Vector3(0, 0, -0.06))   # architrave
	# porta di assi sbilenche con lo spiraglio buio
	Kit.box(n, Vector3(-0.08, 0.235, 0.14), Vector3(0.2, 0.45, 0.04), Art.c("legno_5"), Vector3(0, 0, 0.04))
	Kit.box(n, Vector3(0.1, 0.225, 0.14), Vector3(0.15, 0.43, 0.04), Art.c("legno_4"), Vector3(0, 0, -0.03))
	Kit.box(n, Vector3(0.0, 0.26, 0.165), Vector3(0.36, 0.05, 0.02), Art.c("legno_3"), Vector3(0, 0, 0.25))
	# tetto di lamiera a spiovente verso chi guarda, con una toppa e un copertone sopra per non farlo volare via
	var rf := Node3D.new()
	rf.position = Vector3(0, 0.66, -0.08)
	rf.rotation = Vector3(0.3, 0, 0.04)
	n.add_child(rf)
	Kit.box(rf, Vector3.ZERO, Vector3(1.02, 0.05, 0.86), Art.c("ruggine_1"))
	for k in 4:
		Kit.box(rf, Vector3(0, 0.03, -0.33 + k * 0.22), Vector3(1.02, 0.03, 0.05), Art.c("ruggine_2"))   # ondine della lamiera
	Kit.box(rf, Vector3(0.24, 0.05, 0.12), Vector3(0.32, 0.03, 0.26), Art.c("ferro_4"), Vector3(0, 0.15, 0))   # toppa
	Kit.torus(rf, Vector3(0.22, 0.08, -0.2), 0.07, 0.17, tire)
	# tubo della stufa e fumo grigio (niente bagliore: è solo fumo)
	Kit.cyl(n, Vector3(-0.22, 0.86, -0.25), 0.06, 0.32, Art.c("ferro_3"))
	Kit.cyl(n, Vector3(-0.22, 1.01, -0.25), 0.08, 0.04, Art.c("ferro_2"))
	Kit.blob(n, Vector3(-0.2, 1.11, -0.24), Vector3(0.18, 0.14, 0.18), Art.c("ferro_4"))
	Kit.blob(n, Vector3(-0.11, 1.23, -0.25), Vector3(0.22, 0.17, 0.2), Art.c("ferro_5"))
	Kit.blob(n, Vector3(0.03, 1.34, -0.27), Vector3(0.26, 0.18, 0.22), Art.c("ferro_6"))
	return n


## Hai Preso Tu l'Apriscatole? (evento, ~0,9): scatoletta chiusa, forchetta piegata a forza, fumetto con il punto di domanda.
## «Giorno 112. Nessuno l'ha preso.»
static func _apriscatole() -> Node3D:
	var n := Kit.root("hai_preso_tu_l_apriscatole", -0.15)
	var tin := Art.c("ferro_5")
	# scatoletta sigillata con etichetta
	Kit.cyl(n, Vector3(0, 0.16, 0), 0.17, 0.32, tin)
	Kit.cyl(n, Vector3(0, 0.15, 0), 0.175, 0.17, Art.c("rosso_2"))                      # etichetta
	Kit.blob(n, Vector3(0, 0.15, 0.16), Vector3(0.12, 0.1, 0.04), Art.c("giallo_2"))    # fagiolo sull'etichetta
	Kit.cyl(n, Vector3(0, 0.325, 0), 0.15, 0.02, Art.c("ferro_4"))                       # coperchio
	for a in [0.4, 1.9, 3.6]:
		Kit.blob(n, Vector3(cos(a) * 0.12, 0.33, sin(a) * 0.12), Vector3(0.05, 0.02, 0.03), Art.c("ferro_3"))   # graffi dei tentativi
	# forchetta piegata appoggiata a terra
	var f0 := Vector3(0.2, 0.025, 0.24)
	var f1 := Vector3(0.38, 0.025, 0.3)
	var f2 := Vector3(0.44, 0.14, 0.26)
	_seg(n, f0, f1, 0.024, Art.c("ferro_5"))
	_seg(n, f1, f2, 0.024, Art.c("ferro_5"))
	Kit.box(n, f2 + Vector3(0, 0.02, 0), Vector3(0.09, 0.04, 0.03), Art.c("ferro_5"), Vector3(0, 0.4, 0))
	for k in 3:
		var off := Vector3((k - 1) * 0.028, 0.03, -(k - 1) * 0.012)
		var tip := off + Vector3((k - 1) * 0.03, 0.1, 0.02 + (0.04 if k == 1 else 0.0))
		_seg(n, f2 + off, f2 + tip, 0.011, Art.c("ferro_5"))
	# fumetto con il punto di domanda
	var bc := Vector3(0.0, 0.7, 0.0)
	Kit.cyl(n, bc, 0.25, 0.06, Art.c("bianco"), Vector3(PI / 2.0, 0, 0))
	Kit.cone(n, bc + Vector3(0.08, -0.25, 0), 0.06, 0.14, Art.c("bianco"), Vector3(PI, 0, -0.3))
	var q := Art.c("rosso_2")
	var z := 0.05
	var arc: Array = []
	for k in 7:
		var a := deg_to_rad(170.0 - k * 40.0)
		arc.append(bc + Vector3(cos(a) * 0.08, 0.06 + sin(a) * 0.08, z))
	arc.append(bc + Vector3(0.0, -0.06, z))
	for k in arc.size() - 1:
		_seg(n, arc[k], arc[k + 1], 0.028, q)
		if k > 0:
			Kit.blob(n, arc[k], Vector3(0.056, 0.056, 0.056), q)
	Kit.blob(n, bc + Vector3(0, -0.14, z), Vector3(0.065, 0.065, 0.05), q)
	return n
