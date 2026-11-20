extends RefCounted
## Ricette dei modelli 3D: gruppo "stagno". Usa il kit (models/kit.gd) e le sue convenzioni di taglia e stile.


static func build(id: String) -> Node3D:
	match id:
		"anatra_col_coltello":
			return _anatra()
		"oca_esattrice":
			return _oca()
		"germano_di_vedetta":
			return _germano()
		"cigno_col_remo":
			return _cigno()
		"pontile_dei_predoni":
			return _pontile()
		"razionamento":
			return _razionamento()
		_:
			return null


## Sopracciglia arrabbiate (due listelli inclinati verso il centro) sopra gli occhi.
static func _brows(n: Node3D, pos: Vector3, gap: float, w: float, angry := 0.45) -> void:
	for sx in [-1.0, 1.0]:
		Kit.box(n, pos + Vector3(sx * gap / 2.0, 0, 0), Vector3(w, w * 0.28, w * 0.25), Art.c("inchiostro"), Vector3(0, 0, sx * angry))


## Piedi palmati: due zampette corte + due palette piatte.
static func _webbed(n: Node3D, gap: float, h: float, color: Color, foot := 0.14) -> void:
	Kit.legs2(n, gap, h, color, 0.035)
	for sx in [-1.0, 1.0]:
		Kit.box(n, Vector3(sx * gap / 2.0, 0.02, 0.05), Vector3(foot * 0.8, 0.04, foot), color, Vector3(0, sx * 0.25, 0))


## Becco d'anatra: piatto e largo (due metà, sopra e sotto).
static func _duck_bill(n: Node3D, pos: Vector3, s: float, color: Color) -> void:
	Kit.blob(n, pos, Vector3(0.2, 0.06, 0.2) * s, color)
	Kit.blob(n, pos + Vector3(0, -0.035, -0.01) * s, Vector3(0.16, 0.045, 0.16) * s, color)


## Anatra col Coltello (taglia S, ~0,8): anatra bianca con bandana rossa da predone e coltello da cucina alzato.
## «Qua. Dammi le scatolette. Qua.»
static func _anatra() -> Node3D:
	var n := Kit.root("anatra_col_coltello")
	var white := Art.c("ferro_6")
	var orange := Art.c("arancio_2")
	_webbed(n, 0.18, 0.12, orange)
	Kit.blob(n, Vector3(0, 0.3, -0.04), Vector3(0.5, 0.4, 0.6), white)                       # corpo
	Kit.cone(n, Vector3(0, 0.38, -0.36), 0.1, 0.18, white, Vector3(-2.0, 0, 0))            # coda all'insù
	Kit.blob(n, Vector3(0, 0.6, 0.12), Vector3(0.38, 0.36, 0.34), white)                    # testa
	_duck_bill(n, Vector3(0, 0.55, 0.32), 1.0, orange)
	Kit.eyes(n, Vector3(0, 0.65, 0.26), 0.15, 0.05, Vector3(0.15, 0, 1))
	_brows(n, Vector3(0, 0.71, 0.29), 0.15, 0.08)
	# bandana da predone: calotta rossa + nodo con le code dietro
	Kit.blob(n, Vector3(0, 0.71, 0.1), Vector3(0.4, 0.2, 0.37), Art.c("rosso_2"))
	Kit.blob(n, Vector3(0, 0.69, -0.08), Vector3(0.08, 0.07, 0.07), Art.c("rosso_1"))
	for sx in [-1.0, 1.0]:
		Kit.box(n, Vector3(sx * 0.05, 0.62, -0.12), Vector3(0.05, 0.14, 0.02), Art.c("rosso_2"), Vector3(-0.3, 0, sx * 0.4))
	Kit.blob(n, Vector3(0.13, 0.76, 0.17), Vector3(0.05, 0.05, 0.02), Art.c("bianco"))    # pois della bandana
	Kit.blob(n, Vector3(-0.13, 0.76, 0.17), Vector3(0.05, 0.05, 0.02), Art.c("bianco"))
	# ala sinistra a riposo, ala destra alzata che stringe il coltello
	Kit.blob(n, Vector3(-0.25, 0.32, -0.04), Vector3(0.1, 0.24, 0.36), Art.c("ferro_5"), Vector3(0, 0, -0.15))
	Kit.blob(n, Vector3(0.27, 0.4, 0.06), Vector3(0.12, 0.3, 0.2), Art.c("ferro_5"), Vector3(0.3, 0, -0.5))
	var knife := Node3D.new()
	knife.position = Vector3(0.36, 0.5, 0.14)
	knife.rotation = Vector3(0.2, 0, -0.25)
	n.add_child(knife)
	Kit.cyl(knife, Vector3(0, 0, 0), 0.03, 0.14, Art.c("legno_2"))                             # manico
	Kit.box(knife, Vector3(0, 0.08, 0), Vector3(0.08, 0.02, 0.05), Art.c("ferro_2"))         # guardia
	Kit.box(knife, Vector3(0.025, 0.22, 0), Vector3(0.11, 0.26, 0.02), Art.c("ferro_5"))    # lama
	Kit.box(knife, Vector3(0.0, 0.36, 0), Vector3(0.06, 0.07, 0.02), Art.c("ferro_5"), Vector3(0, 0, 0.6))
	Kit.box(knife, Vector3(0.055, 0.22, 0.012), Vector3(0.015, 0.24, 0.01), Art.c("bianco"))   # filo lucido
	knife.rotation.y = 0.35
	return n


