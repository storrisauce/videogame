extends RefCounted
## Ricette dei modelli 3D: gruppo "porcile". Usa il kit (models/kit.gd) e le sue convenzioni di taglia e stile.


static func build(id: String) -> Node3D:
	match id:
		"maialino_di_scorta":
			return _maialino()
		"scrofa_carrarmato":
			return _scrofa_carrarmato()
		"maiale_in_lamiera":
			return _maiale_in_lamiera()
		"verro_spugna":
			return _verro_spugna()
		"bunker_di_lamiera":
			return _bunker_di_lamiera()
		_:
			return null


## Maialino di Scorta (taglia S, ~0,75): un cucciolo rosa paffuto con il cartellino "scorta" all'orecchio.
## «Lo teniamo per le emergenze. Lui non lo sa.»
static func _maialino() -> Node3D:
	var n := Kit.root("maialino_di_scorta")
	var pink := Art.c("rosa_4")
	var dark := Art.c("rosa_2")
	Kit.legs4(n, 0.5, 0.55, 0.18, dark, 0.075)
	Kit.blob(n, Vector3(0, 0.36, -0.05), Vector3(0.62, 0.48, 0.72), pink)                 # corpo
	Kit.blob(n, Vector3(0, 0.52, 0.3), Vector3(0.5, 0.46, 0.44), pink)                    # testa grande (cucciolo)
	Kit.cyl(n, Vector3(0, 0.48, 0.52), 0.11, 0.09, Art.c("rosa_3"), Vector3(PI / 2.0, 0, 0))   # grugno
	for sx in [-0.04, 0.04]:
		Kit.blob(n, Vector3(sx, 0.49, 0.57), Vector3(0.035, 0.05, 0.02), Art.c("rosa_1"))
	Kit.eyes(n, Vector3(0, 0.6, 0.47), 0.2, 0.06, Vector3(0.1, 0, 1))
	for sx in [-1.0, 1.0]:
		Kit.cone(n, Vector3(sx * 0.17, 0.77, 0.27), 0.08, 0.16, dark, Vector3(0.3, 0, sx * -0.5))   # orecchie
	# cartellino della scorta appeso all'orecchio destro
	Kit.cyl(n, Vector3(0.24, 0.72, 0.3), 0.008, 0.12, Art.c("legno_3"), Vector3(0, 0, 0.4))
	Kit.box(n, Vector3(0.29, 0.63, 0.31), Vector3(0.13, 0.09, 0.015), Art.c("legno_9"), Vector3(0, -0.2, 0.15))
	Kit.box(n, Vector3(0.29, 0.63, 0.32), Vector3(0.07, 0.025, 0.01), Art.c("rosso_2"), Vector3(0, -0.2, 0.15))
	Kit.torus(n, Vector3(0, 0.45, -0.42), 0.03, 0.07, dark, Vector3(PI / 2.0, 0, 0))     # codino a ricciolo
	Kit.radio_spot(n, Vector3(-0.2, 0.52, -0.12), 0.06)
	return n


## Muso di maiale (grugno con narici, occhi, orecchie a punta) davanti a una testa centrata in `c`, larga `w`.
static func _pig_face(n: Node3D, c: Vector3, w: float, ear_col: Color, look := Vector3(0.1, 0, 1)) -> void:
	var snout_z := c.z + w * 0.46
	Kit.cyl(n, Vector3(0, c.y - w * 0.12, snout_z), w * 0.23, w * 0.2, Art.c("rosa_3"), Vector3(PI / 2.0, 0, 0))
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(sx * w * 0.08, c.y - w * 0.1, snout_z + w * 0.1), Vector3(w * 0.07, w * 0.1, w * 0.04), Art.c("rosa_1"))
	Kit.eyes(n, Vector3(0, c.y + w * 0.14, c.z + w * 0.36), w * 0.4, w * 0.12, look)
	for sx in [-1.0, 1.0]:
		Kit.cone(n, Vector3(sx * w * 0.34, c.y + w * 0.5, c.z - w * 0.05), w * 0.16, w * 0.32, ear_col, Vector3(0.3, 0, sx * -0.5))


## Bullone: una testa di vite sporgente in `pos`.
static func _bolt(n: Node3D, pos: Vector3, r := 0.035) -> void:
	Kit.blob(n, pos, Vector3(r * 2.0, r * 2.0, r * 2.0), Art.c("ferro_5"))


