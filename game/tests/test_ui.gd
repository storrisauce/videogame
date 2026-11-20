extends SceneTree
## Test dell'interfaccia senza grafica: una partita intera giocata dalle schermate vere,
## e controllo che nulla esca dallo schermo alle misure dei telefoni.
## godot --headless --path game --script res://tests/test_ui.gd

const SIZES: Array[Vector2i] = [Vector2i(852, 393), Vector2i(667, 375), Vector2i(932, 430)]

var failed := 0
var passed := 0


func check(ok: bool, label: String) -> void:
	if ok:
		passed += 1
	else:
		failed += 1
		push_error("FAIL " + label)


func _initialize() -> void:
	await process_frame
	await _test_full_game_through_ui()
	await _test_layout()
	print("Risultati UI: %d ok, %d falliti" % [passed, failed])
	quit(1 if failed > 0 else 0)


func _test_full_game_through_ui() -> void:
	for g in 3:
		var main: Control = load("res://main.tscn").instantiate()
		main.test_mode = true
		root.add_child(main)
		await process_frame
		check(main.current is MenuScreen, "parte dal menu")
		main.current._on_play()
		var ms: MatchScreen = main.current
		check(ms is MatchScreen, "il menu apre la partita")
		var frames := 0
		while ms.state != "over" and frames < 3000:
			await process_frame
			frames += 1
		check(ms.state == "over", "la partita %d arriva alla fine (frame %d)" % [g, frames])
		check(ms.m.winner in [0, 1], "c'è un vincitore")
		check(ms.over_panel.visible, "compare il pannello di fine partita")
		# Rivincita: deve aprire una nuova partita
		ms._end_and("rematch")
		await process_frame
		check(main.current is MatchScreen and main.current != ms, "la rivincita apre una nuova partita")
		main.queue_free()
		await process_frame


func _test_layout() -> void:
	for sz in SIZES:
		var vp := SubViewport.new()
		vp.size = sz
		root.add_child(vp)
		var ms := MatchScreen.new()
		vp.add_child(ms)
		await process_frame
		var db := CardDB.load_default()
		ms.speed = 0.0
		ms.start_match(db, null, "nonna", ["porcile", "pollaio"], "speaker", ["stagno", "patate"], 3)
		await process_frame
		await process_frame
		var screen := Rect2(Vector2.ZERO, Vector2(sz)).grow(1)
		for node in ms.find_children("*", "Control", true, false):
			var c := node as Control
			if c.is_visible_in_tree() and c != ms.dial and not screen.encloses(c.get_global_rect()):
				check(false, "%s fuori schermo a %s: %s" % [ms.get_path_to(c), sz, c.get_global_rect()])
		for p in 2:
			for i in 4:
				var lv: LaneView = ms.lane_views[p][i]
				# tavolo in prospettiva (D-015): la fila lontana è più piccola; conta che si tocchi bene (≥ 44 pt, HIG Apple)
				var need := Vector2(80, 56) if p == 0 else Vector2(56, 44)
				check(lv.size.x >= need.x and lv.size.y >= need.y, "recinto abbastanza grande a %s (%s)" % [sz, lv.size])
		check(ms.end_button.size.y >= 44, "pulsante Fine turno toccabile a %s" % sz)
		vp.queue_free()
		await process_frame