## Oca Esattrice (taglia S-M, ~1,0): oca grigia con berretto da esattore, occhialini e registro delle tasse.
## «Le tasse si pagano anche dopo la fine del mondo.»
static func _oca() -> Node3D:
	var n := Kit.root("oca_esattrice")
	var grey := Art.c("ferro_5")
	var dark := Art.c("ferro_3")
	var orange := Art.c("arancio_2")
	_webbed(n, 0.22, 0.14, orange, 0.16)
	Kit.blob(n, Vector3(0, 0.36, -0.06), Vector3(0.56, 0.46, 0.68), grey)                    # corpo
	Kit.cone(n, Vector3(0, 0.44, -0.42), 0.1, 0.18, dark, Vector3(-2.0, 0, 0))             # coda
	Kit.blob(n, Vector3(0, 0.3, 0.14), Vector3(0.42, 0.3, 0.3), Art.c("bianco"))            # petto chiaro
	Kit.cyl(n, Vector3(0, 0.68, 0.12), 0.08, 0.36, grey, Vector3(0.15, 0, 0), 0.07)       # collo lungo
	Kit.blob(n, Vector3(0, 0.88, 0.16), Vector3(0.3, 0.28, 0.3), grey)                      # testa
	Kit.cone(n, Vector3(0, 0.84, 0.36), 0.06, 0.16, orange, Vector3(PI / 2.0, 0, 0))       # becco
	Kit.blob(n, Vector3(0, 0.865, 0.29), Vector3(0.08, 0.06, 0.04), Art.c("inchiostro"))   # attacco del becco
	Kit.eyes(n, Vector3(0, 0.92, 0.28), 0.13, 0.042, Vector3(0.1, -0.2, 1))
	# occhialini tondi
	for sx in [-1.0, 1.0]:
		Kit.torus(n, Vector3(sx * 0.065, 0.92, 0.32), 0.04, 0.052, Art.c("legno_1"), Vector3(PI / 2.0, 0, 0))
	# berretto da esattore: cupola blu, fascia, visiera
	Kit.cyl(n, Vector3(0, 1.02, 0.15), 0.15, 0.08, Art.c("acqua_1"), Vector3(-0.1, 0, 0), 0.17)
	Kit.cyl(n, Vector3(0, 1.0, 0.15), 0.152, 0.03, Art.c("giallo_2"), Vector3(-0.1, 0, 0))
	Kit.box(n, Vector3(0, 0.98, 0.31), Vector3(0.22, 0.02, 0.1), Art.c("notte"), Vector3(0.2, 0, 0))
	# registro sotto l'ala, aperto, rivolto a chi guarda
	var book := Node3D.new()
	book.position = Vector3(0.12, 0.42, 0.28)
	book.rotation = Vector3(-0.35, -0.25, 0.05)
	n.add_child(book)
	Kit.box(book, Vector3(0, 0, 0), Vector3(0.32, 0.22, 0.03), Art.c("rosso_1"))
	Kit.box(book, Vector3(0, 0, 0.02), Vector3(0.29, 0.19, 0.02), Art.c("legno_9"))
	for i in 3:
		Kit.box(book, Vector3(-0.06, 0.05 - i * 0.045, 0.032), Vector3(0.1, 0.012, 0.005), Art.c("ferro_2"))
		Kit.box(book, Vector3(0.08, 0.05 - i * 0.045, 0.032), Vector3(0.08, 0.012, 0.005), Art.c("ferro_2"))
	Kit.blob(n, Vector3(0.27, 0.42, 0.12), Vector3(0.12, 0.28, 0.3), dark, Vector3(0.4, 0, -0.2))  # ala che lo regge
	Kit.blob(n, Vector3(-0.27, 0.4, -0.06), Vector3(0.1, 0.26, 0.4), dark, Vector3(0, 0, 0.15))
	# matita dietro la testa
	Kit.cyl(n, Vector3(0.16, 0.9, 0.1), 0.015, 0.2, Art.c("giallo_2"), Vector3(0.4, 0, -0.9))
	return n


