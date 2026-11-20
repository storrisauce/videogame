extends RefCounted
## Ricette dei modelli 3D: gruppo "patate". Usa il kit (models/kit.gd) e le sue convenzioni di taglia e stile.
## Gli ortaggi sono creature: faccia con occhi grandi e bocca espressiva, piantati su una montagnola di terra.


static func build(id: String) -> Node3D:
	match id:
		"patata_depressa":
			return _patata()
		"carota_urlatrice":
			return _carota()
		"rapa_rancorosa":
			return _rapa()
		"zucca_lievitata":
			return _zucca()
		"fienile_fumante":
			return _fienile()
		_:
			return null


# --- aiuti privati -------------------------------------------------------------------------------

## Montagnola di terra su cui poggia l'ortaggio (alta ~0,12) con due sassolini.
static func _mound(n: Node3D, w: float, d := -1.0) -> void:
	if d < 0.0:
		d = w * 0.85
	Kit.blob(n, Vector3(0, 0.03, 0), Vector3(w, 0.18, d), Art.c("legno_3"))
	Kit.blob(n, Vector3(w * 0.32, 0.07, d * 0.28), Vector3(0.07, 0.05, 0.06), Art.c("ferro_3"))
	Kit.blob(n, Vector3(-w * 0.36, 0.06, -d * 0.1), Vector3(0.05, 0.04, 0.05), Art.c("legno_1"))


## Arco di piccoli segmenti nel piano xy (bocche, sopracciglia). Angoli in gradi, 0 = destra, 90 = su.
static func _arc(p: Node3D, c: Vector3, r: float, a0: float, a1: float, thick: float, col: Color, seg := 5) -> void:
	for i in seg:
		var t0 := deg_to_rad(lerpf(a0, a1, float(i) / seg))
		var t1 := deg_to_rad(lerpf(a0, a1, float(i + 1) / seg))
		var tm := (t0 + t1) * 0.5
		var length := r * absf(t1 - t0) * 1.25
		Kit.box(p, c + Vector3(cos(tm) * r, sin(tm) * r, 0), Vector3(length, thick, thick * 0.8), col, Vector3(0, 0, tm + PI / 2.0))


## Palpebra: mezza calotta del colore della pelle che copre la parte alta dell'occhio, inclinata di `tilt`.
static func _lid(p: Node3D, eye_pos: Vector3, r: float, col: Color, tilt := 0.0, drop := 0.35) -> void:
	var lid := Node3D.new()
	lid.position = eye_pos
	lid.rotation.z = tilt
	p.add_child(lid)
	Kit.blob(lid, Vector3(0, r * (1.0 - drop), r * 0.1), Vector3(r * 2.35, r * 1.3, r * 2.35), col)


## Nodo figlio (per inclinare corpo e faccia insieme).
static func _pivot(p: Node3D, pos: Vector3, rot := Vector3.ZERO) -> Node3D:
	var g := Node3D.new()
	g.position = pos
	g.rotation = rot
	p.add_child(g)
	return g


## Prisma a base triangolare (tetti): asse lungo z, punta in alto.
static func _prism(p: Node3D, pos: Vector3, w: float, h: float, length: float, col: Color) -> void:
	var pm := PrismMesh.new()
	pm.size = Vector3(w, h, length)
	var mi := MeshInstance3D.new()
	mi.mesh = pm
	mi.position = pos
	mi.material_override = Kit.mat(col)
	p.add_child(mi)


# --- ricette -------------------------------------------------------------------------------------

