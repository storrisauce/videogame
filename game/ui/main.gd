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
	var t := Theme.new()
	t.default_font_size = 13
	theme = t
	var bg := ColorRect.new()
	bg.color = Pal.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(safe)
	db = CardDB.load_default()
	profile = Profile.load_or_new()
	rng.randomize()
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)
	show_menu()


func _apply_safe_area() -> void:
	var win := Vector2(DisplayServer.window_get_size())
	var area := DisplayServer.get_display_safe_area()
	if win.x <= 0 or area.size.x <= 0 or DisplayServer.get_name() == "headless":
		return
	var k := size / win
	safe.offset_left = area.position.x * k.x
	safe.offset_top = area.position.y * k.y
	safe.offset_right = -(win.x - area.end.x) * k.x
	safe.offset_bottom = -(win.y - area.end.y) * k.y


func _swap(screen: Control) -> void:
	if current:
		current.queue_free()
	current = screen
	safe.add_child(screen)


func show_menu() -> void:
	var menu := MenuScreen.new()
	menu.setup(db, profile)
	menu.play.connect(start_match)
	_swap(menu)


func start_match(hero: String, bands: Array) -> void:
	var ms := MatchScreen.new()
	_swap(ms)
	if test_mode:
		ms.speed = 0.0
		ms.autoplay_human = true
	ms.exit_to_menu.connect(show_menu)
	ms.rematch.connect(start_match.bind(hero, bands))
	var opp_ids: Array = db.heroes.keys()
	var opp_hero: String = opp_ids[rng.randi_range(0, opp_ids.size() - 1)]
	ms.start_match(db, profile, hero, bands, opp_hero, DeckFactory.random_pair(rng), rng.randi())