## Germano di Vedetta (taglia S, ~0,9 col palo): germano reale su un palo di legno, col binocolo agli occhi
## e il fischietto al collo. «Fischia se arriva qualcuno. Anche se non arriva nessuno.»
static func _germano() -> Node3D:
	var n := Kit.root("germano_di_vedetta")
	var orange := Art.c("arancio_3")
	# palo/ceppo di vedetta
	Kit.cyl(n, Vector3(0, 0.14, 0), 0.2, 0.28, Art.c("legno_4"), Vector3.ZERO, 0.18)
	Kit.cyl(n, Vector3(0, 0.285, 0), 0.18, 0.02, Art.c("legno_8"))
	Kit.box(n, Vector3(0.12, 0.1, 0.16), Vector3(0.12, 0.05, 0.03), Art.c("legno_2"), Vector3(0, -0.6, 0.3))
	var top := Node3D.new()
	top.position = Vector3(0, 0.29, 0)
	n.add_child(top)
	_webbed(top, 0.16, 0.08, orange, 0.12)
	Kit.blob(top, Vector3(0, 0.24, -0.04), Vector3(0.44, 0.34, 0.54), Art.c("ferro_4"))     # corpo grigio
	Kit.blob(top, Vector3(0, 0.24, 0.12), Vector3(0.34, 0.26, 0.24), Art.c("legno_3"))      # petto castano
	Kit.cone(top, Vector3(0, 0.3, -0.32), 0.08, 0.14, Art.c("notte"), Vector3(-2.0, 0, 0))
	Kit.blob(top, Vector3(-0.21, 0.25, -0.06), Vector3(0.08, 0.2, 0.32), Art.c("ferro_3"), Vector3(0, 0, 0.15))
	Kit.box(top, Vector3(-0.235, 0.22, -0.12), Vector3(0.03, 0.05, 0.12), Art.c("acqua_2"))   # specchio blu dell'ala
	Kit.torus(top, Vector3(0, 0.4, 0.06), 0.1, 0.13, Art.c("bianco"))                         # collarino bianco
	Kit.blob(top, Vector3(0, 0.52, 0.08), Vector3(0.32, 0.3, 0.3), Art.c("verde_2"))        # testa verde
	_duck_bill(top, Vector3(0, 0.46, 0.25), 0.9, Art.c("giallo_2"))
	# binocolo davanti agli occhi, retto dall'ala destra
	for sx in [-1.0, 1.0]:
		Kit.cyl(top, Vector3(sx * 0.055, 0.56, 0.27), 0.04, 0.1, Art.c("ferro_1"), Vector3(PI / 2.0, 0, 0), 0.05)
		Kit.cyl(top, Vector3(sx * 0.055, 0.56, 0.325), 0.052, 0.012, Art.c("acqua_5"), Vector3(PI / 2.0, 0, 0))
	Kit.box(top, Vector3(0, 0.56, 0.27), Vector3(0.05, 0.03, 0.04), Art.c("notte"))
	Kit.blob(top, Vector3(0.18, 0.44, 0.16), Vector3(0.1, 0.24, 0.12), Art.c("ferro_3"), Vector3(0.6, 0, -0.7))
	# fischietto appeso al collo
	Kit.cyl(top, Vector3(0.05, 0.34, 0.2), 0.025, 0.07, Art.c("giallo_2"), Vector3(PI / 2.0, 0, 0))
	Kit.cyl(top, Vector3(0.05, 0.36, 0.165), 0.006, 0.05, Art.c("rosso_2"))
	return n