## Patata Depressa (taglia S, ~0,95 con la nuvoletta): patata afflosciata sulla sua montagnola,
## occhi a mezz'asta, lacrima, bocca all'ingiù e una nuvoletta di pioggia tutta sua.
## «Sta male lei, così stanno bene gli altri.»
static func _patata() -> Node3D:
	var n := Kit.root("patata_depressa")
	var skin := Art.c("legno_7")
	var spot := Art.c("legno_4")
	_mound(n, 0.72)
	var s := _pivot(n, Vector3(0, 0.1, 0), Vector3(-0.05, 0, 0.14))              # afflosciata di lato
	Kit.blob(s, Vector3(0, 0.23, 0), Vector3(0.6, 0.46, 0.5), skin)               # corpo-patata (afflosciato)
	Kit.blob(s, Vector3(0.12, 0.42, -0.04), Vector3(0.3, 0.2, 0.3), skin)          # bitorzolo
	for pp in [Vector3(-0.2, 0.36, 0.14), Vector3(0.21, 0.18, 0.15), Vector3(0.05, 0.47, 0.06), Vector3(-0.24, 0.14, 0.05)]:
		Kit.blob(s, pp, Vector3(0.045, 0.035, 0.03), spot)                         # "occhi" della patata
	for sx in [-1.0, 1.0]:
		var ep := Vector3(sx * 0.11, 0.3, 0.21)
		Kit.eye(s, ep, 0.08, Vector3(sx * 0.1, -0.6, 1))
		_lid(s, ep, 0.08, skin, sx * -0.35, 0.4)                                     # palpebre tristi
	_arc(s, Vector3(0, 0.09, 0.25), 0.07, 40.0, 140.0, 0.022, Art.c("inchiostro"))  # bocca all'ingiù
	Kit.blob(s, Vector3(-0.19, 0.2, 0.2), Vector3(0.04, 0.06, 0.04), Art.c("acqua_5"))   # lacrima
	for sx in [-1.0, 1.0]:
		Kit.cyl(s, Vector3(sx * 0.3, 0.12, 0.1), 0.035, 0.18, skin, Vector3(0, 0, sx * 0.25))  # braccini mosci
	Kit.radio_spot(s, Vector3(0.22, 0.32, -0.12), 0.05)
	# nuvoletta di pioggia personale
	var cl := Art.c("ferro_4")
	Kit.blob(n, Vector3(0, 0.9, 0.02), Vector3(0.26, 0.2, 0.2), cl)
	Kit.blob(n, Vector3(-0.13, 0.86, 0.02), Vector3(0.2, 0.15, 0.17), cl)
	Kit.blob(n, Vector3(0.13, 0.87, 0.0), Vector3(0.2, 0.16, 0.17), cl)
	for dx in [-0.12, -0.03, 0.06, 0.14]:
		Kit.cyl(n, Vector3(dx, 0.74 + absf(dx) * 0.2, 0.04), 0.012, 0.07, Art.c("acqua_5"))
	return n


## Carota Urlatrice (taglia M, ~1,2): carota piantata a metà nella terra, ciuffo dritto per lo spavento,
## braccini in aria e bocca spalancata a urlare.
## «Più ne pianti, più urlano.»
static func _carota() -> Node3D:
	var n := Kit.root("carota_urlatrice")
	var org := Art.c("arancio_2")
	var dark := Art.c("arancio_1")
	_mound(n, 0.7)
	Kit.cyl(n, Vector3(0, 0.47, 0), 0.07, 0.78, org, Vector3.ZERO, 0.24)            # corpo affusolato
	Kit.blob(n, Vector3(0, 0.86, 0), Vector3(0.48, 0.22, 0.48), org)                # spalle tonde
	for y in [0.3, 0.48, 0.66]:
		var rr := lerpf(0.09, 0.22, (y - 0.1) / 0.78)
		Kit.box(n, Vector3(rr * 0.4, y, rr * 0.92), Vector3(0.09, 0.018, 0.02), dark, Vector3(0, -0.4, 0))   # righe
	# ciuffo dritto per lo spavento
	var lf := Art.c("verde_3")
	for a in [-0.45, -0.15, 0.15, 0.45]:
		Kit.cone(n, Vector3(a * 0.22, 1.08, 0), 0.06, 0.34, lf, Vector3(0, 0, -a * 0.6))
	Kit.cone(n, Vector3(0, 1.1, -0.06), 0.06, 0.36, Art.c("verde_2"), Vector3(-0.3, 0, 0))
	# faccia terrorizzata
	Kit.eyes(n, Vector3(0, 0.8, 0.17), 0.2, 0.085, Vector3(0, 0.15, 1))
	for sx in [-1.0, 1.0]:
		Kit.box(n, Vector3(sx * 0.1, 0.92, 0.2), Vector3(0.1, 0.025, 0.03), Art.c("arancio_1"), Vector3(0, 0, sx * 0.35))  # sopracciglia alzate
	Kit.blob(n, Vector3(0, 0.6, 0.17), Vector3(0.15, 0.2, 0.06), Art.c("inchiostro"))          # bocca spalancata
	Kit.blob(n, Vector3(0, 0.54, 0.19), Vector3(0.09, 0.06, 0.03), Art.c("rosso_2"))          # lingua
	# braccini alzati
	for sx in [-1.0, 1.0]:
		Kit.cyl(n, Vector3(sx * 0.25, 0.75, 0.02), 0.03, 0.26, org, Vector3(0, 0, sx * -0.7))
		Kit.blob(n, Vector3(sx * 0.34, 0.86, 0.02), Vector3(0.08, 0.08, 0.08), org)
	# righe dell'urlo
	for i in 3:
		var a := deg_to_rad(-25.0 + i * 25.0)
		Kit.box(n, Vector3(0.38 * cos(a) + 0.04, 0.6 + 0.38 * sin(a) * 0.5, 0.15), Vector3(0.1, 0.022, 0.02), Art.c("giallo_2"), Vector3(0, 0, a * 0.6))
	Kit.radio_spot(n, Vector3(-0.15, 0.4, 0.07), 0.04)
	return n


