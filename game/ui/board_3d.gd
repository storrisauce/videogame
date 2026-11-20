class_name Board3D
extends Control
## Il tavolo in 3D vero (D-015): un altopiano di fattoria inclinato verso il giocatore, come nei giochi a corsie,
## con le creature pixel art in piedi (Sprite3D rivolti alla telecamera). Le superfici usano i colori esatti della
## palette (materiali "unshaded"); solo siepe e steccati prendono la luce del sole per dare volume.
## L'interfaccia 2D (vita, attacco, tocchi) sta sopra: MatchScreen chiede a questa classe dove cade ogni recinto.
## Le animazioni (arrivo, attacco, colpo, morte) partono da qui; durano 150–400 ms, entrate in ease-out.

signal framed   ## la telecamera si è sistemata: i recinti sullo schermo sono cambiati

const COL_W := 2.1          ## larghezza di un recinto (unità del mondo): corsie lunghe e strette
const ROW_D := 2.95         ## profondità di un recinto: circa 1 : 1,4
const MID := 0.8            ## sentiero tra le due file
const PX := 1.0 / 16.0      ## un pixel dello sprite in unità del mondo: 1 tile da 16 px = 1 unità (design system §3)
const STRUCT_SCALE := 0.8   ## le strutture stanno dietro, un po' più piccole
const CAM_TARGET := Vector3(0, 0, 0.35)
const CAM_DIR := Vector3(0, 0.76, 0.65)   ## inclinazione fissa (~50 gradi); la distanza si adatta allo schermo

var cam := Camera3D.new()
var world := Node3D.new()
var creature_sprites := [[null, null, null, null], [null, null, null, null]]
var structure_sprites := [[null, null, null, null], [null, null, null, null]]
var _shown := [[null, null, null, null], [null, null, null, null]]      ## CardInst mostrata per recinto (creatura)
var _shown_s := [[null, null, null, null], [null, null, null, null]]    ## struttura
var _zones := [[], []]
var _trauma := 0.0
var _cam_rest := Transform3D()
var _t := 0.0
var reduce_motion := false
var focus := Rect2()     ## zona dello schermo (coordinate del controllo) in cui il tabellone deve stare
var avoid: Array[Rect2] = []   ## zone da non coprire (i ritratti negli angoli): il fondo del tabellone, più stretto, ci passa in mezzo


## Il mondo 3D sta direttamente nella finestra principale (niente riquadro intermedio): così è disegnato alla
## risoluzione vera dello schermo, con l'anti-aliasing del progetto, sotto tutta l'interfaccia 2D.
func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(world)
	_build_world()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_inside_tree():
		_fit_camera.call_deferred()


## Dimensione della vista (unità dell'interfaccia, come le coordinate di `project`).
func _vsize() -> Vector2:
	return get_viewport().get_visible_rect().size if is_inside_tree() else Vector2.ZERO


func has_view() -> bool:
	return is_inside_tree() and cam.is_inside_tree() and _vsize().x > 16


# --- Costruzione ---------------------------------------------------------------
## Stile (strada A): low-poly cartoon con ombre a gradini (shaders/toon.gdshader) e contorno nero
## (shaders/outline.gdshader). Il tabellone è un vassoio di legno sul tavolo di lamiera di un bunker, con oggetti
## di scena intorno. Bloom leggero solo sulle cose radioattive (emissione > 1).

const SURF := 0.22          ## altezza della superficie dei recinti
const TOON := preload("res://shaders/toon.gdshader")
const OUTLINE := preload("res://shaders/outline.gdshader")
const TERRAIN := {
	"porcile": ["legno_4", "legno_3"], "pollaio": ["pelle_3", "arancio_4"], "stagno": ["acqua_4", "acqua_6"],
	"patate": ["legno_3", "legno_5"], "discarica": ["ferro_3", "ferro_2"], "cratere": ["viola_1", "radio_1"], "erba": ["verde_4", "verde_3"]}

var _cells := [[], []]      ## Node3D con terreno e decorazioni di ogni recinto
var _rng := RandomNumberGenerator.new()