## Cigno col Remo (taglia M, ~1,3: l'uccello più grande dello stagno): cigno bianco elegante, collo a esse,
## con un remo impugnato come una mazza. «Elegante. Finché non prende il remo.»
static func _cigno() -> Node3D:
	var n := Kit.root("cigno_col_remo")
	var white := Art.c("bianco")
	var shade := Art.c("ferro_6")
	var orange := Art.c("arancio_2")
	_webbed(n, 0.26, 0.14, Art.c("notte"), 0.18)
	Kit.blob(n, Vector3(0, 0.42, -0.12), Vector3(0.72, 0.56, 0.95), white)                   # corpo
	Kit.cone(n, Vector3(0, 0.54, -0.6), 0.14, 0.24, white, Vector3(-2.1, 0, 0))            # coda
	Kit.blob(n, Vector3(-0.32, 0.5, -0.18), Vector3(0.12, 0.34, 0.6), shade, Vector3(0.3, 0, 0.25))  # ala
	# collo a esse: tre tratti
	Kit.cyl(n, Vector3(0, 0.72, 0.22), 0.1, 0.32, white, Vector3(0.5, 0, 0), 0.085)
	Kit.cyl(n, Vector3(0, 0.96, 0.25), 0.085, 0.24, white, Vector3(-0.35, 0, 0), 0.08)
	Kit.blob(n, Vector3(0, 1.08, 0.2), Vector3(0.17, 0.17, 0.17), white)
	Kit.blob(n, Vector3(0, 1.16, 0.24), Vector3(0.3, 0.26, 0.32), white)                     # testa
	Kit.cone(n, Vector3(0, 1.12, 0.45), 0.065, 0.18, orange, Vector3(PI / 2.0 + 0.25, 0, 0))   # becco
	Kit.blob(n, Vector3(0, 1.15, 0.37), Vector3(0.1, 0.09, 0.06), Art.c("inchiostro"))     # pomello nero
	Kit.eyes(n, Vector3(0, 1.21, 0.36), 0.14, 0.045, Vector3(0.1, -0.1, 1))
	_brows(n, Vector3(0, 1.265, 0.38), 0.14, 0.07, 0.5)
	# remo impugnato in diagonale, pronto a colpire
	var oar := Node3D.new()
	oar.position = Vector3(0.46, 0.62, 0.26)
	oar.rotation = Vector3(0.25, 0, -0.55)
	n.add_child(oar)
	Kit.cyl(oar, Vector3(0, 0, 0), 0.035, 1.1, Art.c("legno_6"))                               # asta
	Kit.cyl(oar, Vector3(0, -0.5, 0), 0.042, 0.12, Art.c("legno_3"))                           # impugnatura
	Kit.box(oar, Vector3(0, 0.66, 0), Vector3(0.22, 0.38, 0.04), Art.c("legno_5"))             # pala
	Kit.blob(oar, Vector3(0, 0.85, 0), Vector3(0.22, 0.1, 0.04), Art.c("legno_5"))
	Kit.box(oar, Vector3(0, 0.6, 0.025), Vector3(0.22, 0.06, 0.01), Art.c("rosso_2"))          # banda rossa
	Kit.blob(n, Vector3(0.36, 0.58, 0.18), Vector3(0.14, 0.34, 0.2), shade, Vector3(0.4, 0, -0.8))  # ala che stringe
	return n