## Scrofa Carrarmato (taglia L, ~1,6): una scrofa enorme montata su due cingoli, con la piastra di lamiera
## imbullonata sulla schiena e il tubo di scappamento che fuma. «Ha mangiato un trattore. Il trattore era d'accordo.»
static func _scrofa_carrarmato() -> Node3D:
	var n := Kit.root("scrofa_carrarmato")
	var pink := Art.c("rosa_4")
	var track := Art.c("ferro_1")
	var wheel := Art.c("ferro_4")
	# cingoli: piastra + due estremità tonde + ruote a vista
	for sx in [-1.0, 1.0]:
		var x: float = sx * 0.52
		Kit.box(n, Vector3(x, 0.19, 0), Vector3(0.3, 0.38, 1.2), track)
		for sz in [-1.0, 1.0]:
			Kit.cyl(n, Vector3(x, 0.19, sz * 0.6), 0.19, 0.3, track, Vector3(0, 0, PI / 2.0))
		for z in [-0.55, 0.0, 0.55]:
			Kit.cyl(n, Vector3(x + sx * 0.14, 0.19, z), 0.12, 0.04, wheel, Vector3(0, 0, PI / 2.0))
	# corpo enorme che strabocca dai cingoli
	Kit.blob(n, Vector3(0, 0.74, -0.08), Vector3(1.3, 0.85, 1.5), pink)
	# piastra di lamiera imbullonata sulla schiena, con la striscia di pericolo
	Kit.box(n, Vector3(0, 1.13, -0.2), Vector3(0.8, 0.07, 0.75), Art.c("ferro_3"), Vector3(-0.12, 0, 0))
	Kit.box(n, Vector3(0, 1.175, -0.2), Vector3(0.8, 0.02, 0.14), Art.c("arancio_4"), Vector3(-0.12, 0, 0))
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			_bolt(n, Vector3(sx * 0.32, 1.17 - sz * 0.035, -0.2 + sz * 0.3), 0.035)
	# testa grande, un po' più bassa del dorso
	var head := Vector3(0, 0.9, 0.62)
	Kit.blob(n, head, Vector3(0.85, 0.75, 0.66), pink)
	_pig_face(n, head, 0.85, Art.c("rosa_2"))
	# fanale del trattore sulla fronte
	Kit.cyl(n, Vector3(0, 1.24, 0.75), 0.07, 0.06, Art.c("ferro_2"), Vector3(PI / 2.0 - 0.3, 0, 0))
	Kit.cyl(n, Vector3(0, 1.245, 0.785), 0.05, 0.02, Art.c("giallo_2"), Vector3(PI / 2.0 - 0.3, 0, 0))
	# tubo di scappamento verticale dietro, con il fumo
	Kit.cyl(n, Vector3(0.38, 1.25, -0.55), 0.06, 0.55, Art.c("ferro_2"))
	Kit.cyl(n, Vector3(0.38, 1.53, -0.55), 0.08, 0.06, Art.c("ferro_1"))
	Kit.blob(n, Vector3(0.42, 1.68, -0.58), Vector3(0.18, 0.15, 0.18), Art.c("ferro_5"))
	Kit.blob(n, Vector3(0.5, 1.82, -0.62), Vector3(0.13, 0.11, 0.13), Art.c("ferro_6"))
	Kit.torus(n, Vector3(0, 0.82, -0.86), 0.03, 0.08, Art.c("rosa_2"), Vector3(PI / 2.0, 0, 0))   # codino
	return n


## Maiale in Lamiera (taglia M, ~1,1): un maiale con un'armatura fatta di lamiere imbullonate e un secchio per elmo.
## «Rumoroso quando cammina. Anche da fermo.»
static func _maiale_in_lamiera() -> Node3D:
	var n := Kit.root("maiale_in_lamiera")
	var pink := Art.c("rosa_4")
	var plate := Art.c("ferro_4")
	var rust := Art.c("ruggine_2")
	Kit.legs4(n, 0.72, 0.8, 0.24, Art.c("rosa_2"), 0.09)
	Kit.blob(n, Vector3(0, 0.5, -0.05), Vector3(0.84, 0.62, 0.98), pink)
	# lamiere a tetto sulla schiena (due falde) con bulloni e una toppa di ruggine
	for sx in [-1.0, 1.0]:
		Kit.box(n, Vector3(sx * 0.19, 0.75, -0.08), Vector3(0.42, 0.06, 0.74), plate, Vector3(0, 0, sx * -0.65))
		for z in [-0.3, 0.0, 0.28]:
			_bolt(n, Vector3(sx * 0.3, 0.7, -0.08 + z), 0.03)
	Kit.box(n, Vector3(-0.17, 0.79, 0.12), Vector3(0.16, 0.03, 0.15), rust, Vector3(0, 0.3, 0.65))
	# pettorale davanti al petto
	Kit.box(n, Vector3(0, 0.42, 0.36), Vector3(0.5, 0.32, 0.06), Art.c("ferro_3"), Vector3(-0.15, 0, 0))
	for sx in [-1.0, 1.0]:
		_bolt(n, Vector3(sx * 0.18, 0.5, 0.39), 0.03)
	# testa
	var head := Vector3(0, 0.66, 0.42)
	Kit.blob(n, head, Vector3(0.62, 0.56, 0.52), pink)
	_pig_face(n, head, 0.62, Art.c("rosa_2"))
	# elmo: un secchio di latta capovolto, un po' storto, col manico
	Kit.cyl(n, Vector3(0.02, 1.0, 0.38), 0.24, 0.24, Art.c("ferro_5"), Vector3(-0.15, 0, 0.12), 0.18)
	Kit.cyl(n, Vector3(0.0, 0.89, 0.4), 0.26, 0.04, Art.c("ferro_3"), Vector3(-0.15, 0, 0.12))
	Kit.cyl(n, Vector3(0.0, 0.96, 0.39), 0.24, 0.03, Art.c("ferro_3"), Vector3(-0.15, 0, 0.12))
	_bolt(n, Vector3(0.04, 1.12, 0.37), 0.035)
	# piastra sul sedere e codino
	Kit.box(n, Vector3(0, 0.55, -0.53), Vector3(0.44, 0.34, 0.05), plate, Vector3(0.1, 0, 0))
	Kit.torus(n, Vector3(0.12, 0.66, -0.58), 0.025, 0.06, Art.c("rosa_2"), Vector3(PI / 2.0, 0, 0))
	return n


