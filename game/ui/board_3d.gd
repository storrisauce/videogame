class_name Board3D
extends SubViewportContainer
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

var vp := SubViewport.new()
var cam := Camera3D.new()
var world := Node3D.new()
var creature_sprites := [[null, null, null, null], [null, null, null, null]]
var structure_sprites := [[null, null, null, null], [null, null, null, null]]
var _shown := [[null, null, null, null], [null, null, null, null]]      ## CardInst mostrata per recinto (creatura)
var _shown_s := [[null, null, null, null], [null, null, null, null]]    ## struttura
var _zones := [[], []]
var _ground: Array = [[], []]
var _trauma := 0.0
var _cam_rest := Transform3D()
var _t := 0.0
var reduce_motion := false
var focus := Rect2()     ## zona dello schermo (coordinate del controllo) in cui il tabellone deve stare


func _init() -> void:
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	vp.own_world_3d = true
	vp.msaa_3d = Viewport.MSAA_DISABLED
	vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	vp.handle_input_locally = false
	add_child(vp)
	vp.add_child(world)
	_build_world()


# --- Costruzione ---------------------------------------------------------------

func _build_world() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Art.c("verde_3")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.85, 0.88, 1.0)
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	var we := WorldEnvironment.new()
	we.environment = env
	world.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-58, -35, 0)
	sun.light_energy = 0.9
	sun.shadow_enabled = true
	world.add_child(sun)
	# telecamera dietro la tua fila, inclinata di circa 52 gradi
	cam.fov = 44.0
	cam.look_at_from_position(CAM_TARGET + CAM_DIR * 10.0, CAM_TARGET, Vector3.UP)
	world.add_child(cam)
	vp.size_changed.connect(_fit_camera)
	_cam_rest = cam.transform
	cam.current = true

	var bw := COL_W * 4.0
	var bd := ROW_D * 2.0 + MID
	# prato tutto intorno (sotto l'altopiano)
	_plane(Vector3(0, -1.6, 0), Vector2(60, 60), Art.terrain_tex("erba"), 2.0)
	# altopiano: fianchi di terra e labbro d'erba
	_box(Vector3(0, -0.8, 0), Vector3(bw + 0.5, 1.6, bd + 0.5), Art.c("legno_4"))
	_box(Vector3(0, -0.06, 0), Vector3(bw + 0.62, 0.12, bd + 0.62), Art.c("verde_3"))
	for k in 6:   # strati di roccia sul fronte della scogliera
		_box(Vector3(-bw / 2.0 + 0.6 + k * (bw - 1.2) / 5.0, -0.7 - (k % 2) * 0.35, bd / 2.0 + 0.26), Vector3(0.9, 0.12, 0.02), Art.c("legno_3"))
	# erba sopra l'altopiano (bordo attorno ai recinti)
	_plane(Vector3(0, 0.001, 0), Vector2(bw + 0.6, bd + 0.6), Art.terrain_tex("erba"), 2.0)
	# sentiero di terra
	_plane(Vector3(0, 0.004, 0), Vector2(bw, MID), Art.terrain_tex("pollaio"), 2.0)
	# recinti: un piano per terreno, cambiato in refresh() secondo le zone
	for p in 2:
		for i in 4:
			var c := cell_center(p, i)
			var mi := _plane(Vector3(c.x, 0.006, c.z), Vector2(COL_W - 0.12, ROW_D - 0.1), Art.terrain_tex("erba"), 2.0)
			_ground[p].append(mi)
	# steccati tra i recinti e ai bordi
	for i in range(5):
		var x := -bw / 2.0 + i * COL_W
		for zr in [[-bd / 2.0, -MID / 2.0], [MID / 2.0, bd / 2.0]]:
			_fence(x, zr[0], zr[1])
	# siepe in fondo
	var hx := -bw / 2.0 - 0.3
	var k2 := 0
	while hx <= bw / 2.0 + 0.3:
		var r := 0.42 + 0.08 * float(k2 % 3)
		_ball(Vector3(hx, r * 0.7, -bd / 2.0 - 0.45), r, Art.c("verde_2"))
		hx += 0.55
		k2 += 1
	# qualche albero ai lati, per la profondità
	for side in [-1.0, 1.0]:
		for z in [-2.6, 0.2, 2.8]:
			_tree(Vector3(side * (bw / 2.0 + 1.5 + absf(z) * 0.15), -1.6, z))
	# figure dei recinti
	for p in 2:
		for i in 4:
			creature_sprites[p][i] = _sprite()
			structure_sprites[p][i] = _sprite()


