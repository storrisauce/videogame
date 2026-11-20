class_name BunkerSet
extends RefCounted
## Scenografia del bunker attorno al tabellone (D-018): luce calda di una lampada sopra il tavolo, buio ai bordi,
## pozze di luce verde attorno alle cose radioattive, polvere che fluttua; tavolo di lamiera con giunture, bulloni,
## graffi, cavi e una mappa sotto il tabellone; oggetti raggruppati in piccole scene ai lati, con contorni spessi.
## bw, bd = larghezza e profondità del tabellone; il tabellone è centrato nell'origine, la sua superficie a y ≈ 0,2.

const OUT := 0.055     ## contorno degli oggetti di scena (più spesso di quello delle creature, sono più lontani)


static func build(world: Node3D, bw: float, bd: float, calm: bool) -> void:
	Kit.outline_w = OUT
	_lights(world, bw, bd)
	_table(world, bw, bd)
	var L := -bw / 2.0
	var R := bw / 2.0
	_barrel(world, Vector3(L - 1.7, 0, 2.0), 0.4, calm)
	_spilled_beans(world, Vector3(L - 1.1, 0, 3.3), -0.4)
	_gas_mask(world, Vector3(L - 1.5, 0, -0.2), 0.6)
	_gnome_shrine(world, Vector3(L - 1.4, 0, -2.9), calm)
	_radio(world, Vector3(R + 1.6, 0, 0.3), -0.5)
	_geiger(world, Vector3(R + 1.5, 0, 2.6), -0.3)
	_uranium(world, Vector3(R + 1.5, 0, -2.8), calm)
	_tower(world, Vector3(R + 3.2, 0, -4.6), calm)
	_mushrooms(world, Vector3(L - 0.6, 0, 3.9))
	_dust(world, bw, bd, calm)
	Kit.outline_w = Kit.OUT_W


# --- luce e tavolo -------------------------------------------------------------

static func _lights(world: Node3D, bw: float, bd: float) -> void:
	var spot := SpotLight3D.new()
	spot.position = Vector3(0, 11.0, 1.0)
	spot.rotation_degrees = Vector3(-90, 0, 0)
	spot.light_color = Color(1.0, 0.9, 0.72)
	spot.light_energy = 3.0
	spot.spot_range = 22.0
	spot.spot_angle = 38.0
	spot.spot_attenuation = 0.6
	spot.spot_angle_attenuation = 1.4
	spot.shadow_enabled = true
	world.add_child(spot)


static func _table(world: Node3D, bw: float, bd: float) -> void:
	var tw := bw + 12.0
	var td := bd + 10.0
	Kit.box(world, Vector3(0, -0.35, 0), Vector3(tw, 0.5, td), Art.c("ferro_1"))
	# giunture delle lamiere con bulloni
	for k in range(-2, 3):
		var x := k * 4.2
		Kit.box(world, Vector3(x, -0.095, 0), Vector3(0.06, 0.02, td - 0.4), Art.c("notte"))
		for z in range(-int(td / 2.0) + 1, int(td / 2.0), 1):
			Kit.blob(world, Vector3(x + 0.18, -0.09, z), Vector3(0.09, 0.05, 0.09), Art.c("ferro_3"))
	for k in [-1, 1]:
		Kit.box(world, Vector3(0, -0.095, k * 4.6), Vector3(tw - 0.4, 0.02, 0.06), Art.c("notte"))
	# graffi
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for k in 14:
		var g := Kit.box(world, Vector3(rng.randf_range(-tw / 2.0 + 1, tw / 2.0 - 1), -0.097, rng.randf_range(-td / 2.0 + 1, td / 2.0 - 1)),
			Vector3(rng.randf_range(0.3, 0.9), 0.01, 0.025), Art.c("ferro_2"), Vector3(0, rng.randf_range(0, PI), 0))
		g.material_override = Kit.mat(Art.c("ferro_2"), 0.0, false)
	# mappa ingiallita sotto il tabellone, un po' storta, con il segno di una tazza
	var map := Kit.box(world, Vector3(0.4, -0.09, 0.3), Vector3(bw + 2.4, 0.02, bd + 1.8), Art.c("legno_9"), Vector3(0, 0.05, 0))
	map.material_override = Kit.mat(Art.c("legno_9"), 0.0, false)
	var ring := Kit.torus(world, Vector3(bw / 2.0 + 0.9, -0.075, -bd / 2.0 - 0.3), 0.32, 0.4, Art.c("legno_5"))
	ring.material_override = Kit.mat(Art.c("legno_5"), 0.0, false)
	# cavi che corrono sul tavolo verso radio e Geiger
	_cable(world, [Vector3(bw / 2.0 + 6.0, -0.06, -1.5), Vector3(bw / 2.0 + 3.5, -0.06, -0.8), Vector3(bw / 2.0 + 2.2, -0.06, 0.2)], Art.c("notte"))
	_cable(world, [Vector3(bw / 2.0 + 6.0, -0.06, 4.5), Vector3(bw / 2.0 + 3.0, -0.06, 3.8), Vector3(bw / 2.0 + 2.0, -0.06, 2.9)], Art.c("rosso_1"))