## Rapa Rancorosa (taglia M, ~1,0): rapa bianca e viola a braccia conserte, sopracciglia aggrottate, broncio.
## «Non ha un cervello, ma non dimentica.»
static func _rapa() -> Node3D:
	var n := Kit.root("rapa_rancorosa")
	var white := Art.c("legno_9")
	var purple := Art.c("viola_3")
	_mound(n, 0.78)
	Kit.blob(n, Vector3(0, 0.38, 0), Vector3(0.66, 0.6, 0.62), white)               # bulbo
	Kit.blob(n, Vector3(0, 0.56, 0), Vector3(0.69, 0.42, 0.65), purple)             # cappello viola
	Kit.cone(n, Vector3(0, 0.74, 0), 0.08, 0.12, purple)                            # colletto
	var lf := Art.c("verde_2")
	for a in [-0.6, 0.0, 0.6]:
		Kit.blob(n, Vector3(a * 0.2, 0.92, -0.02), Vector3(0.14, 0.34, 0.05), lf, Vector3(0, 0, -a * 0.8))
	Kit.cone(n, Vector3(0, 0.06, 0), 0.1, 0.2, white, Vector3(PI, 0, 0))             # radice nella terra
	# faccia arrabbiata (sulla parte bianca e viola)
	for sx in [-1.0, 1.0]:
		var ep := Vector3(sx * 0.12, 0.5, 0.27)
		Kit.eye(n, ep, 0.075, Vector3(0, -0.1, 1))
		_lid(n, ep, 0.075, purple, sx * 0.4, 0.45)                                   # palpebre di traverso
		Kit.box(n, Vector3(sx * 0.12, 0.6, 0.31), Vector3(0.15, 0.035, 0.04), Art.c("inchiostro"), Vector3(0, 0, sx * 0.45))   # sopracciglia
	_arc(n, Vector3(0, 0.3, 0.3), 0.07, 55.0, 125.0, 0.024, Art.c("inchiostro"), 4)    # broncio
	# braccia conserte (sotto la bocca)
	Kit.cyl(n, Vector3(0, 0.16, 0.24), 0.032, 0.32, white, Vector3(0, 0, PI / 2.0 + 0.14))
	Kit.cyl(n, Vector3(0, 0.18, 0.26), 0.032, 0.32, white, Vector3(0, 0, PI / 2.0 - 0.14))
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * 0.15, 0.17 + sx * 0.02, 0.25), Vector3(0.07, 0.07, 0.07), white)   # pugni
	Kit.radio_spot(n, Vector3(0.25, 0.62, 0.12), 0.05)
	return n


## Zucca Lievitata (taglia L, ~1,8): zuccone gonfio che lievita come un impasto e trabocca dalla
## madia di legno, con un canovaccio in testa e scintille radioattive.
## «Ogni giorno è un po' più grande. Nessuno sa cosa mangi.»
static func _zucca() -> Node3D:
	var n := Kit.root("zucca_lievitata")
	var org := Art.c("arancio_3")
	# madia (ciotola di legno) con i cerchi
	Kit.cyl(n, Vector3(0, 0.28, 0), 0.6, 0.56, Art.c("legno_4"), Vector3.ZERO, 0.86)
	Kit.torus(n, Vector3(0, 0.56, 0), 0.8, 0.94, Art.c("legno_3"))
	Kit.torus(n, Vector3(0, 0.2, 0), 0.62, 0.72, Art.c("ferro_2"))
	# zucca che lievita e trabocca dal bordo
	var z := Kit.food(n, "pumpkin", Vector3(0, 0.42, 0), 4.0)
	z.scale = Vector3(4.0, 4.8, 4.0)
	for d in [[-160.0, 0.3], [-100.0, 0.22], [-20.0, 0.34], [40.0, 0.24], [75.0, 0.4], [125.0, 0.28], [165.0, 0.36]]:
		var r := deg_to_rad(d[0])
		Kit.blob(n, Vector3(cos(r) * 0.9, 0.6 - d[1] * 0.35, sin(r) * 0.9), Vector3(0.24, d[1] + 0.12, 0.16), org, Vector3(0, -r + PI / 2.0, 0))   # impasto che cola
	# faccia pasciuta: occhi socchiusi, guance, sorriso
	for sx in [-1.0, 1.0]:
		var ep := Vector3(sx * 0.26, 1.18, 0.8)
		Kit.eye(n, ep, 0.12, Vector3(0, 0, 1))
		_lid(n, ep, 0.12, org, sx * 0.12, 0.5)
		Kit.blob(n, Vector3(sx * 0.48, 0.98, 0.78), Vector3(0.2, 0.12, 0.1), Art.c("rosso_4"))   # guance
	_arc(n, Vector3(0, 1.06, 0.9), 0.14, 205.0, 335.0, 0.04, Art.c("inchiostro"), 6)       # sorriso pacioso
	# canovaccio a righe in testa, come sull'impasto
	var t := _pivot(n, Vector3(-0.05, 1.5, 0.05), Vector3(0.12, 0.5, 0.1))
	Kit.box(t, Vector3.ZERO, Vector3(0.8, 0.05, 0.8), Art.c("bianco"))
	for dz in [-0.2, 0.2]:
		Kit.box(t, Vector3(0, 0.03, dz), Vector3(0.8, 0.02, 0.1), Art.c("rosso_2"))
	# scintille radioattive
	for sp in [Vector3(-1.0, 1.3, 0.3), Vector3(0.98, 1.45, 0.1), Vector3(-0.6, 1.8, -0.2), Vector3(0.6, 1.85, 0.0)]:
		Kit.blob(n, sp, Vector3(0.09, 0.09, 0.09), Art.c("radio_2"), Vector3(0, 0, 0.785), 2.6)
		Kit.box(n, sp, Vector3(0.22, 0.03, 0.03), Art.c("radio_2"), Vector3.ZERO, 2.6)
		Kit.box(n, sp, Vector3(0.03, 0.22, 0.03), Art.c("radio_2"), Vector3.ZERO, 2.6)
	Kit.radio_spot(n, Vector3(0.66, 1.25, 0.5), 0.09)
	return n


