class_name Kit
extends RefCounted
## Kit di forme cartoon low-poly per creature, strutture e sopravvissuti (strada A, D-016).
## Tutto con ombre a gradini (shaders/toon.gdshader) e contorno nero (shaders/outline.gdshader).
## Convenzioni (rispettale in tutte le ricette, così le taglie restano vere):
## - 1 unità = mezzo recinto. La creatura poggia su y = 0, guarda verso +Z (verso la telecamera / chi gioca),
##   leggermente girata a sinistra (rotazione y di circa -0,35) se la ricetta non dice altro.
## - Altezze: taglia S ~0,7–0,9 · M ~1,0–1,3 · L ~1,5–2,0 · persone ~1,2 (la Nonna 1,3, il Veterinario 1,4).
## - Forme tozze: corpo grande e tondo, testa grande, zampe corte, occhi grandi (bianco + pupilla nera).
## - Colori dalla palette (Art.c), 3–5 colori per modello; il verde radio (radio_1/radio_2) solo per le mutazioni,
##   con glow > 1 per il bagliore.

const TOON := preload("res://shaders/toon.gdshader")
const OUTLINE := preload("res://shaders/outline.gdshader")
## Spessore del contorno, come frazione dell'altezza dello schermo: uguale per tutto (D-020).
## Lo strumento delle foto lo alza un po', perché le foto delle carte vengono rimpicciolite.
static var outline_thickness := 0.0058

static var _mats: Dictionary = {}


## Materiale cartoon (condiviso per colore). `glow` > 1 accende il bagliore (bloom).
static func mat(color: Color, glow := 0.0, outline := true) -> ShaderMaterial:
	var key := "%s|%.2f|%s|%.4f" % [color.to_html(), glow, outline, outline_thickness]
	if _mats.has(key):
		return _mats[key]
	var m := ShaderMaterial.new()
	m.shader = TOON
	m.set_shader_parameter("albedo", color)
	if glow > 0.0:
		m.set_shader_parameter("emission", color)
		m.set_shader_parameter("emission_energy", glow)
	if outline:
		var o := ShaderMaterial.new()
		o.shader = OUTLINE
		o.set_shader_parameter("thickness", outline_thickness)
		m.next_pass = o
	_mats[key] = m
	return m


static func _add(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color, scl := Vector3.ONE, rot := Vector3.ZERO, glow := 0.0, outline := true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.scale = scl
	mi.rotation = rot
	mi.material_override = mat(color, glow, outline)
	parent.add_child(mi)
	return mi


## Ellissoide (corpo, testa, guance): `size` = diametri x, y, z.
static func blob(parent: Node3D, pos: Vector3, size: Vector3, color: Color, rot := Vector3.ZERO, glow := 0.0) -> MeshInstance3D:
	var sm := SphereMesh.new()
	sm.radius = 0.5
	sm.height = 1.0
	sm.radial_segments = 10
	sm.rings = 6
	return _add(parent, sm, pos, color, size, rot, glow)


static func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, rot := Vector3.ZERO, glow := 0.0) -> MeshInstance3D:
	var bm := BoxMesh.new()
	bm.size = Vector3.ONE
	return _add(parent, bm, pos, color, size, rot, glow)


## Cilindro (zampe, colli, tubi): asse lungo y.
static func cyl(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color, rot := Vector3.ZERO, top := -1.0) -> MeshInstance3D:
	var cm := CylinderMesh.new()
	cm.top_radius = radius if top < 0.0 else top
	cm.bottom_radius = radius
	cm.height = height
	cm.radial_segments = 8
	cm.rings = 1
	return _add(parent, cm, pos, color, Vector3.ONE, rot)


## Cono (becchi, orecchie, cappelli, corna): punta verso +y prima della rotazione.
static func cone(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color, rot := Vector3.ZERO) -> MeshInstance3D:
	var cm := CylinderMesh.new()
	cm.top_radius = 0.0
	cm.bottom_radius = radius
	cm.height = height
	cm.radial_segments = 8
	cm.rings = 1
	return _add(parent, cm, pos, color, Vector3.ONE, rot)


