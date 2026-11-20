class_name MenuScreen
extends Control
## Menu iniziale, pensato per capirsi al primo sguardo (skill game-ui-ux, frontend-design):
## a destra il protagonista, cioè il tuo sopravvissuto grande e animato, che scorri con le frecce, e sotto le
## tue due bande, che cambi toccandole; a sinistra il titolo, i tuoi numeri e un solo pulsante principale, Gioca.
## Tutto entra in sequenza (30–80 ms di sfalsamento), solo all'apertura.

signal play(hero: String, bands: Array)

var db: CardDB
var profile: Profile
var hero_ids: Array = []
var hero_index := 0
var band_sel := [0, 1]
var hero_portrait := SpriteView.new(null, 4)
var hero_name := Label.new()
var hero_desc := Label.new()
var band_buttons: Array[Button] = [Button.new(), Button.new()]
var auto_check := CheckBox.new()
var motion_check := CheckBox.new()
var stats := Label.new()
var play_button := Button.new()
var deck_row := HBoxContainer.new()


func setup(card_db: CardDB, prof: Profile) -> void:
	db = card_db
	profile = prof


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(TerrainBG.new("erba", 0.25))
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20 if side in ["left", "right"] else 12)
	add_child(margin)
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 20)
	margin.add_child(cols)

	# --- colonna sinistra: chi sei e il pulsante per giocare ---
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 0.9
	left.add_theme_constant_override("separation", 8)
	cols.add_child(left)
	var title := Label.new()
	title.text = "Fattoria Nucleare"
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Art.c("radio_1"))
	title.add_theme_color_override("font_outline_color", Art.c("verde_0"))
	title.add_theme_constant_override("outline_size", 14)
	title.add_theme_color_override("font_outline_color", Art.c("inchiostro"))
	left.add_child(title)
	var sub := Label.new()
	sub.text = "Animali mutanti. Recinti contesi.\nVince chi fa perdere la Pazienza all'altro."
	sub.add_theme_font_size_override("font_size", Ui.SMALL)
	sub.add_theme_color_override("font_color", Art.c("legno_9"))
	left.add_child(sub)
	stats.add_theme_font_size_override("font_size", Ui.SMALL)
	stats.add_theme_color_override("font_color", Art.c("bianco"))
	left.add_child(_panel(stats))
	left.add_child(_section("Nel tuo mazzo"))
	deck_row.add_theme_constant_override("separation", 6)
	for k in 6:
		var sv := SpriteView.new(null, 2)
		sv.custom_minimum_size = Vector2(66, 66)
		deck_row.add_child(sv)
	left.add_child(deck_row)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(spacer)
	play_button.text = "Gioca"
	play_button.custom_minimum_size = Vector2(0, 62)
	play_button.add_theme_font_size_override("font_size", Ui.BIG)
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		play_button.add_theme_color_override(k, Art.c("bianco"))
	play_button.add_theme_constant_override("outline_size", 10)
	for st in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Art.c({"normal": "radio_1", "hover": "radio_2", "pressed": "verde_4", "focus": "radio_1"}[st])
		sb.border_color = Art.c("inchiostro")
		sb.set_border_width_all(4)
		sb.set_corner_radius_all(16)
		sb.shadow_color = Art.c("inchiostro")
		sb.shadow_offset = Vector2(0, 0 if st == "pressed" else 5)
		sb.shadow_size = 1
		play_button.add_theme_stylebox_override(st, sb)
	play_button.pressed.connect(_on_play)
	Juice.press(play_button)
	left.add_child(play_button)
	var toggles := HBoxContainer.new()
	toggles.add_theme_constant_override("separation", 14)
	auto_check.text = "Mirino automatico"
	auto_check.button_pressed = profile.mirino_automatico
	auto_check.toggled.connect(func(on: bool): profile.mirino_automatico = on; profile.save())
	motion_check.text = "Meno movimento"
	motion_check.button_pressed = profile.meno_movimento
	motion_check.toggled.connect(func(on: bool): profile.meno_movimento = on; profile.save())
	for cb in [auto_check, motion_check]:
		cb.add_theme_font_size_override("font_size", 12)
		cb.custom_minimum_size = Vector2(0, 44)
		toggles.add_child(cb)
	left.add_child(toggles)

	# --- colonna destra: il tuo sopravvissuto (protagonista) e le tue bande ---
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 6)
	cols.add_child(right)
	right.add_child(_section("Il tuo sopravvissuto"))
	var carousel := HBoxContainer.new()
	carousel.alignment = BoxContainer.ALIGNMENT_CENTER
	carousel.add_theme_constant_override("separation", 10)
	carousel.add_child(_arrow("‹", func(): _cycle_hero(-1)))
	hero_portrait.custom_minimum_size = Vector2(136, 136)
	carousel.add_child(hero_portrait)
	carousel.add_child(_arrow("›", func(): _cycle_hero(1)))
	right.add_child(carousel)
	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 0)
	hero_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_name.add_theme_font_size_override("font_size", Ui.MID)
	hero_name.add_theme_color_override("font_color", Art.c("giallo_2"))
	hero_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	who.add_child(hero_name)
	hero_desc.add_theme_font_size_override("font_size", Ui.BODY + 1)
	hero_desc.add_theme_font_override("font", Ui.body())
	hero_desc.add_theme_constant_override("outline_size", 0)
	hero_desc.add_theme_color_override("font_color", Art.c("bianco"))
	hero_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	who.add_child(hero_desc)
	right.add_child(who)
	right.add_child(_section("Le tue due bande (tocca per cambiare)"))
	var chips := HBoxContainer.new()
	chips.add_theme_constant_override("separation", 10)
	for k in 2:
		var b := band_buttons[k]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 48)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_size_override("font_size", 13)
		b.pressed.connect(_cycle_band.bind(k))
		Juice.press(b)
		chips.add_child(b)
	right.add_child(chips)

	hero_ids = db.heroes.keys()
	hero_index = maxi(hero_ids.find(profile.hero), 0)
	for k in 2:
		band_sel[k] = maxi(DeckFactory.BANDS.find(profile.bands[k]), 0)
	if band_sel[0] == band_sel[1]:
		band_sel[1] = (band_sel[0] + 1) % DeckFactory.BANDS.size()
	_update()
	play_button.grab_focus()
	# entrata: titolo, protagonista, bande, pulsante (sfalsati)
	var order: Array[Control] = [title, sub, stats.get_parent(), deck_row, hero_portrait, who, chips, play_button, toggles]
	for i in order.size():
		Juice.enter(order[i], 0.04 * i)


