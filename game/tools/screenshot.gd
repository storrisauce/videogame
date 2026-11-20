extends SceneTree
## Screenshot della schermata di partita (serve uno schermo, anche virtuale):
## xvfb-run -s "-screen 0 1704x786x24" godot --path game --rendering-driver opengl3 --resolution 852x393 --script res://tools/screenshot.gd -- <cartella>

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out := args[0] if args.size() > 0 else "user://"
	var main: Control = load("res://main.tscn").instantiate()
	root.add_child(main)
	for i in 10:
		await process_frame
	for i in 60:   # lascia finire l'entrata del menu
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join("menu.png"))
	main.test_mode = false
	main.current._on_play()
	var ms: MatchScreen = main.current
	ms.speed = 0.0
	for i in 20:
		await process_frame
	# gioca qualche turno con l'IA per riempire il tavolo
	for t in 4:
		if ms.state != "play":
			break
		while true:
			var a := GreedyAI.choose(ms.m, 0)
			if a.is_empty():
				break
			ms.m.apply(0, a)
		ms.refresh()
		ms._on_end_turn()
		for i in 5:
			await process_frame
	ms.refresh()
	for i in 50:   # lascia finire le animazioni d'arrivo
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join("tavolo.png"))
	if ms.state == "play" and not ms.m.players[0].hand.is_empty():
		ms._on_hand_tapped(ms.hand_layer.get_child(0))
	for i in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join("partita.png"))
	ms.dial.start(ms.rng, "Attacca con Mucca Laser!", false, 0.25, 0.08, 1.2, 1.6, 3)
	for i in 25:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join("mirino.png"))
	print("screenshot salvati in ", out)
	quit(0)
