class_name MenuScreen
extends Control
## Home (D-019): scena 3D del bunker con il sopravvissuto scelto su un piedistallo sotto la lampada (MenuStage),
## e sopra pochissimo: logo, nome e abilità in una riga, frecce tonde ai lati del personaggio, le due bande come
## gettoni (tocca per cambiare), un grande "Gioca", scatolette e rotellina delle impostazioni in alto a destra.
## Un solo elemento memorabile (il personaggio), niente testi di troppo (frontend-design, game-ui-ux).

signal play(hero: String, bands: Array)

var db: CardDB
var profile: Profile
var hero_ids: Array = []
var hero_index := 0
var band_sel := [0, 1]
var stage := MenuStage.new()
var logo := Label.new()
var hero_name := Label.new()
var hero_epithet := Label.new()
var hero_desc := Label.new()
var arrow_l := Button.new()
var arrow_r := Button.new()
var band_tokens: Array = []
var play_button := Button.new()
var wallet := Wallet.new()
var gear := Button.new()
var settings := PanelContainer.new()
var auto_check := CheckBox.new()
var motion_check := CheckBox.new()


func setup(card_db: CardDB, prof: Profile) -> void:
	db = card_db
	profile = prof


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage.calm = profile.meno_movimento
	add_child(stage)
	logo.text = "Fattoria Nucleare"
	logo.add_theme_font_size_override("font_size", 44)
	logo.add_theme_color_override("font_color", Art.c("radio_1"))
	logo.add_theme_constant_override("outline_size", 16)
	add_child(logo)
	hero_name.add_theme_font_size_override("font_size", Ui.BIG)
	hero_name.add_theme_color_override("font_color", Art.c("giallo_2"))
	hero_epithet.add_theme_font_size_override("font_size", Ui.SMALL)
	hero_epithet.add_theme_color_override("font_color", Art.c("legno_9"))
	hero_desc.add_theme_font_override("font", Ui.body())
	hero_desc.add_theme_font_size_override("font_size", Ui.BODY + 2)
	hero_desc.add_theme_constant_override("outline_size", 6)
	hero_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for l in [hero_name, hero_epithet, hero_desc]:
		add_child(l)
	for b: Button in [arrow_l, arrow_r]:
		b.text = "‹" if b == arrow_l else "›"
		b.add_theme_font_size_override("font_size", Ui.BIG)
		b.custom_minimum_size = Vector2(48, 48)
		_round(b, "ferro_2")
		Juice.press(b)
		add_child(b)
	arrow_l.pressed.connect(func(): _cycle_hero(-1))
	arrow_r.pressed.connect(func(): _cycle_hero(1))
	for k in 2:
		var t := BandToken.new()
		t.pressed.connect(_cycle_band.bind(k))
		band_tokens.append(t)
		add_child(t)
	play_button.text = "Gioca"
	play_button.add_theme_font_size_override("font_size", 34)
	for st in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Art.c({"normal": "radio_1", "hover": "radio_2", "pressed": "verde_4", "focus": "radio_1"}[st])
		sb.border_color = Art.c("inchiostro")
		sb.set_border_width_all(4)
		sb.set_corner_radius_all(30)
		sb.shadow_color = Art.c("inchiostro")
		sb.shadow_offset = Vector2(0, 0 if st == "pressed" else 6)
		sb.shadow_size = 1
		play_button.add_theme_stylebox_override(st, sb)
	play_button.pressed.connect(_on_play)
	Juice.press(play_button)
	add_child(play_button)
	add_child(wallet)
	gear.text = "⚙"
	gear.add_theme_font_size_override("font_size", 22)
	gear.custom_minimum_size = Vector2(44, 44)
	_round(gear, "ferro_2")
	gear.pressed.connect(func(): settings.visible = not settings.visible)
	Juice.press(gear)
	add_child(gear)
	var vb := VBoxContainer.new()
	auto_check.text = "Mirino automatico"
	auto_check.button_pressed = profile.mirino_automatico
	auto_check.toggled.connect(func(on: bool): profile.mirino_automatico = on; profile.save())
	motion_check.text = "Meno movimento"
	motion_check.button_pressed = profile.meno_movimento
	motion_check.toggled.connect(func(on: bool): profile.meno_movimento = on; stage.calm = on; profile.save())
	for cb in [auto_check, motion_check]:
		cb.custom_minimum_size = Vector2(0, 44)
		vb.add_child(cb)
	settings.add_child(vb)
	settings.visible = false
	add_child(settings)

	hero_ids = db.heroes.keys()
	hero_index = maxi(hero_ids.find(profile.hero), 0)
	for k in 2:
		band_sel[k] = maxi(DeckFactory.BANDS.find(profile.bands[k]), 0)
	if band_sel[0] == band_sel[1]:
		band_sel[1] = (band_sel[0] + 1) % DeckFactory.BANDS.size()
	_layout()
	_update(0)
	play_button.grab_focus()
	var order: Array[Control] = [logo, hero_name, hero_epithet, hero_desc, band_tokens[0], band_tokens[1], play_button, wallet, gear]
	for i in order.size():
		Juice.enter(order[i], 0.05 * i)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_inside_tree() and logo.get_parent() == self:
		_layout()