## Verro Spugna (taglia M, ~1,1): un verro giallo spugna pieno di buchi, con zanne piccole e una cresta di setole,
## che gocciola radiazioni assorbite. «Assorbe tutto. Soprattutto le radiazioni.»
static func _verro_spugna() -> Node3D:
	var n := Kit.root("verro_spugna")
	var sponge := Art.c("giallo_1")
	var hole := Art.c("arancio_3")
	Kit.legs4(n, 0.72, 0.8, 0.24, Art.c("legno_7"), 0.09)
	# corpo squadrato come una spugna
	Kit.box(n, Vector3(0, 0.55, -0.05), Vector3(0.8, 0.62, 0.95), sponge)
	# buchi della spugna sui fianchi e sul dorso
	var holes := [
		[Vector3(0.405, 0.65, 0.15), Vector3(0.02, 0.12, 0.1)],
		[Vector3(0.405, 0.45, -0.2), Vector3(0.02, 0.09, 0.14)],
		[Vector3(0.405, 0.7, -0.33), Vector3(0.02, 0.08, 0.08)],
		[Vector3(-0.405, 0.6, 0.05), Vector3(0.02, 0.12, 0.12)],
		[Vector3(-0.405, 0.42, -0.3), Vector3(0.02, 0.08, 0.1)],
	]
	for h in holes:
		Kit.blob(n, h[0], h[1], hole)
	# strato verde ruvido da spugna da cucina, con la cresta di setole da verro
	Kit.box(n, Vector3(0, 0.92, -0.05), Vector3(0.8, 0.12, 0.95), Art.c("verde_3"))
	for i in 4:
		Kit.cone(n, Vector3(0, 1.02, 0.22 - i * 0.17), 0.05, 0.12, Art.c("verde_1"), Vector3(-0.3, 0, 0))
	# testa spugnosa
	var head := Vector3(0, 0.66, 0.5)
	Kit.blob(n, head, Vector3(0.6, 0.54, 0.5), sponge)
	_pig_face(n, head, 0.6, Art.c("legno_7"), Vector3(0.1, -0.1, 1))
	Kit.blob(n, Vector3(0.2, 0.82, 0.62), Vector3(0.06, 0.07, 0.03), hole)
	Kit.blob(n, Vector3(-0.24, 0.55, 0.62), Vector3(0.06, 0.06, 0.03), hole)
	# zanne piccole che spuntano ai lati del grugno
	for sx in [-1.0, 1.0]:
		Kit.cone(n, Vector3(sx * 0.13, 0.56, 0.84), 0.035, 0.11, Art.c("bianco"), Vector3(0.2, 0, sx * -0.35))
	# gocce radioattive assorbite che colano e la pozzetta sotto
	Kit.blob(n, Vector3(0.3, 0.18, 0.2), Vector3(0.06, 0.1, 0.06), Art.c("radio_1"), Vector3.ZERO, 2.4)
	Kit.blob(n, Vector3(-0.28, 0.3, -0.35), Vector3(0.05, 0.08, 0.05), Art.c("radio_1"), Vector3.ZERO, 2.4)
	Kit.blob(n, Vector3(0.12, 0.012, 0.05), Vector3(0.38, 0.02, 0.3), Art.c("radio_2"), Vector3.ZERO, 1.6)
	return n