func _build_world() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Art.c("notte")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.66, 0.85)
	env.ambient_light_energy = 0.6
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.glow_enabled = true
	env.glow_hdr_threshold = 1.05
	env.glow_intensity = 0.7
	env.glow_bloom = 0.0
	var we := WorldEnvironment.new()
	we.environment = env
	world.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -32, 0)
	sun.light_energy = 1.25
	sun.light_color = Color(1.0, 0.96, 0.88)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 40.0
	world.add_child(sun)
	cam.fov = 40.0
	cam.look_at_from_position(CAM_TARGET + CAM_DIR * 10.0, CAM_TARGET, Vector3.UP)
	world.add_child(cam)
	_rng.seed = 7

	var bw := COL_W * 4.0
	var bd := ROW_D * 2.0 + MID
	# tavolo di lamiera del bunker, con bulloni sul bordo e una macchia di ruggine
	_box(Vector3(0, -0.35, 0), Vector3(bw + 9.0, 0.5, bd + 7.0), Art.c("ferro_2"), 0.0)
	for k in 9:
		for side in [-1.0, 1.0]:
			_ball(Vector3(-bw / 2.0 - 4.2 + k * (bw + 8.4) / 8.0, -0.08, side * (bd / 2.0 + 3.3)), 0.09, Art.c("ferro_4"), false)
	_disc(Vector3(bw / 2.0 + 2.3, -0.09, 2.2), 1.1, Art.c("ruggine_2"), 0.02)
	_disc(Vector3(-bw / 2.0 - 2.6, -0.09, -2.0), 0.8, Art.c("ruggine_1"), 0.02)
	# vassoio di legno del tabellone
	_box(Vector3(0, 0.0, 0), Vector3(bw + 0.7, 0.36, bd + 0.7), Art.c("legno_5"))
	_box(Vector3(0, SURF - 0.06, 0), Vector3(bw + 0.1, 0.1, bd + 0.1), Art.c("legno_3"), 0.0)
	# sentiero di terra tra i due schieramenti
	_box(Vector3(0, SURF - 0.03, 0), Vector3(bw, 0.06, MID), Art.c("legno_8"), 0.0)
	# recinti: terreno e decorazioni (rifatti in refresh() secondo la zona)
	for p in 2:
		for i in 4:
			var n := Node3D.new()
			n.position = cell_center(p, i)
			world.add_child(n)
			_cells[p].append(n)
	# steccati bassi tra le corsie e sui bordi: bordi netti
	for i in range(5):
		var x := -bw / 2.0 + i * COL_W
		for zr in [[-bd / 2.0, -MID / 2.0], [MID / 2.0, bd / 2.0]]:
			_fence(x, zr[0], zr[1])
	# oggetti di scena sul tavolo
	_props(bw, bd)



## Materiale cartoon: colore pieno (o texture a palette), emissione per il bagliore.
func _toon(color: Color, tex: Texture2D = null, glow := 0.0) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = TOON
	m.set_shader_parameter("albedo", color)
	if tex:
		m.set_shader_parameter("albedo_tex", tex)
		m.set_shader_parameter("use_tex", true)
	if glow > 0.0:
		m.set_shader_parameter("emission", color)
		m.set_shader_parameter("emission_energy", glow)
	return m


func _outlined(m: ShaderMaterial, width := 0.035) -> ShaderMaterial:
	var o := ShaderMaterial.new()
	o.shader = OUTLINE
	o.set_shader_parameter("width", width)
	m.next_pass = o
	return m