func _round(b: Button, fill: String) -> void:
	for st in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Art.c(fill) if st != "pressed" else Art.c(fill).darkened(0.2)
		sb.border_color = Art.c("inchiostro")
		sb.set_border_width_all(3)
		sb.set_corner_radius_all(30)
		sb.shadow_color = Art.c("inchiostro")
		sb.shadow_offset = Vector2(0, 0 if st == "pressed" else 3)
		sb.shadow_size = 1
		b.add_theme_stylebox_override(st, sb)


func _layout() -> void:
	var W := size.x
	var H := size.y
	if W <= 0:
		return
	var m := 18.0
	logo.position = Vector2(m, 6)
	logo.size = Vector2(W * 0.6, 56)
	hero_name.position = Vector2(m, 70)
	hero_name.size = Vector2(W * 0.45, 36)
	hero_epithet.position = Vector2(m, 104)
	hero_epithet.size = Vector2(W * 0.45, 20)
	hero_desc.position = Vector2(m, 128)
	hero_desc.custom_minimum_size = Vector2(W * 0.4, 0)
	hero_desc.size = Vector2(W * 0.4, 0)
	var tok := clampf(H * 0.24, 72.0, 96.0)
	for k in 2:
		var t: BandToken = band_tokens[k]
		t.position = Vector2(m + k * (tok + 14), H - tok - 26)
		t.size = Vector2(tok, tok + 18)
	play_button.size = Vector2(clampf(W * 0.26, 180.0, 240.0), 66)
	play_button.position = Vector2(W - play_button.size.x - m, H - 66 - m)
	gear.size = Vector2(44, 44)
	gear.position = Vector2(W - 44 - m, 10)
	wallet.size = Vector2(150, 44)
	wallet.position = Vector2(W - 44 - m - 10 - 150, 10)
	settings.position = Vector2(W - 240 - m, 60)
	settings.size = Vector2(240, 0)
	_place_arrows.call_deferred()


func _place_arrows() -> void:
	var r := stage.hero_screen_rect()
	if r.size.x <= 0:
		return
	var cy := r.position.y + r.size.y * 0.55
	arrow_l.position = Vector2(r.position.x - 70, cy - 24)
	arrow_r.position = Vector2(r.end.x + 22, cy - 24)
	arrow_l.size = Vector2(48, 48)
	arrow_r.size = Vector2(48, 48)


func _cycle_hero(d: int) -> void:
	hero_index = posmod(hero_index + d, hero_ids.size())
	_update(d)


func _cycle_band(k: int) -> void:
	var n := DeckFactory.BANDS.size()
	var v: int = (band_sel[k] + 1) % n
	if v == band_sel[1 - k]:
		v = (v + 1) % n
	band_sel[k] = v
	_update(0, false)


