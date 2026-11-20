extends SceneTree
## Icona dell'app (1024×1024, senza trasparenza come vuole iOS): una creatura mutante su un bagliore radioattivo.
## godot --headless --path game --script res://tools/make_icon.gd -- [id_creatura]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var id := args[0] if args.size() > 0 else "maiale_in_lamiera"
	var S := 1024
	var img := Image.create(S, S, false, Image.FORMAT_RGBA8)
	var bg := Color("#262b44")
	var glow := Color("#a3e048")
	var c := Vector2(S / 2.0, S * 0.55)
	for y in S:
		for x in S:
			var d := Vector2(x, y).distance_to(c) / (S * 0.5)
			var col := bg
			if d < 0.78:
				col = bg.lerp(glow, 0.55)
			if d < 0.62:
				col = bg.lerp(glow, 0.8)
			if d < 0.46:
				col = glow
			img.set_pixel(x, y, col)
	var art := Image.load_from_file("res://assets/art3d/%s.png" % id)
	if art == null:
		push_error("manca l'immagine di " + id)
		quit(1)
		return
	art.convert(Image.FORMAT_RGBA8)
	var k := (S * 0.82) / maxf(art.get_width(), art.get_height())
	art.resize(int(art.get_width() * k), int(art.get_height() * k), Image.INTERPOLATE_LANCZOS)
	var pos := Vector2i((S - art.get_width()) / 2, int(S * 0.56 - art.get_height() / 2.0))
	img.blend_rect(art, Rect2i(Vector2i.ZERO, art.get_size()), pos)
	img.convert(Image.FORMAT_RGB8)
	img.save_png("res://assets/icon.png")
	print("icona salvata: assets/icon.png (", id, ")")
	quit(0)