static func torus(parent: Node3D, pos: Vector3, inner: float, outer: float, color: Color, rot := Vector3.ZERO) -> MeshInstance3D:
	var tm := TorusMesh.new()
	tm.inner_radius = inner
	tm.outer_radius = outer
	tm.rings = 12
	tm.ring_segments = 6
	return _add(parent, tm, pos, color, Vector3.ONE, rot)


## Occhio cartoon: bianco + pupilla nera che guarda nella direzione `look` (in locale). `r` = raggio del bianco.
static func eye(parent: Node3D, pos: Vector3, r: float, look := Vector3(0, 0, 1), mutant := false) -> Node3D:
	var e := Node3D.new()
	e.position = pos
	parent.add_child(e)
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	sm.radial_segments = 10
	sm.rings = 6
	_add(e, sm, Vector3.ZERO, Art.c("bianco"), Vector3.ONE, Vector3.ZERO, 0.0, true)
	var pm := SphereMesh.new()
	pm.radius = r * 0.55
	pm.height = r * 1.1
	pm.radial_segments = 8
	pm.rings = 4
	var pc := Art.c("radio_1") if mutant else Art.c("inchiostro")
	_add(e, pm, look.normalized() * r * 0.62, pc, Vector3.ONE, Vector3.ZERO, 2.2 if mutant else 0.0, false)
	return e


## Due occhi simmetrici sulla faccia (centro `pos`, distanza `gap`).
static func eyes(parent: Node3D, pos: Vector3, gap: float, r: float, look := Vector3(0, 0, 1)) -> void:
	eye(parent, pos + Vector3(-gap / 2.0, 0, 0), r, look)
	eye(parent, pos + Vector3(gap / 2.0, 0, 0), r, look)


## Quattro zampe tozze sotto un corpo largo `w` e lungo `l` (asse z), alte `h`.
static func legs4(parent: Node3D, w: float, l: float, h: float, color: Color, r := 0.07) -> void:
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			cyl(parent, Vector3(sx * w * 0.3, h / 2.0, sz * l * 0.3), r, h, color)


## Due zampette (uccelli, persone).
static func legs2(parent: Node3D, gap: float, h: float, color: Color, r := 0.04) -> void:
	for sx in [-1.0, 1.0]:
		cyl(parent, Vector3(sx * gap / 2.0, h / 2.0, 0), r, h, color)


## Macchia radioattiva che brilla (mutazione), appoggiata sulla superficie in `pos`.
static func radio_spot(parent: Node3D, pos: Vector3, r := 0.08) -> void:
	blob(parent, pos, Vector3(r * 2.0, r * 1.2, r * 2.0), Art.c("radio_1"), Vector3.ZERO, 2.6)


## Modello del Food Kit di Kenney (CC0) con materiali cartoon: carrot, beet, radish, pumpkin, onion, eggplant...
static func food(parent: Node3D, name: String, pos: Vector3, s := 1.0, rot := Vector3.ZERO) -> Node3D:
	var scene: PackedScene = load("res://assets/models/food/%s.glb" % name)
	if scene == null:
		return null
	var n: Node3D = scene.instantiate()
	n.position = pos
	n.scale = Vector3.ONE * s
	n.rotation = rot
	parent.add_child(n)
	for mi: MeshInstance3D in n.find_children("*", "MeshInstance3D", true, false):
		for si in mi.mesh.get_surface_count():
			var orig := mi.mesh.surface_get_material(si) as BaseMaterial3D
			var m := ShaderMaterial.new()
			m.shader = TOON
			m.set_shader_parameter("albedo", orig.albedo_color if orig else Color.WHITE)
			if orig and orig.albedo_texture:
				m.set_shader_parameter("albedo_tex", orig.albedo_texture)
				m.set_shader_parameter("use_tex", true)
			var o := ShaderMaterial.new()
			o.shader = OUTLINE
			o.set_shader_parameter("thickness", outline_thickness)
			m.next_pass = o
			mi.set_surface_override_material(si, m)
	prepare_outlines(n)
	return n


## Radice di un modello: un Node3D con nome, già girato di tre quarti verso sinistra.
static func root(id: String, turn := -0.35) -> Node3D:
	var n := Node3D.new()
	n.name = id
	n.rotation.y = turn
	return n


