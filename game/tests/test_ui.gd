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
	_test_audio_files()
	_test_outlines_prepared()
	print("Risultati UI: %d ok, %d falliti" % [passed, failed])
	quit(1 if failed > 0 else 0)


## Ogni mesh con contorno ha le normali medie (altrimenti il contorno si stacca agli spigoli, D-020).
func _test_outlines_prepared() -> void:
	var roots: Array[Node3D] = []
	var board := Board3D.new()
	roots.append(board.world)
	var db := CardDB.load_default()
	for id in db.cards.keys() + db.heroes.keys():
		var n := Models.build(id)
		if n:
			roots.append(n)
	var missing := 0
	for r in roots:
		for mi: MeshInstance3D in r.find_children("*", "MeshInstance3D", true, false):
			if Kit._has_outline(mi) and not mi.has_meta("smooth"):
				missing += 1
	check(missing == 0, "contorni compatti su tutte le mesh (%d senza)" % missing)
	for r in roots:
		if r != board.world:
			r.free()
	board.free()


## Ogni suono e musica usati dal gioco esiste davvero (Sfx tace senza errori se manca un file).
func _test_audio_files() -> void:
	var missing := []
	for id in Sfx.LEVEL:
		if not ResourceLoader.exists(Sfx.SFX_DIR + id + ".wav"):
			missing.append(id)
	for id in ["menu", "match"]:
		if not ResourceLoader.exists(Sfx.MUSIC_DIR + id + ".ogg"):
			missing.append(id)
	check(missing.is_empty(), "suoni e musiche presenti %s" % [missing])


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