## Pontile dei Predoni (struttura, ~1,1): passerella di assi su una pozza d'acqua, sbarra del pedaggio
## a strisce e bandierina dei predoni. «Si paga il pedaggio. In dita.»
static func _pontile() -> Node3D:
	var n := Kit.root("pontile_dei_predoni", -0.3)
	# pozza
	Kit.cyl(n, Vector3(0, 0.02, 0), 0.62, 0.04, Art.c("acqua_3"))
	Kit.torus(n, Vector3(0.25, 0.045, 0.3), 0.06, 0.09, Art.c("acqua_5"))
	Kit.torus(n, Vector3(-0.35, 0.045, 0.15), 0.04, 0.065, Art.c("acqua_5"))
	# pali e assi della passerella (da dietro verso chi guarda)
	for sx in [-1.0, 1.0]:
		for z in [-0.4, 0.3]:
			Kit.cyl(n, Vector3(sx * 0.2, 0.12, z), 0.045, 0.26, Art.c("legno_2"))
	for i in 6:
		var z := -0.45 + i * 0.16
		var tilt := 0.06 if i % 2 == 0 else -0.05
		Kit.box(n, Vector3(0, 0.27, z), Vector3(0.5, 0.05, 0.14), Art.c("legno_6") if i % 2 == 0 else Art.c("legno_5"), Vector3(0, tilt, tilt * 0.5))
	# sbarra del pedaggio: palo + sbarra a strisce alzata a metà
	Kit.cyl(n, Vector3(-0.3, 0.5, 0.15), 0.04, 0.5, Art.c("legno_3"))
	Kit.box(n, Vector3(-0.3, 0.72, 0.15), Vector3(0.1, 0.1, 0.1), Art.c("legno_1"))
	var bar := Node3D.new()
	bar.position = Vector3(-0.3, 0.72, 0.15)
	bar.rotation = Vector3(0, 0, -0.35)
	n.add_child(bar)
	for i in 5:
		Kit.box(bar, Vector3(0.08 + i * 0.12, 0, 0), Vector3(0.12, 0.06, 0.06), Art.c("rosso_2") if i % 2 == 0 else Art.c("bianco"))
	# cassetta del pedaggio sul palo
	Kit.box(n, Vector3(-0.3, 0.42, 0.21), Vector3(0.14, 0.12, 0.08), Art.c("ferro_2"))
	Kit.box(n, Vector3(-0.3, 0.465, 0.25), Vector3(0.07, 0.012, 0.01), Art.c("inchiostro"))
	# bandiera dei predoni in fondo
	Kit.cyl(n, Vector3(0.22, 0.65, -0.4), 0.025, 0.8, Art.c("legno_3"))
	Kit.blob(n, Vector3(0.22, 1.06, -0.4), Vector3(0.05, 0.05, 0.05), Art.c("giallo_2"))
	Kit.box(n, Vector3(0.36, 0.92, -0.4), Vector3(0.26, 0.18, 0.02), Art.c("notte"), Vector3(0, 0, -0.06))
	Kit.blob(n, Vector3(0.36, 0.93, -0.385), Vector3(0.08, 0.07, 0.01), Art.c("bianco"))      # teschio-papera: testa
	Kit.cone(n, Vector3(0.415, 0.925, -0.385), 0.02, 0.05, Art.c("arancio_4"), Vector3(0, 0, -PI / 2.0))  # becco
	Kit.box(n, Vector3(0.36, 0.875, -0.385), Vector3(0.1, 0.02, 0.01), Art.c("bianco"), Vector3(0, 0, 0.6))  # ossa incrociate
	Kit.box(n, Vector3(0.36, 0.875, -0.385), Vector3(0.1, 0.02, 0.01), Art.c("bianco"), Vector3(0, 0, -0.6))
	return n