func _mat(color: Color, tex: Texture2D = null, uv := Vector2.ONE, shaded := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	if tex:
		m.albedo_texture = tex
		m.uv1_scale = Vector3(uv.x, uv.y, 1)
		m.texture_repeat = true
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	m.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL if shaded else BaseMaterial3D.SHADING_MODE_UNSHADED
	return m


## Piano orizzontale con un terreno ripetuto: `tile` = unità del mondo per una piastrella da 32 px.
func _plane(pos: Vector3, sz: Vector2, tex: Texture2D, tile: float) -> MeshInstance3D:
	var pm := PlaneMesh.new()
	pm.size = sz
	var mi := MeshInstance3D.new()
	mi.mesh = pm
	mi.position = pos
	mi.material_override = _mat(Color.WHITE, tex, sz / tile)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(mi)
	return mi


func _box(pos: Vector3, sz: Vector3, color: Color, shaded := false) -> MeshInstance3D:
	var bm := BoxMesh.new()
	bm.size = sz
	var mi := MeshInstance3D.new()
	mi.mesh = bm
	mi.position = pos
	mi.material_override = _mat(color, null, Vector2.ONE, shaded)
	world.add_child(mi)
	return mi


func _ball(pos: Vector3, r: float, color: Color) -> void:
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 1.6
	sm.radial_segments = 10
	sm.rings = 5
	var mi := MeshInstance3D.new()
	mi.mesh = sm
	mi.position = pos
	mi.material_override = _mat(color, null, Vector2.ONE, true)
	world.add_child(mi)


func _fence(x: float, z0: float, z1: float) -> void:
	var len := z1 - z0
	_box(Vector3(x, 0.32, (z0 + z1) / 2.0), Vector3(0.1, 0.1, len), Art.c("legno_6"), true)
	_box(Vector3(x, 0.16, (z0 + z1) / 2.0), Vector3(0.08, 0.08, len), Art.c("legno_5"), true)
	var z := z0 + 0.1
	while z <= z1 + 0.01:
		_box(Vector3(x, 0.22, z), Vector3(0.16, 0.44, 0.16), Art.c("legno_5"), true)
		z += 1.0


func _tree(pos: Vector3) -> void:
	_box(pos + Vector3(0, 0.6, 0), Vector3(0.3, 1.2, 0.3), Art.c("legno_3"), true)
	_ball(pos + Vector3(0, 1.75, 0), 0.95, Art.c("verde_2"))
	_ball(pos + Vector3(-0.2, 2.15, 0.15), 0.6, Art.c("verde_3"))


func _sprite() -> Sprite3D:
	var s := Sprite3D.new()
	s.pixel_size = PX
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	s.shaded = false
	s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	s.centered = true
	s.visible = false
	s.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(s)
	return s


## Avvicina la telecamera finché il tavolo (siepe e scogliera comprese) riempie lo schermo senza uscire.
func _fit_camera() -> void:
	if vp.size.x <= 16 or vp.size.y <= 16 or not cam.is_inside_tree():
		return
	var bw := COL_W * 4.0
	var bd := ROW_D * 2.0 + MID
	var pts := [Vector3(-bw / 2.0, 0.3, -bd / 2.0 - 0.6), Vector3(bw / 2.0, 0.3, -bd / 2.0 - 0.6),
		Vector3(-bw / 2.0 - 0.3, -0.5, bd / 2.0 + 0.3), Vector3(bw / 2.0 + 0.3, -0.5, bd / 2.0 + 0.3),
		Vector3(0, 0.9, -bd / 2.0 - 0.45),
		Vector3(-bw / 2.0 + COL_W / 2.0, 2.4, -MID / 2.0 - ROW_D / 2.0), Vector3(bw / 2.0 - COL_W / 2.0, 2.4, -MID / 2.0 - ROW_D / 2.0)]   # teste delle figure in fondo
	var dir := CAM_DIR.normalized()
	var lo := 3.0
	var hi := 40.0
	var area := Rect2(Vector2(4, 4), Vector2(vp.size) - Vector2(8, 8))
	if focus.size.x > 0:
		var k := Vector2(vp.size) / size
		area = Rect2(focus.position * k, focus.size * k)
	for k in 24:
		var d := (lo + hi) / 2.0
		cam.look_at_from_position(CAM_TARGET + dir * d, CAM_TARGET, Vector3.UP)
		cam.v_offset = _v_offset_for(d, area)
		var ok := true
		for v in pts:
			if cam.is_position_behind(v) or not area.has_point(cam.unproject_position(v)):
				ok = false
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
	var dy := vp.size.y / 2.0 - area.get_center().y
	return -dy * 2.0 * d * tan(deg_to_rad(cam.fov) / 2.0) / float(vp.size.y)


# --- Geometria -----------------------------------------------------------------

## Centro di un recinto sul tavolo (giocatore 0 = fila vicina).
func cell_center(p: int, i: int) -> Vector3:
	var z := (MID / 2.0 + ROW_D / 2.0) * (1.0 if p == 0 else -1.0)
	return Vector3((i - 1.5) * COL_W, 0, z)


func _creature_pos(p: int, i: int) -> Vector3:
	return cell_center(p, i) + Vector3(-0.3, 0, 0.15 if p == 0 else -0.15)


func _structure_pos(p: int, i: int) -> Vector3:
	return cell_center(p, i) + Vector3(0.62, 0, 0.6 if p == 0 else -0.6)


## Punto dello schermo (coordinate di questo controllo) di un punto del mondo.
func project(v: Vector3) -> Vector2:
	if not is_inside_tree() or vp.size.x <= 0:
		return Vector2.ZERO
	return cam.unproject_position(v) * (size / Vector2(vp.size))


## I 4 angoli di un recinto sullo schermo.
func cell_poly(p: int, i: int) -> PackedVector2Array:
	var c := cell_center(p, i)
	var hx := COL_W / 2.0 - 0.05
	var hz := ROW_D / 2.0 - 0.05
	return PackedVector2Array([project(c + Vector3(-hx, 0, -hz)), project(c + Vector3(hx, 0, -hz)),
		project(c + Vector3(hx, 0, hz)), project(c + Vector3(-hx, 0, hz))])


## Punto sopra la testa della creatura (per ATK e Vita), in coordinate di questo controllo.
func head_point(p: int, i: int) -> Vector2:
	var s: Sprite3D = creature_sprites[p][i]
	var h := 1.0
	if s and s.texture:
		h = _visible_height(s.texture) * PX + 0.15
	return project(_creature_pos(p, i) + Vector3(0, h, 0))


func _visible_height(t: Texture2D) -> float:
	# altezza utile dello sprite: quasi tutti hanno aria in alto, quindi ~80% del fotogramma
	return t.get_height() * 0.82


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
				var mi: MeshInstance3D = _ground[p][i]
				(mi.material_override as StandardMaterial3D).albedo_texture = Art.terrain_tex(l.zone)
			_sync(p, i, l.creature, true)
			_sync(p, i, l.structure, false)


func _sync(p: int, i: int, c: CardInst, creature: bool) -> void:
	var shown: Array = _shown if creature else _shown_s
	var spr: Sprite3D = creature_sprites[p][i] if creature else structure_sprites[p][i]
	if shown[p][i] == c:
		if c and creature:
			spr.modulate = Color(0.75, 0.75, 0.85) if c.helpless else Color.WHITE
		return
	var old: CardInst = shown[p][i]
	shown[p][i] = c
	if old != null:
		_die(spr, p, creature)
		spr = _sprite()
		if creature:
			creature_sprites[p][i] = spr
		else:
			structure_sprites[p][i] = spr
	if c == null:
		return
	var tex := Art.card_tex(c.def.get("id", ""))
	if tex == null:
		return
	spr.texture = tex
	spr.hframes = maxi(1, tex.get_width() / tex.get_height())
	spr.flip_h = p == 1
	var sc := 1.0 if creature else STRUCT_SCALE
	spr.pixel_size = PX * sc
	var base := (_creature_pos(p, i) if creature else _structure_pos(p, i)) + Vector3(0, tex.get_height() * PX * sc / 2.0, 0)
	spr.set_meta("rest", base)
	spr.set_meta("phase", i + p * 2)
	spr.visible = true
	_arrive(spr, base)


## Arrivo: cade dall'alto con un piccolo rimbalzo e uno schiacciamento quando tocca terra.
func _arrive(spr: Sprite3D, rest: Vector3) -> void:
	if reduce_motion or not is_inside_tree():
		spr.position = rest
		spr.modulate.a = 1.0
		return
	spr.position = rest + Vector3(0, 2.2, 0)
	spr.modulate.a = 0.0
	spr.scale = Vector3(0.9, 1.15, 1)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(spr, "position", rest, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(spr, "modulate:a", 1.0, 0.12)
	tw.chain().tween_property(spr, "scale", Vector3(1.22, 0.8, 1), 0.06)
	tw.chain().tween_property(spr, "scale", Vector3.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_puff(rest - Vector3(0, spr.texture.get_height() * spr.pixel_size / 2.0, 0), Art.c("legno_8"), 8, 0.28)


## Morte: un attimo bianco, si schiaccia e sparisce in una nuvoletta.
func _die(spr: Sprite3D, p: int, creature: bool) -> void:
	if not is_inside_tree() or reduce_motion:
		spr.queue_free()
		return
	var tw := create_tween()
	tw.tween_interval(0.18)
	tw.tween_property(spr, "modulate", Color(4, 4, 4, 1), 0.05)
	tw.tween_property(spr, "scale", Vector3(1.35, 0.25, 1), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(spr, "modulate:a", 0.0, 0.18)
	tw.tween_callback(func(): _puff(spr.position, Art.c("ferro_5"), 14, 0.45))
	tw.tween_callback(spr.queue_free)


## Attacco: la creatura scatta in avanti verso il recinto di fronte e torna indietro.
func attack(p: int, i: int, hit_target: bool, crit: bool) -> void:
	var spr: Sprite3D = creature_sprites[p][i]
	if spr == null or not spr.visible or not is_inside_tree():
		return
	var rest: Vector3 = spr.get_meta("rest", spr.position)
	var dir := Vector3(0, 0, -1.0 if p == 0 else 1.0)
	if reduce_motion:
		hit(1 - p, i, crit)
		return
	var tw := create_tween()
	tw.tween_property(spr, "position", rest - dir * 0.25, 0.08).set_ease(Tween.EASE_OUT)   # carica
	tw.tween_property(spr, "position", rest + dir * (1.4 if hit_target else 2.2), 0.11).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func(): hit(1 - p, i, crit) if hit_target else shake(0.35 if not crit else 0.8))
	tw.tween_property(spr, "position", rest, 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## Colpo subito: lampo bianco, piccolo tremolio, polvere. Con la Botta Atomica anche la telecamera trema.
func hit(p: int, i: int, crit: bool) -> void:
	var spr: Sprite3D = creature_sprites[p][i]
	shake(0.85 if crit else 0.32)
	if spr == null or not spr.visible:
		return
	var rest: Vector3 = spr.get_meta("rest", spr.position)
	var tw := create_tween()
	tw.tween_property(spr, "modulate", Color(4, 4, 4, 1), 0.04)
	tw.tween_property(spr, "modulate", Color.WHITE, 0.12)
	var tw2 := create_tween()
	for k in 4:
		tw2.tween_property(spr, "position", rest + Vector3(0.09 * (1 if k % 2 == 0 else -1), 0, 0), 0.035)
	tw2.tween_property(spr, "position", rest, 0.05)
	_puff(rest, Art.c("radio_2") if crit else Art.c("bianco"), 10 if crit else 6, 0.3)


## Scossa: la creatura si schiaccia e si allunga (Scuotere).
func wiggle(p: int, i: int) -> void:
	var spr: Sprite3D = creature_sprites[p][i]
	if spr == null or not spr.visible or reduce_motion:
		return
	var tw := create_tween()
	tw.tween_property(spr, "scale", Vector3(1.2, 0.85, 1), 0.07)
	tw.tween_property(spr, "scale", Vector3(0.88, 1.15, 1), 0.08)
	tw.tween_property(spr, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_puff(spr.position, Art.c("radio_1"), 8, 0.35)


## Scossa della telecamera a "trauma": i colpi si sommano e si smorzano (forza = trauma²).
func shake(amount: float) -> void:
	if reduce_motion:
		return
	_trauma = clampf(_trauma + amount, 0.0, 1.0)


func _ready() -> void:
	_fit_camera.call_deferred()


func _process(delta: float) -> void:
	# fotogrammi dell'animazione di riposo
	var f := int(Time.get_ticks_msec() / 1000.0 * Art.FPS)
	for arr in [creature_sprites, structure_sprites]:
		for p in 2:
			for i in 4:
				var s: Sprite3D = arr[p][i]
				if s and s.visible and s.hframes > 1:
					s.frame = (f + int(s.get_meta("phase", 0))) % s.hframes
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