## Fienile Fumante (struttura, ~1,6): fienile rosso con il portone a croce, fieno nel fienile in alto
## e grossi sbuffi di fumo dal comignolo.
## «Il fumo fa bene. Dice il fienile.»
static func _fienile() -> Node3D:
	var n := Kit.root("fienile_fumante")
	var red := Art.c("rosso_1")
	var trim := Art.c("bianco")
	var roof := Art.c("ferro_2")
	Kit.box(n, Vector3(0, 0.03, 0), Vector3(1.15, 0.06, 1.0), Art.c("salvia"))    # zolla d'erba
	Kit.box(n, Vector3(0, 0.37, 0), Vector3(0.9, 0.62, 0.8), red)                   # muri
	_prism(n, Vector3(0, 0.85, 0), 0.9, 0.34, 0.8, red)                             # timpano
	for sx in [-1.0, 1.0]:
		Kit.box(n, Vector3(sx * 0.245, 0.865, 0), Vector3(0.68, 0.06, 0.96), roof, Vector3(0, 0, -sx * 0.647))   # falde
	# portone a croce
	Kit.box(n, Vector3(0, 0.28, 0.405), Vector3(0.42, 0.44, 0.02), Art.c("rosso_2"))
	for a in [0.82, -0.82]:
		Kit.box(n, Vector3(0, 0.28, 0.42), Vector3(0.55, 0.035, 0.02), trim, Vector3(0, 0, a))
	for y in [0.06, 0.5]:
		Kit.box(n, Vector3(0, y, 0.42), Vector3(0.46, 0.035, 0.02), trim)
	for sx in [-1.0, 1.0]:
		Kit.box(n, Vector3(sx * 0.22, 0.28, 0.42), Vector3(0.035, 0.48, 0.02), trim)
		Kit.box(n, Vector3(sx * 0.44, 0.37, 0.4), Vector3(0.035, 0.62, 0.035), trim)
	# finestra del fienile con il fieno
	Kit.box(n, Vector3(0, 0.8, 0.41), Vector3(0.2, 0.16, 0.02), Art.c("legno_1"))
	Kit.blob(n, Vector3(0, 0.75, 0.42), Vector3(0.2, 0.07, 0.06), Art.c("giallo_1"))
	# comignolo e fumo
	Kit.box(n, Vector3(0.25, 1.0, -0.1), Vector3(0.12, 0.3, 0.12), Art.c("ferro_1"))
	var puffs := [[Vector3(0.26, 1.2, -0.08), 0.18], [Vector3(0.36, 1.36, -0.04), 0.24], [Vector3(0.26, 1.54, 0.0), 0.3], [Vector3(0.4, 1.72, 0.02), 0.26]]
	for i in puffs.size():
		Kit.blob(n, puffs[i][0], Vector3.ONE * puffs[i][1], Art.c("ferro_6") if i % 2 else Art.c("ferro_5"))
	# balla di fieno a fianco
	Kit.box(n, Vector3(-0.52, 0.14, 0.36), Vector3(0.26, 0.18, 0.18), Art.c("giallo_1"), Vector3(0, 0.4, 0))
	return n
