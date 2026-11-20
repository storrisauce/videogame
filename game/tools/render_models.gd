extends SceneTree
## Fotografa i modelli 3D (models/) su sfondo trasparente, di tre quarti, con la luce del tavolo.
## Serve per controllarli a occhio e per creare le illustrazioni delle carte e i ritratti.
##   godot --path game --script res://tools/render_models.gd -- <cartella> [--bake] [id ...]
## Senza id: tutte le carte e tutti i sopravvissuti. Con --bake salva anche in res://assets/art3d/<id>.png
## (le illustrazioni usate dal gioco). Serve una finestra (non --headless): la grafica deve disegnare davvero.

const SIZE := 320


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out := args[0] if args.size() > 0 else "user://render"
	var bake := args.has("--bake")
	var ids: Array = []
	for a in args.slice(1):
		if a != "--bake":
			ids.append(a)
	if ids.is_empty():
		var db := CardDB.load_default()
		ids = db.cards.keys() + db.heroes.keys()
	DirAccess.make_dir_recursive_absolute(out)
	if bake:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/art3d"))
	var vp := SubViewport.new()
	vp.size = Vector2i(SIZE, SIZE)
	vp.transparent_bg = true
	vp.own_world_3d = true
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var env := Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.66, 0.85)
	env.ambient_light_energy = 0.6
	env.glow_enabled = true
	env.glow_hdr_threshold = 1.05
	env.glow_intensity = 0.7
	var we := WorldEnvironment.new()
	we.environment = env
	vp.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -32, 0)
	sun.light_energy = 1.25
	sun.light_color = Color(1.0, 0.96, 0.88)
	vp.add_child(sun)
	var cam := Camera3D.new()
	cam.fov = 30.0
	vp.add_child(cam)
	await process_frame
	var done := 0
	for id: String in ids:
		var model := Models.build(id)
		if model == null:
			continue
		vp.add_child(model)
		await process_frame
		var aabb := _aabb(model)
		var c := aabb.get_center()
		var r := maxf(aabb.size.length() * 0.5, 0.3)
		var dist := r / sin(deg_to_rad(cam.fov) * 0.5) * 1.02
		var dir := Vector3(0.0, 0.42, 1.0).normalized()
		cam.look_at_from_position(c + dir * dist, c, Vector3.UP)
		for f in 4:
			await process_frame
		await RenderingServer.frame_post_draw
		var img := vp.get_texture().get_image()
		# ritaglio attorno al modello (con un piccolo margine), così nelle carte appare grande
		var used := img.get_used_rect().grow(6).intersection(Rect2i(Vector2i.ZERO, img.get_size()))
		if used.size.x > 8 and used.size.y > 8:
			img = img.get_region(used)
		img.save_png(out.path_join(id + ".png"))
		if bake:
			img.save_png(ProjectSettings.globalize_path("res://assets/art3d/%s.png" % id))
		model.queue_free()
		done += 1
	print("render_models: %d modelli in %s%s" % [done, out, " (+ assets/art3d)" if bake else ""])
	quit(0)


func _aabb(n: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for mi: MeshInstance3D in n.find_children("*", "MeshInstance3D", true, false):
		var b := mi.global_transform * mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box