func _mesh(mesh: Mesh, pos: Vector3, color: Color, outline := 0.035, glow := 0.0, parent: Node3D = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	var m := _toon(color, null, glow)
	mi.material_override = _outlined(m, outline) if outline > 0.0 else m
	(parent if parent else world).add_child(mi)
	return mi


func _box(pos: Vector3, sz: Vector3, color: Color, outline := 0.035, parent: Node3D = null) -> MeshInstance3D:
	var bm := BoxMesh.new()
	bm.size = sz
	return _mesh(bm, pos, color, outline, 0.0, parent)


func _ball(pos: Vector3, r: float, color: Color, outline := true, parent: Node3D = null, glow := 0.0) -> MeshInstance3D:
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	sm.radial_segments = 8
	sm.rings = 4
	return _mesh(sm, pos, color, 0.03 if outline else 0.0, glow, parent)


func _disc(pos: Vector3, r: float, color: Color, h := 0.04, parent: Node3D = null, glow := 0.0) -> MeshInstance3D:
	var cm := CylinderMesh.new()
	cm.top_radius = r
	cm.bottom_radius = r
	cm.height = h
	cm.radial_segments = 9
	return _mesh(cm, pos, color, 0.0, glow, parent)


func _cyl(pos: Vector3, r: float, h: float, color: Color, parent: Node3D = null, outline := 0.03) -> MeshInstance3D:
	var cm := CylinderMesh.new()
	cm.top_radius = r
	cm.bottom_radius = r
	cm.height = h
	cm.radial_segments = 8
	return _mesh(cm, pos, color, outline, 0.0, parent)


func _fence(x: float, z0: float, z1: float) -> void:
	var len := z1 - z0
	_box(Vector3(x, SURF + 0.2, (z0 + z1) / 2.0), Vector3(0.09, 0.08, len), Art.c("legno_6"), 0.025)
	var z := z0 + 0.12
	while z <= z1 + 0.01:
		_box(Vector3(x, SURF + 0.13, z), Vector3(0.13, 0.3, 0.13), Art.c("legno_5"), 0.025)
		z += 0.9


## Importa un modello Kenney (CC0) e gli dà il materiale cartoon con la sua texture a palette.
func _model(path: String, pos: Vector3, s := 1.0, rot := 0.0, glow_tint := Color(0, 0, 0, 0)) -> Node3D:
	var scene: PackedScene = load(path)
	if scene == null:
		return null
	var n: Node3D = scene.instantiate()
	n.position = pos
	n.scale = Vector3.ONE * s
	n.rotation.y = rot
	world.add_child(n)
	for mi: MeshInstance3D in n.find_children("*", "MeshInstance3D", true, false):
		for si in mi.mesh.get_surface_count():
			var orig := mi.mesh.surface_get_material(si) as BaseMaterial3D
			var tex: Texture2D = orig.albedo_texture if orig else null
			var col: Color = orig.albedo_color if orig else Color.WHITE
			mi.set_surface_override_material(si, _outlined(_toon(col, tex), 0.02 / s))
	return n


## Oggetti di scena: scatolette, radio, maschera antigas, nano da giardino, barile, lampada.
func _props(bw: float, bd: float) -> void:
	var L := -bw / 2.0 - 1.4
	var R := bw / 2.0 + 1.4
	# scatolette di fagioli (Kenney Food Kit) e una che brilla
	_model("res://assets/models/props/can.glb", Vector3(L - 0.4, -0.1, 1.6), 1.6, 0.4)
	_model("res://assets/models/props/can-open.glb", Vector3(L + 0.5, -0.1, 2.3), 1.6, -0.7)
	_model("res://assets/models/props/can-small.glb", Vector3(R + 0.6, -0.1, 2.6), 1.7, 0.3)
	_model("res://assets/models/props/soda-can.glb", Vector3(R - 0.2, -0.1, -2.9), 1.5, 1.1)
	_disc(Vector3(L + 0.5, 0.02, 2.3), 0.22, Art.c("radio_1"), 0.05, null, 2.2)
	# barile radioattivo e cassa degli attrezzi (Kenney Survival Kit)
	var barrel := _model("res://assets/models/survival/barrel.glb", Vector3(R + 0.9, -0.1, -0.6), 1.5, 0.2)
	_disc(Vector3(R + 0.9, 1.05, -0.6), 0.45, Art.c("radio_1"), 0.04, null, 2.5)
	_model("res://assets/models/survival/chest.glb", Vector3(L - 0.6, -0.1, -2.4), 1.4, 0.5)
	# radio a transistor
	var radio := Node3D.new()
	radio.position = Vector3(R + 0.4, -0.1, 1.0)
	radio.rotation.y = -0.4
	world.add_child(radio)
	_box(Vector3(0, 0.45, 0), Vector3(1.3, 0.8, 0.5), Art.c("rosso_2"), 0.04, radio)
	_box(Vector3(-0.25, 0.48, 0.26), Vector3(0.62, 0.5, 0.04), Art.c("legno_9"), 0.02, radio)
	_cyl(Vector3(0.38, 0.5, 0.27), 0.18, 0.06, Art.c("ferro_5"), radio).rotation.x = PI / 2.0
	_cyl(Vector3(0.45, 1.25, -0.1), 0.025, 1.0, Art.c("ferro_4"), radio, 0.015).rotation.z = 0.35
	# maschera antigas
	var mask := Node3D.new()
	mask.position = Vector3(L + 0.2, -0.1, 0.0)
	mask.rotation = Vector3(-1.1, 0.5, 0)
	world.add_child(mask)
	_ball(Vector3(0, 0.35, 0), 0.5, Art.c("verde_1"), true, mask)
	for sx in [-0.22, 0.22]:
		_cyl(Vector3(sx, 0.55, 0.38), 0.16, 0.08, Art.c("acqua_5"), mask).rotation.x = PI / 2.0
	_cyl(Vector3(0, 0.2, 0.5), 0.17, 0.3, Art.c("ferro_2"), mask).rotation.x = PI / 2.0
	# nano da giardino
	var gnome := Node3D.new()
	gnome.position = Vector3(L - 0.1, -0.1, -1.0)
	world.add_child(gnome)
	_cyl(Vector3(0, 0.35, 0), 0.32, 0.6, Art.c("acqua_3"), gnome)
	_ball(Vector3(0, 0.82, 0), 0.26, Art.c("pelle_4"), true, gnome)
	_ball(Vector3(0, 0.7, 0.15), 0.2, Art.c("bianco"), true, gnome)
	var hat := CylinderMesh.new()
	hat.top_radius = 0.0
	hat.bottom_radius = 0.3
	hat.height = 0.6
	hat.radial_segments = 8
	_mesh(hat, Vector3(0, 1.25, 0), Art.c("rosso_2"), 0.03, 0.0, gnome)
	# lampada da bunker che illumina il tavolo
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0, 6.0, -2.0)
	lamp.light_color = Art.c("giallo_2")
	lamp.light_energy = 0.6
	lamp.omni_range = 14.0
	world.add_child(lamp)