static func _cable(world: Node3D, pts: Array, color: Color) -> void:
	for k in pts.size() - 1:
		var a: Vector3 = pts[k]
		var b: Vector3 = pts[k + 1]
		var mid := (a + b) / 2.0
		var c := Kit.cyl(world, mid, 0.05, a.distance_to(b) + 0.05, color)
		c.look_at_from_position(mid, b, Vector3.UP)
		c.rotate_object_local(Vector3.RIGHT, PI / 2.0)


# --- oggetti -------------------------------------------------------------------

static func _node(world: Node3D, pos: Vector3, rot_y := 0.0, s := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = pos + Vector3(0, -0.1, 0)
	n.rotation.y = rot_y
	n.scale = Vector3.ONE * s
	world.add_child(n)
	return n


static func _green_light(world: Node3D, pos: Vector3, energy := 2.2, rng := 2.6) -> void:
	var l := OmniLight3D.new()
	l.position = pos
	l.light_color = Art.c("radio_1")
	l.light_energy = energy
	l.omni_range = rng
	l.omni_attenuation = 1.2
	world.add_child(l)


## Simbolo radioattivo disegnato in 2D (quadrante del mirino, icone).
static func trefoil_2d(ci: CanvasItem, c: Vector2, r: float, color := Color("#181425")) -> void:
	ci.draw_circle(c, r * 0.22, color)
	for k in 3:
		var a := -PI / 2.0 + k * TAU / 3.0
		var pts := PackedVector2Array([c + Vector2(cos(a - 0.5), sin(a - 0.5)) * r * 0.35, c + Vector2(cos(a - 0.5), sin(a - 0.5)) * r,
			c + Vector2(cos(a + 0.5), sin(a + 0.5)) * r, c + Vector2(cos(a + 0.5), sin(a + 0.5)) * r * 0.35])
		ci.draw_colored_polygon(pts, color)


## Simbolo radioattivo su una superficie rivolta verso +Z (locale), centro `pos`.
static func trefoil(n: Node3D, pos: Vector3, r: float) -> void:
	Kit.cyl(n, pos, r * 0.2, 0.03, Art.c("inchiostro"), Vector3(PI / 2.0, 0, 0))
	for k in 3:
		var ang := k * TAU / 3.0 + PI / 2.0
		var blade := Kit.cyl(n, pos + Vector3(cos(ang), sin(ang), 0) * r * 0.6, r * 0.38, 0.03, Art.c("inchiostro"), Vector3(PI / 2.0, 0, 0))
		(blade.mesh as CylinderMesh).radial_segments = 3
		blade.rotation.z = ang + PI / 2.0


static func _barrel(world: Node3D, pos: Vector3, rot: float, calm: bool) -> void:
	var n := _node(world, pos, rot)
	Kit.cyl(n, Vector3(0, 0.7, 0), 0.55, 1.4, Art.c("giallo_2"))
	for y in [0.25, 0.7, 1.15]:
		Kit.cyl(n, Vector3(0, y, 0), 0.57, 0.07, Art.c("arancio_1"))
	Kit.blob(n, Vector3(0.38, 0.95, 0.3), Vector3(0.25, 0.3, 0.2), Art.c("giallo_1"))       # ammaccatura
	trefoil(n, Vector3(0, 0.62, 0.56), 0.24)
	Kit.cyl(n, Vector3(0, 1.42, 0), 0.5, 0.06, Art.c("ferro_3"))
	var ooze := Kit.blob(n, Vector3(0.05, 1.47, 0.05), Vector3(0.75, 0.16, 0.75), Art.c("radio_1"), Vector3.ZERO, 1.5)
	for d in [Vector3(0.45, 1.15, 0.25), Vector3(-0.2, 1.05, 0.5), Vector3(0.1, 0.9, 0.55)]:
		Kit.blob(n, d, Vector3(0.12, 0.5, 0.12), Art.c("radio_1"), Vector3.ZERO, 1.5)
	var puddle := Kit.blob(n, Vector3(0.6, 0.02, 0.7), Vector3(1.3, 0.05, 0.9), Art.c("radio_1"), Vector3.ZERO, 1.25)
	puddle.material_override = Kit.mat(Art.c("radio_1"), 1.25, false)
	_green_light(world, pos + Vector3(0.6, 0.4, 0.9), 1.3, 2.2)
	if not calm:
		var tw := ooze.create_tween().set_loops()
		tw.tween_property(ooze, "scale", Vector3(0.82, 0.2, 0.82), 0.9).set_trans(Tween.TRANS_SINE)
		tw.tween_property(ooze, "scale", Vector3(0.75, 0.16, 0.75), 0.9).set_trans(Tween.TRANS_SINE)


static func _spilled_beans(world: Node3D, pos: Vector3, rot: float) -> void:
	var n := _node(world, pos, rot)
	var can := Kit.cyl(n, Vector3(0, 0.3, 0), 0.3, 0.75, Art.c("ferro_4"), Vector3(0, 0, PI / 2.0))
	Kit.cyl(n, Vector3(0, 0.3, 0), 0.31, 0.45, Art.c("rosso_2"), Vector3(0, 0, PI / 2.0))
	Kit.cyl(n, Vector3(0.12, 0.31, 0), 0.32, 0.12, Art.c("legno_9"), Vector3(0, 0, PI / 2.0))
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for k in 9:
		Kit.blob(n, Vector3(0.45 + rng.randf_range(0, 0.7), 0.08, rng.randf_range(-0.35, 0.35)), Vector3(0.14, 0.09, 0.09), Art.c("ruggine_2"), Vector3(0, rng.randf_range(0, PI), 0))


static func _gas_mask(world: Node3D, pos: Vector3, rot: float) -> void:
	var n := _node(world, pos, rot)
	var face := Node3D.new()
	face.rotation_degrees = Vector3(-62, 0, 0)    # appoggiata sul tavolo, guarda in su
	face.position = Vector3(0, 0.3, 0)
	n.add_child(face)
	Kit.blob(face, Vector3.ZERO, Vector3(0.95, 1.05, 0.55), Art.c("verde_1"))
	for sx in [-0.24, 0.24]:
		Kit.torus(face, Vector3(sx, 0.18, 0.24), 0.11, 0.2, Art.c("ferro_2"), Vector3(PI / 2.0, 0, 0))
		Kit.cyl(face, Vector3(sx, 0.18, 0.26), 0.15, 0.04, Art.c("acqua_5"), Vector3(PI / 2.0, 0, 0))
		Kit.blob(face, Vector3(sx - 0.05, 0.23, 0.29), Vector3(0.08, 0.05, 0.02), Art.c("bianco"))
	Kit.cyl(face, Vector3(0, -0.28, 0.35), 0.17, 0.3, Art.c("ferro_3"), Vector3(PI / 2.0, 0, 0))   # filtro
	Kit.cyl(face, Vector3(0, -0.28, 0.52), 0.18, 0.05, Art.c("ferro_1"), Vector3(PI / 2.0, 0, 0))
	Kit.torus(n, Vector3(-0.1, 0.04, -0.55), 0.04, 0.55, Art.c("inchiostro"), Vector3(0, 0, 0))     # cinghie


static func _gnome_shrine(world: Node3D, pos: Vector3, calm: bool) -> void:
	var n := _node(world, pos, 0.5)
	Kit.box(n, Vector3(0, 0.12, 0), Vector3(1.2, 0.24, 1.0), Art.c("ferro_3"))
	Kit.cyl(n, Vector3(0, 0.55, 0), 0.3, 0.62, Art.c("acqua_3"))
	Kit.cyl(n, Vector3(0, 0.6, 0), 0.31, 0.08, Art.c("inchiostro"))
	Kit.blob(n, Vector3(0, 1.0, 0.05), Vector3(0.5, 0.48, 0.48), Art.c("pelle_4"))
	Kit.blob(n, Vector3(0, 0.82, 0.2), Vector3(0.42, 0.42, 0.25), Art.c("bianco"))
	Kit.blob(n, Vector3(0, 1.0, 0.27), Vector3(0.12, 0.1, 0.1), Art.c("rosa_3"))
	Kit.eyes(n, Vector3(0, 1.1, 0.22), 0.16, 0.045)
	Kit.cone(n, Vector3(0, 1.48, 0), 0.3, 0.7, Art.c("rosso_2"), Vector3(-0.15, 0, 0))
	var halo := Kit.torus(n, Vector3(0, 1.95, 0), 0.03, 0.22, Art.c("giallo_2"), Vector3(PI / 2.0 - 0.3, 0, 0))
	halo.material_override = Kit.mat(Art.c("giallo_2"), 0.0)
	for k in 3:
		var c := Vector3(-0.45 + k * 0.45, 0.24, 0.42)
		Kit.cyl(n, c + Vector3(0, 0.14, 0), 0.06, 0.28, Art.c("legno_9"))
		var flame := Kit.blob(n, c + Vector3(0, 0.34, 0), Vector3(0.07, 0.12, 0.07), Art.c("arancio_4"), Vector3.ZERO, 1.05)
		if not calm:
			var tw := flame.create_tween().set_loops()
			var base := flame.scale   # Kit.blob mette la misura nella scala: l'animazione è relativa a quella
			tw.tween_property(flame, "scale", base * Vector3(0.8, 1.25, 0.8), 0.18 + k * 0.05)
			tw.tween_property(flame, "scale", base, 0.2 + k * 0.04)



static func _radio(world: Node3D, pos: Vector3, rot: float) -> void:
	var n := _node(world, pos, rot)
	Kit.box(n, Vector3(0, 0.55, 0), Vector3(1.5, 1.0, 0.6), Art.c("rosso_2"))
	Kit.box(n, Vector3(0, 1.06, 0), Vector3(1.3, 0.06, 0.5), Art.c("rosso_1"))
	for k in 5:
		Kit.box(n, Vector3(-0.4, 0.3 + k * 0.1, 0.31), Vector3(0.5, 0.04, 0.02), Art.c("inchiostro"))
	Kit.box(n, Vector3(0.32, 0.68, 0.31), Vector3(0.6, 0.28, 0.03), Art.c("legno_9"))
	Kit.box(n, Vector3(0.28, 0.68, 0.33), Vector3(0.03, 0.24, 0.02), Art.c("rosso_2"))
	for sx in [0.15, 0.48]:
		Kit.cyl(n, Vector3(sx, 0.32, 0.33), 0.09, 0.08, Art.c("ferro_5"), Vector3(PI / 2.0, 0, 0))
	Kit.torus(n, Vector3(0, 1.25, 0), 0.05, 0.35, Art.c("ferro_2"), Vector3(0, 0, 0)).rotation = Vector3(0, 0, 0)
	var ant := Kit.cyl(n, Vector3(0.75, 1.55, -0.1), 0.03, 1.3, Art.c("ferro_4"), Vector3(0, 0, -0.5))
	Kit.blob(n, Vector3(1.07, 2.12, -0.1), Vector3(0.12, 0.12, 0.12), Art.c("ferro_5"))


static func _geiger(world: Node3D, pos: Vector3, rot: float) -> void:
	var n := _node(world, pos, rot)
	Kit.box(n, Vector3(0, 0.38, 0), Vector3(1.1, 0.66, 0.7), Art.c("arancio_4"))
	Kit.box(n, Vector3(0, 0.38, 0), Vector3(1.14, 0.08, 0.74), Art.c("arancio_1"))
	Kit.cyl(n, Vector3(-0.18, 0.45, 0.36), 0.24, 0.05, Art.c("bianco"), Vector3(PI / 2.0, 0, 0))
	Kit.torus(n, Vector3(-0.18, 0.45, 0.37), 0.24, 0.29, Art.c("inchiostro"), Vector3(PI / 2.0, 0, 0))
	Kit.box(n, Vector3(-0.1, 0.52, 0.4), Vector3(0.03, 0.2, 0.02), Art.c("rosso_2"), Vector3(0, 0, -0.7))
	Kit.blob(n, Vector3(0.3, 0.5, 0.36), Vector3(0.1, 0.1, 0.05), Art.c("radio_1"), Vector3.ZERO, 2.6)
	Kit.cyl(n, Vector3(0.3, 0.3, 0.37), 0.07, 0.05, Art.c("inchiostro"), Vector3(PI / 2.0, 0, 0))
	Kit.torus(n, Vector3(0, 0.85, 0), 0.06, 0.26, Art.c("inchiostro"), Vector3(PI / 2.0, PI / 2.0, 0))
	# sonda col cavo a spirale
	Kit.cyl(n, Vector3(1.15, 0.1, 0.4), 0.09, 0.8, Art.c("ferro_4"), Vector3(0, 0.4, PI / 2.0))
	for k in 5:
		Kit.torus(n, Vector3(0.6 + k * 0.1, 0.12, 0.25), 0.02, 0.08, Art.c("inchiostro"), Vector3(0, 0, PI / 2.0))


static func _uranium(world: Node3D, pos: Vector3, calm: bool) -> void:
	var n := _node(world, pos, -0.3)
	Kit.box(n, Vector3(0, 0.4, 0), Vector3(1.3, 0.8, 0.9), Art.c("legno_5"))
	for y in [0.15, 0.65]:
		Kit.box(n, Vector3(0, y, 0.46), Vector3(1.3, 0.12, 0.03), Art.c("legno_3"))
	trefoil(n, Vector3(0, 0.4, 0.47), 0.17)
	for k in 5:
		var rod := Kit.cyl(n, Vector3(-0.44 + k * 0.22, 1.0, 0.0), 0.08, 0.9, Art.c("radio_1"), Vector3(0.15 * ((k % 2) * 2 - 1), 0, 0.1 * (k - 2)))
		rod.material_override = Kit.mat(Art.c("radio_1"), 1.9)
		if not calm:
			var y := rod.position.y
			var tw := rod.create_tween().set_loops()
			tw.tween_property(rod, "position:y", y + 0.07, 0.7 + k * 0.13).set_trans(Tween.TRANS_SINE)
			tw.tween_property(rod, "position:y", y, 0.7 + k * 0.13).set_trans(Tween.TRANS_SINE)
	# cartello piantato nella cassa
	Kit.cyl(n, Vector3(0.75, 0.9, -0.2), 0.04, 1.6, Art.c("ferro_3"))
	var tri := Kit.cone(n, Vector3(0.75, 1.7, -0.15), 0.4, 0.06, Art.c("giallo_2"), Vector3(PI / 2.0, 0, 0))
	(tri.mesh as CylinderMesh).radial_segments = 3
	trefoil(n, Vector3(0.75, 1.63, -0.1), 0.1)
	_green_light(world, pos + Vector3(0, 1.3, 0.4), 2.6, 3.0)


static func _tower(world: Node3D, pos: Vector3, calm: bool) -> void:
	var n := _node(world, pos, 0.0, 0.7)
	var rs := [1.0, 0.85, 0.7, 0.62, 0.68, 0.78]
	for k in rs.size():
		Kit.cyl(n, Vector3(0, 0.22 + k * 0.4, 0), rs[k], 0.42, Art.c("ferro_6") if k != 4 else Art.c("rosso_2"), Vector3.ZERO, rs[mini(k + 1, rs.size() - 1)])
	for k in 4:
		var y := 2.6 + k * 0.5
		var puff := Kit.blob(n, Vector3(0.1 * k, y, 0), Vector3.ONE * (0.6 + k * 0.2), Art.c("ferro_6"))
		if not calm:
			var tw := puff.create_tween().set_loops()
			tw.tween_interval(k * 0.4)
			tw.tween_property(puff, "position:y", y + 0.7, 1.6).set_trans(Tween.TRANS_SINE)
			tw.tween_property(puff, "position:y", y, 0.01)


static func _mushrooms(world: Node3D, pos: Vector3) -> void:
	var n := _node(world, pos, 0.2)
	for m in [[Vector3(0, 0, 0), 1.0], [Vector3(0.5, 0, 0.25), 0.65], [Vector3(-0.35, 0, 0.35), 0.5]]:
		var p: Vector3 = m[0]
		var s: float = m[1]
		Kit.cyl(n, p + Vector3(0, 0.25 * s, 0), 0.1 * s, 0.5 * s, Art.c("legno_9"))
		Kit.blob(n, p + Vector3(0, 0.55 * s, 0), Vector3(0.6, 0.32, 0.6) * s, Art.c("viola_3"))
		Kit.blob(n, p + Vector3(0.12 * s, 0.68 * s, 0.1 * s), Vector3(0.12, 0.05, 0.12) * s, Art.c("radio_2"), Vector3.ZERO, 2.6)


## Polvere radioattiva che fluttua piano nella luce della lampada.
static func _dust(world: Node3D, bw: float, bd: float, calm: bool) -> void:
	if calm:
		return
	var ps := CPUParticles3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(0.06, 0.06)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.vertex_color_use_as_albedo = true
	qm.material = mat
	ps.mesh = qm
	ps.amount = 50
	ps.lifetime = 7.0
	ps.preprocess = 7.0
	ps.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	ps.emission_box_extents = Vector3(bw / 2.0 + 2.5, 1.2, bd / 2.0 + 2.0)
	ps.position = Vector3(0, 1.4, 0)
	ps.direction = Vector3(0, 1, 0)
	ps.spread = 180.0
	ps.gravity = Vector3(0, 0.05, 0)
	ps.initial_velocity_min = 0.03
	ps.initial_velocity_max = 0.12
	var g := Gradient.new()
	g.set_color(0, Color(Art.c("radio_2"), 0.0))
	g.add_point(0.3, Color(Art.c("radio_2"), 0.7))
	g.set_color(g.get_point_count() - 1, Color(Art.c("radio_2"), 0.0))
	ps.color_ramp = g
	world.add_child(ps)
