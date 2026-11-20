extends Control
## Radice del gioco: tiene dati e profilo e passa dal menu alla partita.
## I contenuti stanno dentro i margini sicuri dello schermo (Dynamic Island, indicatore Home).

var db: CardDB
var profile: Profile
var safe := Control.new()
var current: Control
var rng := RandomNumberGenerator.new()
var test_mode := false   ## test: partite istantanee giocate dall'IA anche per il giocatore


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = Ui.theme()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(safe)
	db = CardDB.load_default()
	profile = Profile.load_or_new()
	Sfx.configure(profile.musica, profile.effetti, profile.vibrazione)
	rng.randomize()
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)
	show_menu()


## Tema in pixel art: bottoni di legno con luce in alto, pannelli di legno scuro, testo bianco.
func _make_theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = 13
	var states := {"normal": ["legno_5", "legno_7"], "hover": ["legno_6", "legno_8"], "pressed": ["legno_3", "legno_4"],
		"disabled": ["legno_2", "legno_3"], "focus": ["legno_5", "radio_1"]}
	for st: String in states:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Art.c(states[st][0])
		sb.border_color = Art.c("legno_1")
		sb.set_border_width_all(2)
		sb.border_width_top = 2
		sb.set_content_margin_all(4)
		sb.shadow_size = 0
		if st == "focus":
			sb.draw_center = false
			sb.border_color = Art.c("radio_1")
		else:
			sb.expand_margin_top = 0
			sb.border_blend = false
			# riga di luce in alto
			sb.border_width_top = 3
			sb.border_color = Art.c("legno_1")
		t.set_stylebox(st, "Button", sb)
		t.set_stylebox(st, "OptionButton", sb)
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		t.set_color(k, "Button", Art.c("bianco"))
		t.set_color(k, "OptionButton", Art.c("bianco"))
	t.set_color("font_disabled_color", "Button", Art.c("legno_6"))
	t.set_color("font_outline_color", "Button", Art.c("legno_1"))
	t.set_constant("outline_size", "Button", 3)
	t.set_color("font_outline_color", "Label", Art.c("inchiostro"))
	t.set_constant("outline_size", "Label", 3)
	var panel := StyleBoxFlat.new()
	panel.bg_color = Art.c("legno_2")
	panel.border_color = Art.c("legno_6")
	panel.set_border_width_all(2)
	panel.set_content_margin_all(8)
	t.set_stylebox("panel", "PanelContainer", panel)
	t.set_stylebox("panel", "PopupMenu", panel)
	return t


func _apply_safe_area() -> void:
	# L'area sicura è in coordinate dello schermo: la riduciamo alla finestra del gioco.
	if DisplayServer.get_name() == "headless":
		return
	var win_pos := DisplayServer.window_get_position()
	var win_size := DisplayServer.window_get_size()
	if win_size.x <= 0 or win_size.y <= 0:
		return
	var win := Rect2i(win_pos, win_size)
	var area := DisplayServer.get_display_safe_area().intersection(win)
	if area.size.x <= 0 or area.size.y <= 0:
		area = win
	var k := size / Vector2(win_size)
	safe.offset_left = (area.position.x - win.position.x) * k.x
	safe.offset_top = (area.position.y - win.position.y) * k.y
	safe.offset_right = -(win.end.x - area.end.x) * k.x
	safe.offset_bottom = -(win.end.y - area.end.y) * k.y


var _curtain := ColorRect.new()


## Cambio schermata: la nuova appare subito sotto un velo scuro che si dissolve (dissolvenza, 280 ms).
func _swap(screen: Control) -> void:
	if current:
		current.queue_free()
	current = screen
	safe.add_child(screen)
	if test_mode or not is_inside_tree():
		return
	if _curtain.get_parent() == null:
		_curtain.color = Art.c("notte")
		_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(_curtain)
	move_child(_curtain, -1)
	_curtain.modulate.a = 1.0
	create_tween().tween_property(_curtain, "modulate:a", 0.0, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func show_menu() -> void:
	var menu := MenuScreen.new()
	menu.setup(db, profile)
	menu.play.connect(start_match)
	menu.play_online.connect(start_online)
	Sfx.muted = test_mode
	_swap(menu)


## Partita online con un amico: OnlineGame è già in contatto (codice della stanza), info dal suo ready_to_start.
func start_online(og: OnlineGame, info: Dictionary) -> void:
	Sfx.muted = test_mode
	if og.get_parent() != self:
		if og.get_parent():
			og.get_parent().remove_child(og)
		add_child(og)
	var ms := MatchScreen.new()
	_swap(ms)
	ms.exit_to_menu.connect(func():
		og.leave()
		og.queue_free()
		show_menu())
	ms.start_online(db, profile, og, info)


func start_match(hero: String, bands: Array) -> void:
	Sfx.muted = test_mode
	var ms := MatchScreen.new()
	_swap(ms)
	if test_mode:
		ms.speed = 0.0
		ms.autoplay_human = true
	ms.exit_to_menu.connect(show_menu)
	ms.rematch.connect(start_match.bind(hero, bands))
	var opp_ids: Array = db.heroes.keys()
	if opp_ids.size() > 1:
		opp_ids.erase(hero)   # mai lo stesso sopravvissuto da tutte e due le parti
	var opp_hero: String = opp_ids[rng.randi_range(0, opp_ids.size() - 1)]
	ms.start_match(db, profile, hero, bands, opp_hero, DeckFactory.random_pair(rng), rng.randi())