## Terreno e decorazioni di un recinto, ben distinti per banda.
func _build_cell(p: int, i: int, band: String) -> void:
	var n: Node3D = _cells[p][i]
	for c in n.get_children():
		c.queue_free()
	var cols: Array = TERRAIN.get(band, TERRAIN["erba"])
	var base := Art.c(cols[0])
	var acc := Art.c(cols[1])
	var w := COL_W - 0.14
	var d := ROW_D - 0.12
	_box(Vector3(0, SURF - 0.02, 0), Vector3(w, 0.08, d), base, 0.0, n)
	_rng.seed = hash(band) + p * 31 + i * 7
	match band:
		"porcile":   # fango con pozzanghere
			for k in 3:
				_disc(Vector3(_rng.randf_range(-0.6, 0.6), SURF + 0.03, _rng.randf_range(-1.1, 1.1)), _rng.randf_range(0.22, 0.38), acc, 0.03, n)
		"pollaio":   # paglia sparsa
			for k in 10:
				var b := _box(Vector3(_rng.randf_range(-0.8, 0.8), SURF + 0.04, _rng.randf_range(-1.2, 1.2)), Vector3(0.36, 0.04, 0.06), acc, 0.0, n)
				b.rotation.y = _rng.randf_range(0, PI)
		"stagno":    # acqua con ninfee
			for k in 3:
				_disc(Vector3(_rng.randf_range(-0.6, 0.6), SURF + 0.04, _rng.randf_range(-1.1, 1.1)), 0.2, Art.c("verde_4"), 0.03, n)
			_disc(Vector3(0, SURF + 0.025, 0), 0.6, acc, 0.01, n)
		"patate":    # solchi con germogli
			for k in 3:
				var zz := -0.9 + k * 0.9
				_box(Vector3(0, SURF + 0.06, zz), Vector3(w - 0.2, 0.12, 0.3), acc, 0.0, n)
				for q in 3:
					_ball(Vector3(-0.55 + q * 0.55, SURF + 0.16, zz), 0.07, Art.c("verde_4"), false, n)
		"discarica": # rottami e un copertone
			for k in 4:
				var b := _box(Vector3(_rng.randf_range(-0.7, 0.7), SURF + 0.05, _rng.randf_range(-1.1, 1.1)), Vector3(0.25, 0.08, 0.15), Art.c("ruggine_2") if k % 2 == 0 else acc, 0.02, n)
				b.rotation.y = _rng.randf_range(0, PI)
			var tire := TorusMesh.new()
			tire.inner_radius = 0.12
			tire.outer_radius = 0.24
			tire.rings = 10
			tire.ring_segments = 6
			_mesh(tire, Vector3(0.55, SURF + 0.06, 1.05), Art.c("notte"), 0.0, 0.0, n)
		"cratere":   # terra viola con crepe che brillano
			for k in 3:
				var b := _box(Vector3(_rng.randf_range(-0.6, 0.6), SURF + 0.03, _rng.randf_range(-1.1, 1.1)), Vector3(0.5, 0.02, 0.05), acc, 0.0, n)
				b.rotation.y = _rng.randf_range(0, PI)
				(b.material_override as ShaderMaterial).set_shader_parameter("emission", acc)
				(b.material_override as ShaderMaterial).set_shader_parameter("emission_energy", 2.4)