# --- contorni compatti (D-020) ---------------------------------------------------------------
## Il contorno è il modello gonfiato lungo le normali. Ma casse, cilindri e modelli low-poly hanno le normali
## "spezzate" agli spigoli (una per faccia): gonfiando lungo quelle, il guscio si apre e il contorno si stacca.
## Qui ogni mesh con contorno riceve, nel colore dei vertici, la normale MEDIA di tutti i vertici nello stesso
## punto: il guscio resta chiuso e il contorno aderisce agli spigoli. Lo shader del contorno usa quella.
## Va chiamata dopo aver costruito un modello o una scena (Models.build, Board3D, BunkerSet la chiamano già).

static var _smooth_cache: Dictionary = {}


static func prepare_outlines(root: Node) -> void:
	var list: Array = root.find_children("*", "MeshInstance3D", true, false)
	if root is MeshInstance3D:
		list.append(root)
	for mi: MeshInstance3D in list:
		if mi.mesh == null or mi.has_meta("smooth") or not _has_outline(mi):
			continue
		var count := mi.get_surface_override_material_count()
		var overrides := []
		for s in count:
			overrides.append(mi.get_surface_override_material(s))
		mi.mesh = smoothed(mi.mesh)
		for s in mini(count, overrides.size()):
			if overrides[s]:
				mi.set_surface_override_material(s, overrides[s])
		mi.set_meta("smooth", true)


static func _has_outline(mi: MeshInstance3D) -> bool:
	var mats: Array = [mi.material_override]
	for s in mi.get_surface_override_material_count():
		mats.append(mi.get_surface_override_material(s))
	for m in mats:
		var mm := m as Material
		while mm:
			if mm is ShaderMaterial and (mm as ShaderMaterial).shader == OUTLINE:
				return true
			mm = mm.next_pass
	return false


static func _mesh_key(mesh: Mesh) -> String:
	if mesh is SphereMesh:
		var m := mesh as SphereMesh
		return "S%.4f|%.4f|%d|%d|%s" % [m.radius, m.height, m.radial_segments, m.rings, m.is_hemisphere]
	if mesh is BoxMesh:
		var b := mesh as BoxMesh
		return "B%s" % [b.size]
	if mesh is CylinderMesh:
		var c := mesh as CylinderMesh
		return "C%.4f|%.4f|%.4f|%d|%d" % [c.top_radius, c.bottom_radius, c.height, c.radial_segments, c.rings]
	if mesh is TorusMesh:
		var t := mesh as TorusMesh
		return "T%.4f|%.4f|%d|%d" % [t.inner_radius, t.outer_radius, t.rings, t.ring_segments]
	if mesh is PrismMesh:
		var p := mesh as PrismMesh
		return "P%s|%.3f" % [p.size, p.left_to_right]
	return "I%d" % mesh.get_instance_id()


## Copia della mesh con la normale media nel colore dei vertici (rgb = normale * 0,5 + 0,5).
static func smoothed(mesh: Mesh) -> Mesh:
	var key := _mesh_key(mesh)
	if _smooth_cache.has(key):
		return _smooth_cache[key]
	var out := ArrayMesh.new()
	for s in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(s)
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL] if arrays[Mesh.ARRAY_NORMAL] != null else PackedVector3Array()
		var sums := {}
		for k in verts.size():
			var q := Vector3i((verts[k] * 2000.0).round())
			var nrm := normals[k] if k < normals.size() else Vector3.UP
			sums[q] = sums.get(q, Vector3.ZERO) + nrm
		var cols := PackedColorArray()
		cols.resize(verts.size())
		for k in verts.size():
			var q := Vector3i((verts[k] * 2000.0).round())
			var d: Vector3 = sums[q]
			if d.length_squared() < 1e-6:
				d = normals[k] if k < normals.size() else Vector3.UP
			d = d.normalized()
			cols[k] = Color(d.x * 0.5 + 0.5, d.y * 0.5 + 0.5, d.z * 0.5 + 0.5, 1.0)
		arrays[Mesh.ARRAY_COLOR] = cols
		out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		var sm := mesh.surface_get_material(s)
		if sm:
			out.surface_set_material(s, sm)
	_smooth_cache[key] = out
	return out
