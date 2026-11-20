class_name MenuStage
extends Control
## Scena 3D della home: il sopravvissuto scelto su un piedistallo che gira piano, sotto la lampada del bunker,
## con il tavolo e gli oggetti nucleari attorno (ui/bunker_set.gd). Sta nella finestra principale, sotto l'interfaccia.

var world := Node3D.new()
var cam := Camera3D.new()
var _hero: Node3D
var _hero_root := Node3D.new()
var calm := false
const SPOT := Vector3(1.2, 0, 0.6)   ## dove sta il piedistallo


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(world)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Art.c("inchiostro")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.5, 0.56, 0.85)
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.glow_enabled = true
	env.glow_hdr_threshold = 1.15
	env.glow_intensity = 0.45
	var we := WorldEnvironment.new()
	we.environment = env
	world.add_child(we)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-40, 30, 0)
	fill.light_energy = 0.4
	fill.light_color = Color(0.7, 0.78, 1.0)
	world.add_child(fill)
	BunkerSet.build(world, 4.0, 2.4, false)
	# piedistallo: una cassa di legno con il simbolo radioattivo
	var ped := Node3D.new()
	ped.position = SPOT
	world.add_child(ped)
	Kit.outline_w = 0.05
	Kit.box(ped, Vector3(0, 0.25, 0), Vector3(1.6, 0.5, 1.6), Art.c("legno_5"))
	Kit.box(ped, Vector3(0, 0.52, 0), Vector3(1.7, 0.08, 1.7), Art.c("legno_3"))
	BunkerSet.trefoil(ped, Vector3(0, 0.26, 0.81), 0.16)
	Kit.outline_w = Kit.OUT_W
	_hero_root.position = SPOT + Vector3(0, 0.56, 0)
	world.add_child(_hero_root)
	# luce sul personaggio
	var key := SpotLight3D.new()
	key.position = SPOT + Vector3(0.5, 6.0, 3.0)
	key.light_color = Color(1.0, 0.9, 0.72)
	key.light_energy = 3.2
	key.spot_range = 14.0
	key.spot_angle = 22.0
	key.shadow_enabled = true
	world.add_child(key)
	key.look_at_from_position(key.position, SPOT + Vector3(0, 0.8, 0), Vector3.UP)
	cam.fov = 34.0
	world.add_child(cam)
	cam.look_at_from_position(Vector3(0.2, 3.4, 8.0), Vector3(0.2, 1.0, 0), Vector3.UP)
	cam.current = true


## Cambia personaggio: il nuovo cade sul piedistallo con una piroetta e una nuvola.
func show_hero(id: String, dir := 0) -> void:
	if _hero:
		_hero.queue_free()
	_hero = Models.build(id)
	if _hero == null:
		return
	_hero.scale = Vector3.ONE * 1.4
	_hero_root.add_child(_hero)
	if calm or not is_inside_tree():
		return
	_hero_root.position.y = SPOT.y + 0.56 + 1.2
	_hero_root.rotation.y = -1.2 * (1 if dir >= 0 else -1)
	var tw := _hero_root.create_tween().set_parallel(true)
	tw.tween_property(_hero_root, "position:y", SPOT.y + 0.56, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(_hero_root, "rotation:y", 0.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(_d: float) -> void:
	if _hero and not calm:
		var t := Time.get_ticks_msec() / 1000.0
		_hero.rotation.y = -0.35 + sin(t * 0.6) * 0.35
		_hero.scale = Vector3.ONE * 1.4 * Vector3(1.0 + 0.012 * sin(t * 2.4), 1.0 - 0.015 * sin(t * 2.4), 1.0)


## Punto dello schermo sopra/accanto al personaggio (per posizionare le frecce).
func hero_screen_rect() -> Rect2:
	if not is_inside_tree():
		return Rect2()
	var a := cam.unproject_position(SPOT + Vector3(-1.5, 0.6, 0))
	var b := cam.unproject_position(SPOT + Vector3(1.5, 2.6, 0))
	return Rect2(Vector2(minf(a.x, b.x), minf(a.y, b.y)), (b - a).abs())