const MODEL_SCALE := COL_W / 2.0 * 1.3    ## 1 unità del kit ≈ due terzi di recinto: figure ben visibili


## Attore di un recinto: un Node3D con dentro il modello 3D della carta (models/), o la vecchia figura pixel art
## se il modello non esiste ancora. Le animazioni muovono e schiacciano l'attore, non il modello.
func _actor(id: String, p: int, creature: bool) -> Node3D:
	var a := Node3D.new()
	a.rotation.y = 0.0 if p == 0 else PI * 0.0
	var model := Models.build(id)
	var sc := MODEL_SCALE * (1.0 if creature else 0.85)
	if model:
		model.scale = Vector3.ONE * sc
		if p == 1:
			model.rotation.y = -model.rotation.y   # l'avversario si gira dall'altra parte, verso il centro
		a.add_child(model)
		a.set_meta("height", Models.height(model) * sc)
	else:
		var tex := Art.card_tex(id)
		if tex:
			var s := Sprite3D.new()
			s.texture = tex
			s.hframes = maxi(1, tex.get_width() / tex.get_height())
			s.pixel_size = PX * (1.0 if creature else STRUCT_SCALE)
			s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			s.shaded = false
			s.flip_h = p == 1
			s.position.y = tex.get_height() * s.pixel_size / 2.0
			a.add_child(s)
			a.set_meta("height", tex.get_height() * s.pixel_size * 0.82)
	world.add_child(a)
	return a


## Lampo bianco / scurito su tutte le mesh dell'attore (parametri per singolo oggetto dello shader cartoon).
func _set_param(a: Node3D, param: String, v: float) -> void:
	if a == null or not is_instance_valid(a):
		return
	for g: GeometryInstance3D in a.find_children("*", "GeometryInstance3D", true, false):
		if g is Sprite3D:
			if param == "flash":
				(g as Sprite3D).modulate = Color.WHITE.lerp(Color(4, 4, 4), v)
			elif param == "dim":
				(g as Sprite3D).modulate = Color.WHITE.lerp(Color(0.7, 0.7, 0.8), v)
		else:
			g.set_instance_shader_parameter(param, v)


## Avvicina la telecamera finché il tavolo (siepe e scogliera comprese) riempie lo schermo senza uscire.
func _fit_camera() -> void:
	if not has_view():
		return
	var vs := _vsize()
	var bw := COL_W * 4.0
	var bd := ROW_D * 2.0 + MID
	var pts := [Vector3(-bw / 2.0, 0.3, -bd / 2.0 - 0.6), Vector3(bw / 2.0, 0.3, -bd / 2.0 - 0.6),
		Vector3(-bw / 2.0 - 0.3, -0.5, bd / 2.0 + 0.3), Vector3(bw / 2.0 + 0.3, -0.5, bd / 2.0 + 0.3),
		Vector3(0, 0.9, -bd / 2.0 - 0.45),
		Vector3(-bw / 2.0 + COL_W / 2.0, 2.4, -MID / 2.0 - ROW_D / 2.0), Vector3(bw / 2.0 - COL_W / 2.0, 2.4, -MID / 2.0 - ROW_D / 2.0)]   # teste delle figure in fondo
	var dir := CAM_DIR.normalized()
	var lo := 3.0
	var hi := 40.0
	var area := Rect2(Vector2(4, 4), vs - Vector2(8, 8))
	if focus.size.x > 0:
		area = Rect2(global_position + focus.position, focus.size)
	for k in 24:
		var d := (lo + hi) / 2.0
		cam.look_at_from_position(CAM_TARGET + dir * d, CAM_TARGET, Vector3.UP)
		cam.v_offset = _v_offset_for(d, area)
		var ok := true
		for v in pts:
			var sp := cam.unproject_position(v)
			if cam.is_position_behind(v) or not area.has_point(sp):
				ok = false
				break
			for r in avoid:
				if r.has_point(sp - global_position):
					ok = false
			if not ok:
				break
		if ok:
			hi = d
		else:
			lo = d
	cam.look_at_from_position(CAM_TARGET + dir * hi, CAM_TARGET, Vector3.UP)
	cam.v_offset = _v_offset_for(hi, area)
	_cam_rest = cam.transform
	framed.emit()