func _section(t: String) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", Ui.SMALL)
	l.add_theme_color_override("font_color", Art.c("legno_9"))
	return l


func _panel(inner: Control) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Art.c("ferro_1")
	sb.border_color = Art.c("inchiostro")
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(12)
	sb.set_content_margin_all(8)
	p.add_theme_stylebox_override("panel", sb)
	p.add_child(inner)
	return p


func _arrow(t: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = t
	b.custom_minimum_size = Vector2(48, 56)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", 26)
	b.pressed.connect(cb)
	Juice.press(b)
	return b


func _cycle_hero(d: int) -> void:
	hero_index = posmod(hero_index + d, hero_ids.size())
	_update()
	# il nuovo ritratto entra dal lato della freccia
	hero_portrait.offset_transform_enabled = true
	hero_portrait.offset_transform_pivot = hero_portrait.size / 2.0
	hero_portrait.offset_transform_position = Vector2(14 * d, 0)
	hero_portrait.modulate.a = 0.4
	var tw := hero_portrait.create_tween().set_parallel(true)
	tw.tween_property(hero_portrait, "offset_transform_position", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(hero_portrait, "modulate:a", 1.0, 0.15)


func _cycle_band(k: int) -> void:
	var n := DeckFactory.BANDS.size()
	var v: int = (band_sel[k] + 1) % n
	if v == band_sel[1 - k]:
		v = (v + 1) % n
	band_sel[k] = v
	_update()


func _update() -> void:
	var h: Dictionary = db.heroes[hero_ids[hero_index]]
	hero_name.text = h["name"]
	hero_desc.text = Abilities.describe_hero(h)
	hero_portrait.art_id = h["id"]
	hero_portrait.art_hero = true
	hero_portrait.set_texture(Art.hero_tex(h["id"]))
	for k in 2:
		var band: String = DeckFactory.BANDS[band_sel[k]]
		band_buttons[k].text = Pal.BAND_NAME[band]
		band_buttons[k].icon = Art.terrain_tex(band)
	# anteprima: tre creature per banda, sul terreno della loro banda
	var views := deck_row.get_children()
	var slot := 0
	for k in 2:
		var band: String = DeckFactory.BANDS[band_sel[k]]
		var n := 0
		for id: String in db.cards:
			var c: Dictionary = db.cards[id]
			if c["band"] == band and c["type"] == "creature" and n < 3 and slot < views.size():
				var sv := views[slot] as SpriteView
				sv.terrain = band
				sv.art_id = id
				sv.set_texture(Art.card_tex(id))
				n += 1
				slot += 1
	stats.text = "%d scatolette di fagioli   %d di tonno\n%d vittorie   %d sconfitte" % [profile.fagioli, profile.tonno, profile.vittorie, profile.sconfitte]


func _on_play() -> void:
	var bands := [DeckFactory.BANDS[band_sel[0]], DeckFactory.BANDS[band_sel[1]]]
	profile.hero = hero_ids[hero_index]
	profile.bands = bands
	profile.save()
	play.emit(profile.hero, bands)
