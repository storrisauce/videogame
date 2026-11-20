class_name MenuScreen
extends Control
## Menu iniziale: scegli il sopravvissuto e le due bande del mazzo, poi gioca contro l'IA.

signal play(hero: String, bands: Array)

var db: CardDB
var profile: Profile
var hero_opt := OptionButton.new()
var band_opts: Array[OptionButton] = [OptionButton.new(), OptionButton.new()]
var hero_desc := Label.new()
var auto_check := CheckBox.new()
var stats := Label.new()
var play_button := Button.new()
var hero_ids: Array = []


var hero_portrait := SpriteView.new(null, 3)
func setup(card_db: CardDB, prof: Profile) -> void:
	db = card_db
	profile = prof


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(TerrainBG.new("erba", 0.35))
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16 if side in ["left", "right"] else 8)
	add_child(margin)
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 24)
	margin.add_child(cols)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cols.add_child(left)
	var title := Label.new()
	title.text = "FATTORIA NUCLEARE"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Pal.GREEN)
	left.add_child(title)
	var sub := Label.new()
	sub.text = "Animali mutanti. Recinti contesi. Scatolette di fagioli."
	sub.add_theme_color_override("font_color", Pal.YELLOW)
	left.add_child(sub)
	stats.add_theme_color_override("font_color", Pal.TEXT)
	left.add_child(stats)
	auto_check.text = "Mirino automatico (niente lancetta)"
	auto_check.button_pressed = profile.mirino_automatico
	auto_check.toggled.connect(func(on: bool): profile.mirino_automatico = on; profile.save())
	left.add_child(auto_check)
	play_button.text = "GIOCA CONTRO L'IA"
	play_button.custom_minimum_size = Vector2(0, 52)
	play_button.add_theme_font_size_override("font_size", 18)
	play_button.pressed.connect(_on_play)
	left.add_child(play_button)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cols.add_child(right)
	_label(right, "Il tuo sopravvissuto")
	hero_ids = db.heroes.keys()
	for id in hero_ids:
		hero_opt.add_item(db.heroes[id]["name"])
	hero_opt.selected = maxi(hero_ids.find(profile.hero), 0)
	hero_opt.item_selected.connect(func(_i): _update())
	right.add_child(hero_opt)
	var hero_row := HBoxContainer.new()
	hero_row.add_theme_constant_override("separation", 8)
	hero_portrait.custom_minimum_size = Vector2(108, 108)
	hero_row.add_child(hero_portrait)
	hero_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_row.add_child(hero_desc)
	right.add_child(hero_row)
	hero_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_desc.add_theme_font_size_override("font_size", 11)
	hero_desc.add_theme_color_override("font_color", Pal.TEXT)
	_label(right, "Le due bande del tuo mazzo (2 recinti ciascuna)")
	for k in 2:
		for b in DeckFactory.BANDS:
			band_opts[k].add_item(Pal.BAND_NAME[b])
		band_opts[k].selected = maxi(DeckFactory.BANDS.find(profile.bands[k]), 0)
		band_opts[k].item_selected.connect(_on_band.bind(k))
		right.add_child(band_opts[k])
	_update()
	play_button.grab_focus()


func _label(parent: Control, t: String) -> void:
	var l := Label.new()
	l.text = t
	l.add_theme_color_override("font_color", Pal.YELLOW)
	parent.add_child(l)


func _on_band(i: int, k: int) -> void:
	var other := 1 - k
	if band_opts[other].selected == i:
		band_opts[other].selected = (i + 1) % DeckFactory.BANDS.size()
	_update()


func _update() -> void:
	var h: Dictionary = db.heroes[hero_ids[hero_opt.selected]]
	hero_desc.text = "%s\n\n%s" % [h["name"], Abilities.describe_hero(h)]
	hero_portrait.set_texture(Art.hero_tex(h["id"]))
	stats.text = "Scatolette di fagioli: %d   ·   tonno: %d\nVittorie %d   ·   sconfitte %d" % [profile.fagioli, profile.tonno, profile.vittorie, profile.sconfitte]


func _on_play() -> void:
	var bands := [DeckFactory.BANDS[band_opts[0].selected], DeckFactory.BANDS[band_opts[1].selected]]
	profile.hero = hero_ids[hero_opt.selected]
	profile.bands = bands
	profile.save()
	play.emit(profile.hero, bands)