## Spostamento verticale dell'inquadratura perché il centro del tabellone cada al centro della zona `area`.
func _v_offset_for(d: float, area: Rect2) -> float:
	var vs := _vsize()
	var dy := vs.y / 2.0 - area.get_center().y
	return -dy * 2.0 * d * tan(deg_to_rad(cam.fov) / 2.0) / vs.y


# --- Geometria -----------------------------------------------------------------

## Centro di un recinto sul tavolo (giocatore 0 = fila vicina).
func cell_center(p: int, i: int) -> Vector3:
	var z := (MID / 2.0 + ROW_D / 2.0) * (1.0 if p == 0 else -1.0)
	return Vector3((i - 1.5) * COL_W, 0, z)


func _creature_pos(p: int, i: int) -> Vector3:
	return cell_center(p, i) + Vector3(-0.2, SURF, 0.2 if p == 0 else -0.2)


func _structure_pos(p: int, i: int) -> Vector3:
	return cell_center(p, i) + Vector3(0.5, SURF, 0.85 if p == 0 else -0.85)


## Punto dello schermo (coordinate di questo controllo) di un punto del mondo.
func project(v: Vector3) -> Vector2:
	if not has_view():
		return Vector2.ZERO
	return cam.unproject_position(v) - global_position


## I 4 angoli di un recinto sullo schermo.
func cell_poly(p: int, i: int) -> PackedVector2Array:
	var c := cell_center(p, i)
	var hx := COL_W / 2.0 - 0.05
	var hz := ROW_D / 2.0 - 0.05
	c.y = SURF
	return PackedVector2Array([project(c + Vector3(-hx, 0, -hz)), project(c + Vector3(hx, 0, -hz)),
		project(c + Vector3(hx, 0, hz)), project(c + Vector3(-hx, 0, hz))])


## Punto sopra la testa della creatura (per ATK e Vita), in coordinate di questo controllo.
func head_point(p: int, i: int) -> Vector2:
	var a: Node3D = creature_sprites[p][i]
	var h := 0.9
	if a and is_instance_valid(a):
		h = float(a.get_meta("height", 0.9)) + 0.15
	return project(_creature_pos(p, i) + Vector3(0, h, 0))


# --- Stato del tavolo ------------------------------------------------------------

## Allinea le figure al Match. Le carte nuove arrivano con un salto, quelle sparite muoiono.
func refresh(m: Match) -> void:
	for p in 2:
		for i in 4:
			var l := m.players[p].lanes[i]
			if _zones[p].size() <= i or _zones[p][i] != l.zone:
				if _zones[p].size() <= i:
					_zones[p].resize(4)
				_zones[p][i] = l.zone
				_build_cell(p, i, l.zone)
			_sync(p, i, l.creature, true)
			_sync(p, i, l.structure, false)


func _sync(p: int, i: int, c: CardInst, creature: bool) -> void:
	var shown: Array = _shown if creature else _shown_s
	var arr: Array = creature_sprites if creature else structure_sprites
	if shown[p][i] == c:
		if c and creature:
			_set_param(arr[p][i], "dim", 1.0 if c.helpless else 0.0)
		return
	var old: CardInst = shown[p][i]
	shown[p][i] = c
	if old != null and arr[p][i]:
		_die(arr[p][i])
		arr[p][i] = null
	if c == null:
		return
	var a := _actor(String(c.def.get("id", "")), p, creature)
	var rest := _creature_pos(p, i) if creature else _structure_pos(p, i)
	a.set_meta("rest", rest)
	a.set_meta("phase", float(i) * 1.7 + p * 0.9)
	arr[p][i] = a
	_arrive(a, rest)


