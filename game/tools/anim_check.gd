extends SceneTree
## Partita automatica a velocità normale, con animazioni: scatta una foto ogni secondo per controllare a occhio
## arrivi, attacchi, colpi e morti. Uso (serve una finestra, non --headless):
##   godot --path game --resolution 852x393 --script res://tools/anim_check.gd -- /percorso/cartella [secondi]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out := args[0] if args.size() > 0 else "user://anim"
	var secs := int(args[1]) if args.size() > 1 else 20
	DirAccess.make_dir_recursive_absolute(out)
	var main: Control = load("res://main.tscn").instantiate()
	root.add_child(main)
	for i in 30:
		await process_frame
	main.current._on_play()
	var ms: MatchScreen = main.current
	ms.autoplay_human = true
	ms.speed = 1.0
	if ms.state == "play":
		ms._auto_human.call_deferred()
	for s in secs:
		await create_timer(1.0).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join("t%02d.png" % s))
		if ms.state == "over":
			break
	print("anim_check: %d foto in %s, stato %s" % [secs, out, ms.state])
	quit(0)