## Razionamento (evento, ~0,6): scatoletta aperta con dentro una sola fava, timbro rosso "razione"
## sull'etichetta e timbro di gomma accanto. «Una fava a testa. Mezza per la capra.»
static func _razionamento() -> Node3D:
	var n := Kit.root("razionamento", -0.3)
	# scatoletta
	Kit.cyl(n, Vector3(0, 0.19, 0), 0.3, 0.38, Art.c("ferro_5"))
	Kit.cyl(n, Vector3(0, 0.19, 0), 0.305, 0.22, Art.c("giallo_1"))                           # etichetta
	Kit.torus(n, Vector3(0, 0.38, 0), 0.26, 0.31, Art.c("ferro_4"))                           # bordo
	Kit.cyl(n, Vector3(0, 0.33, 0), 0.27, 0.02, Art.c("ferro_2"))                              # fondo vuoto (ombra)
	# coperchio aperto, sollevato dietro
	Kit.cyl(n, Vector3(0, 0.6, -0.33), 0.29, 0.02, Art.c("ferro_4"), Vector3(-1.25, 0, 0))
	Kit.torus(n, Vector3(0, 0.6, -0.34), 0.25, 0.29, Art.c("ferro_3"), Vector3(-1.25, 0, 0))
	# l'unica fava, al centro
	Kit.blob(n, Vector3(0, 0.38, 0.02), Vector3(0.2, 0.11, 0.13), Art.c("legno_4"), Vector3(0, 0.4, 0.2))
	Kit.blob(n, Vector3(0.02, 0.41, 0.05), Vector3(0.05, 0.02, 0.03), Art.c("legno_7"), Vector3(0, 0.4, 0.2))
	# timbro "razione" stampato sull'etichetta
	Kit.cyl(n, Vector3(0, 0.2, 0.3), 0.09, 0.012, Art.c("rosso_2"), Vector3(PI / 2.0, 0, 0))
	Kit.cyl(n, Vector3(0, 0.2, 0.305), 0.065, 0.012, Art.c("giallo_1"), Vector3(PI / 2.0, 0, 0))
	Kit.box(n, Vector3(0.005, 0.2, 0.314), Vector3(0.025, 0.09, 0.008), Art.c("rosso_2"))   # "1": una razione
	Kit.box(n, Vector3(-0.012, 0.235, 0.314), Vector3(0.03, 0.018, 0.008), Art.c("rosso_2"), Vector3(0, 0, 0.6))
	# timbro di gomma appoggiato accanto
	Kit.box(n, Vector3(0.48, 0.04, 0.16), Vector3(0.2, 0.08, 0.13), Art.c("legno_5"))
	Kit.box(n, Vector3(0.48, 0.005, 0.16), Vector3(0.18, 0.02, 0.11), Art.c("rosso_1"))
	Kit.cyl(n, Vector3(0.48, 0.14, 0.16), 0.03, 0.14, Art.c("legno_3"))
	Kit.blob(n, Vector3(0.48, 0.24, 0.16), Vector3(0.11, 0.09, 0.11), Art.c("rosso_2"))
	return n