## Mezzo cilindro chiuso (arco) con asse lungo z, base a terra in `pos.y`: forma della baracca di lamiera.
static func _arch(parent: Node3D, pos: Vector3, radius: float, length: float, color: Color, segs := 8) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var hz := length / 2.0
	var pts: Array[Vector2] = []
	for i in segs + 1:
		var a := PI * float(i) / float(segs)
		pts.append(Vector2(cos(a) * radius, sin(a) * radius))
	# volta (lisciata)
	st.set_smooth_group(1)
	for i in segs:
		var a := pts[i]
		var b := pts[i + 1]
		var v0 := Vector3(a.x, a.y, hz)
		var v1 := Vector3(b.x, b.y, hz)
		var v2 := Vector3(b.x, b.y, -hz)
		var v3 := Vector3(a.x, a.y, -hz)
		for v in [v0, v1, v2, v0, v2, v3]:
			st.add_vertex(v)
	# fronte e retro (piatti)
	st.set_smooth_group(-1)
	for i in segs:
		var a := pts[i]
		var b := pts[i + 1]
		for v in [Vector3(0, 0, hz), Vector3(b.x, b.y, hz), Vector3(a.x, a.y, hz)]:
			st.add_vertex(v)
		for v in [Vector3(0, 0, -hz), Vector3(a.x, a.y, -hz), Vector3(b.x, b.y, -hz)]:
			st.add_vertex(v)
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.position = pos
	mi.material_override = Kit.mat(color)
	parent.add_child(mi)
	return mi


## Bunker di Lamiera (struttura, ~1,05): una baracca a mezza botte di lamiera ondulata con le costole,
## la porta socchiusa e un grugno che sbircia dal buio. «Entrare è facile. Uscire dipende dal maiale.»
static func _bunker_di_lamiera() -> Node3D:
	var n := Kit.root("bunker_di_lamiera", -0.3)
	var sheet := Art.c("ferro_4")
	var rib := Art.c("ferro_2")
	# zoccolo di terra battuta
	Kit.box(n, Vector3(0, 0.04, 0.05), Vector3(1.75, 0.08, 1.6), Art.c("legno_4"))
	_arch(n, Vector3(0, 0.08, 0), 0.78, 1.35, sheet, 10)
	# costole della lamiera ondulata
	for z in [-0.45, -0.15, 0.15, 0.45]:
		_arch(n, Vector3(0, 0.08, z), 0.8, 0.05, rib, 10)
	_arch(n, Vector3(0, 0.08, 0.66), 0.81, 0.06, rib, 10)       # bordo davanti
	# toppa di ruggine
	Kit.box(n, Vector3(-0.42, 0.68, -0.05), Vector3(0.03, 0.22, 0.24), Art.c("ruggine_2"), Vector3(0, 0, 0.6))
	# porta buia e anta di lamiera socchiusa
	Kit.box(n, Vector3(0, 0.38, 0.68), Vector3(0.5, 0.6, 0.02), Art.c("inchiostro"))
	Kit.box(n, Vector3(0.36, 0.38, 0.86), Vector3(0.04, 0.6, 0.36), Art.c("ferro_3"), Vector3(0, -0.5, 0))
	_bolt(n, Vector3(0.27, 0.38, 1.0), 0.03)
	# il maiale che sbircia: grugno e occhi nel buio della porta
	Kit.blob(n, Vector3(-0.04, 0.32, 0.7), Vector3(0.3, 0.26, 0.12), Art.c("rosa_4"))
	Kit.cyl(n, Vector3(-0.04, 0.29, 0.77), 0.08, 0.07, Art.c("rosa_3"), Vector3(PI / 2.0, 0, 0))
	for sx in [-1.0, 1.0]:
		Kit.blob(n, Vector3(-0.04 + sx * 0.03, 0.3, 0.81), Vector3(0.025, 0.035, 0.015), Art.c("rosa_1"))
	Kit.eyes(n, Vector3(-0.04, 0.46, 0.73), 0.15, 0.05, Vector3(0.3, 0, 1))
	# camino di latta sul tetto
	Kit.cyl(n, Vector3(0.3, 0.92, -0.3), 0.06, 0.32, rib)
	Kit.cyl(n, Vector3(0.3, 1.1, -0.3), 0.09, 0.05, Art.c("ferro_1"), Vector3.ZERO, 0.05)
	# cartello di pericolo a rombo sopra la porta, con il grugno disegnato
	Kit.box(n, Vector3(0, 0.82, 0.69), Vector3(0.18, 0.18, 0.03), Art.c("giallo_2"), Vector3(0, 0, PI / 4.0))
	Kit.cyl(n, Vector3(0, 0.82, 0.71), 0.04, 0.02, Art.c("rosa_3"), Vector3(PI / 2.0, 0, 0))
	return n