## Arrivo: cade dall'alto, schiaccia toccando terra e si rimette in forma, con una nuvola di polvere.
func _arrive(a: Node3D, rest: Vector3) -> void:
	if reduce_motion or not is_inside_tree():
		a.position = rest
		return
	a.position = rest + Vector3(0, 2.4, 0)
	a.scale = Vector3(0.85, 1.2, 0.85)
	var tw := a.create_tween()
	tw.tween_property(a, "position", rest, 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(a, "scale", Vector3(1.3, 0.72, 1.3), 0.06)
	tw.tween_property(a, "scale", Vector3.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_callback(func(): _puff(rest + Vector3(0, 0.05, 0), Art.c("legno_8"), 12, 0.35)).set_delay(0.0)


## Morte: lampo bianco, si schiaccia e sparisce in una nuvoletta radioattiva.
func _die(a: Node3D) -> void:
	if a == null or not is_instance_valid(a):
		return
	if not is_inside_tree() or reduce_motion:
		a.queue_free()
		return
	var tw := a.create_tween()
	tw.tween_interval(0.18)
	tw.tween_method(func(v: float): _set_param(a, "flash", v), 0.0, 1.0, 0.06)
	tw.tween_property(a, "scale", Vector3(1.4, 0.15, 1.4), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func(): _puff(a.position + Vector3(0, 0.2, 0), Art.c("radio_2"), 18, 0.5))
	tw.tween_callback(a.queue_free)


## Attacco: la creatura carica, scatta in avanti verso il recinto di fronte e torna indietro.
func attack(p: int, i: int, hit_target: bool, crit: bool) -> void:
	var a: Node3D = creature_sprites[p][i]
	if a == null or not is_instance_valid(a) or not is_inside_tree():
		return
	if reduce_motion:
		hit(1 - p, i, crit) if hit_target else shake(0.3)
		return
	var rest: Vector3 = a.get_meta("rest", a.position)
	var dir := Vector3(0, 0, -1.0 if p == 0 else 1.0)
	var tw := a.create_tween()
	tw.tween_property(a, "position", rest - dir * 0.3, 0.09).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(a, "scale", Vector3(1.15, 0.85, 1.15), 0.09)
	tw.tween_property(a, "position", rest + dir * (ROW_D * 0.75 if hit_target else ROW_D * 1.1), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(a, "scale", Vector3(0.9, 1.12, 0.9), 0.12)
	tw.tween_callback(func(): hit(1 - p, i, crit) if hit_target else shake(0.45 if not crit else 0.85))
	tw.tween_property(a, "position", rest, 0.26).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(a, "scale", Vector3.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Colpo subito: lampo bianco, tremolio, scintille. Con la Botta Atomica trema anche la telecamera
## e le scintille sono verdi radioattive.
func hit(p: int, i: int, crit: bool) -> void:
	shake(0.85 if crit else 0.35)
	var a: Node3D = creature_sprites[p][i]
	if a == null or not is_instance_valid(a):
		return
	var rest: Vector3 = a.get_meta("rest", a.position)
	var tw := a.create_tween()
	tw.tween_method(func(v: float): _set_param(a, "flash", v), 1.0, 0.0, 0.18)
	var tw2 := a.create_tween()
	for k in 4:
		tw2.tween_property(a, "position", rest + Vector3(0.1 * (1 if k % 2 == 0 else -1), 0, 0), 0.035)
	tw2.tween_property(a, "position", rest, 0.05)
	_puff(rest + Vector3(0, float(a.get_meta("height", 0.8)) * 0.6, 0), Art.c("radio_2") if crit else Art.c("bianco"), 16 if crit else 8, 0.35)


## Scuotere: la creatura si schiaccia e si allunga, con una nuvola di Caos verde.
func wiggle(p: int, i: int) -> void:
	var a: Node3D = creature_sprites[p][i]
	if a == null or not is_instance_valid(a) or reduce_motion:
		return
	var tw := a.create_tween()
	tw.tween_property(a, "scale", Vector3(1.25, 0.8, 1.25), 0.07)
	tw.tween_property(a, "scale", Vector3(0.85, 1.2, 0.85), 0.08)
	tw.tween_property(a, "scale", Vector3.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_puff(a.position + Vector3(0, 0.3, 0), Art.c("radio_1"), 14, 0.45)


## Effetto positivo (cura, +DEF, +ATK): la creatura si gonfia un attimo e manda scintille del colore dell'effetto.
func glow(p: int, i: int, color: Color) -> void:
	var a: Node3D = creature_sprites[p][i]
	if a == null or not is_instance_valid(a) or reduce_motion:
		return
	var tw := a.create_tween()
	tw.tween_method(func(v: float): _set_param(a, "flash", v), 0.0, 0.45, 0.08)
	tw.parallel().tween_property(a, "scale", Vector3(1.12, 1.12, 1.12), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_method(func(v: float): _set_param(a, "flash", v), 0.45, 0.0, 0.2)
	tw.parallel().tween_property(a, "scale", Vector3.ONE, 0.2)
	_puff(a.position + Vector3(0, float(a.get_meta("height", 0.8)) * 0.7, 0), color, 12, 0.5)


## Scossa della telecamera a "trauma": i colpi si sommano e si smorzano (forza = trauma²).
func shake(amount: float) -> void:
	if reduce_motion:
		return
	_trauma = clampf(_trauma + amount, 0.0, 1.0)


func _ready() -> void:
	_fit_camera.call_deferred()


func _process(delta: float) -> void:
	# riposo: le figure pixel cambiano fotogramma, i modelli 3D "respirano" (sempre un po' vivi)
	var tsec := Time.get_ticks_msec() / 1000.0
	var f := int(tsec * Art.FPS)
	for arr in [creature_sprites, structure_sprites]:
		for p in 2:
			for i in 4:
				var a: Node3D = arr[p][i]
				if a == null or not is_instance_valid(a) or a.get_child_count() == 0:
					continue
				var c := a.get_child(0)
				if c is Sprite3D:
					var s3 := c as Sprite3D
					if s3.hframes > 1:
						s3.frame = (f + int(a.get_meta("phase", 0.0))) % s3.hframes
				elif not reduce_motion and arr == creature_sprites:
					var ph: float = a.get_meta("phase", 0.0)
					(c as Node3D).scale = Vector3.ONE * MODEL_SCALE * Vector3(1.0 + 0.02 * sin(tsec * 2.6 + ph), 1.0 - 0.025 * sin(tsec * 2.6 + ph), 1.0)
	if _trauma > 0.0:
		_trauma = maxf(_trauma - 1.6 * delta, 0.0)
		_t += delta * 30.0
		var k := _trauma * _trauma
		cam.transform = _cam_rest.translated_local(Vector3(0.22 * k * sin(_t * 1.7), 0.15 * k * sin(_t * 2.3), 0))
		if _trauma == 0.0:
			cam.transform = _cam_rest


## Nuvoletta di particelle (polvere, fumo, scintille) che si apre e svanisce.
func _puff(pos: Vector3, color: Color, n: int, life: float) -> void:
	if not is_inside_tree():
		return
	var ps := CPUParticles3D.new()
	var qm := QuadMesh.new()
	qm.size = Vector2(0.14, 0.14)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	qm.material = mat
	ps.mesh = qm
	ps.amount = n
	ps.one_shot = true
	ps.explosiveness = 1.0
	ps.lifetime = life
	ps.direction = Vector3(0, 1, 0)
	ps.spread = 70.0
	ps.initial_velocity_min = 1.2
	ps.initial_velocity_max = 2.4
	ps.gravity = Vector3(0, -2.0, 0)
	ps.scale_amount_min = 0.8
	ps.scale_amount_max = 1.6
	var g := Gradient.new()
	g.set_color(0, color)
	g.set_color(1, Color(color, 0.0))
	ps.color_ramp = g
	ps.position = pos
	world.add_child(ps)
	ps.emitting = true
	get_tree().create_timer(life + 0.3).timeout.connect(ps.queue_free)