func _update(dir: int, hero_changed := true) -> void:
	var h: Dictionary = db.heroes[hero_ids[hero_index]]
	hero_name.text = h["name"]
	hero_epithet.text = h.get("epithet", "")
	hero_desc.text = Abilities.describe_hero(h)
	if hero_changed:
		stage.show_hero(h["id"], dir)
	for k in 2:
		var band: String = DeckFactory.BANDS[band_sel[k]]
		var t: BandToken = band_tokens[k]
		t.set_band(band, _first_creature(band))
	wallet.set_values(profile.fagioli, profile.tonno)


func _first_creature(band: String) -> String:
	for id: String in db.cards:
		var c: Dictionary = db.cards[id]
		if c["band"] == band and c["type"] == "creature":
			return id
	return ""


func _on_play() -> void:
	var bands := [DeckFactory.BANDS[band_sel[0]], DeckFactory.BANDS[band_sel[1]]]
	profile.hero = hero_ids[hero_index]
	profile.bands = bands
	profile.save()
	play.emit(profile.hero, bands)


## Gettone di una banda: tondo del colore della banda con la sua creatura, nome breve sotto. Tocca = cambia.
class BandToken extends Control:
	signal pressed
	var band := ""
	var art := ""

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func set_band(b: String, art_id: String) -> void:
		band = b
		art = art_id
		queue_redraw()
		if is_inside_tree():
			pivot_offset = size / 2.0
			scale = Vector2(0.9, 0.9)
			create_tween().tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	func _gui_input(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and not e.pressed:
			pressed.emit()
			accept_event()

	func _draw() -> void:
		var d := minf(size.x, size.y - 18)
		var c := Vector2(size.x / 2.0, d / 2.0)
		var col := Art.c(CardView.BAND_FRAME.get(band, "legno_5"))
		draw_circle(c + Vector2(0, 4), d / 2.0, Ui.ink())
		draw_circle(c, d / 2.0, Ui.ink())
		draw_circle(c, d / 2.0 - 4, col)
		draw_circle(c + Vector2(0, d * 0.12), d / 2.0 - 10, col.lightened(0.25))
		if art != "":
			Art.draw_art(self, art, false, Rect2(c - Vector2(d, d) * 0.36, Vector2(d, d) * 0.72))
		var short: String = Pal.BAND_NAME.get(band, band).split(" ")[0]
		Ui.text(self, Vector2(0, size.y - 2), short, Ui.SMALL, Art.c("bianco"), HORIZONTAL_ALIGNMENT_CENTER, size.x, 3.0)


## Scatolette di fagioli (moneta) e di tonno, come icone con numero.
class Wallet extends Control:
	var fagioli := 0
	var tonno := 0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func set_values(f: int, t: int) -> void:
		fagioli = f
		tonno = t
		queue_redraw()

	func _draw() -> void:
		_can(Vector2(14, size.y / 2.0), Art.c("rosso_2"))
		Ui.text(self, Vector2(30, size.y / 2.0 + 7), str(fagioli), Ui.MID, Art.c("bianco"))
		var x := 30.0 + Ui.display().get_string_size(str(fagioli), 0, -1, Ui.MID).x + 16.0
		_can(Vector2(x, size.y / 2.0), Art.c("acqua_4"))
		Ui.text(self, Vector2(x + 16, size.y / 2.0 + 7), str(tonno), Ui.MID, Art.c("bianco"))

	func _can(c: Vector2, col: Color) -> void:
		var r := Rect2(c - Vector2(10, 12), Vector2(20, 24))
		var sb := StyleBoxFlat.new()
		sb.bg_color = Art.c("ferro_4")
		sb.border_color = Ui.ink()
		sb.set_border_width_all(3)
		sb.set_corner_radius_all(5)
		draw_style_box(sb, r)
		draw_rect(Rect2(r.position.x + 3, r.position.y + 8, r.size.x - 6, 9), col)
