class_name MenuScreen
extends Control
## Home (D-019): scena 3D del bunker con il sopravvissuto scelto su un piedistallo sotto la lampada (MenuStage),
## e sopra pochissimo: logo, nome e abilità in una riga, frecce tonde ai lati del personaggio, le due bande come
## gettoni (tocca per cambiare), un grande "Gioca", scatolette e rotellina delle impostazioni in alto a destra.
## Un solo elemento memorabile (il personaggio), niente testi di troppo (frontend-design, game-ui-ux).

signal play(hero: String, bands: Array)
signal play_online(og: OnlineGame, info: Dictionary)

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
var friend_button := Button.new()
var lobby := PanelContainer.new()
var lobby_status := Label.new()
var code_edit := LineEdit.new()
var _og: OnlineGame
var auto_check := CheckBox.new()
var motion_check := CheckBox.new()
var music_check := CheckBox.new()
var sfx_check := CheckBox.new()
var vibra_check := CheckBox.new()
var fast_check := CheckBox.new()


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
	friend_button.text = "Con un amico"
	friend_button.add_theme_font_size_override("font_size", Ui.MID)
	for st in ["normal", "hover", "pressed", "focus"]:
		var fsb := StyleBoxFlat.new()
		fsb.bg_color = Art.c({"normal": "acqua_4", "hover": "acqua_5", "pressed": "acqua_2", "focus": "acqua_4"}[st])
		fsb.border_color = Art.c("inchiostro")
		fsb.set_border_width_all(4)
		fsb.set_corner_radius_all(22)
		fsb.shadow_color = Art.c("inchiostro")
		fsb.shadow_offset = Vector2(0, 0 if st == "pressed" else 4)
		fsb.shadow_size = 1
		friend_button.add_theme_stylebox_override(st, fsb)
	friend_button.pressed.connect(_open_lobby)
	Juice.press(friend_button)
	add_child(friend_button)
	_build_lobby()
	add_child(wallet)
	gear.text = ""   # il simbolo ⚙ non c'è nei font su iPhone: la rotellina è disegnata (GearIcon)
	gear.custom_minimum_size = Vector2(44, 44)
	var gi := GearIcon.new()
	gi.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gear.add_child(gi)
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
	music_check.text = "Musica"
	music_check.button_pressed = profile.musica
	sfx_check.text = "Effetti sonori"
	sfx_check.button_pressed = profile.effetti
	vibra_check.text = "Vibrazione"
	vibra_check.button_pressed = profile.vibrazione
	for cb: CheckBox in [music_check, sfx_check, vibra_check]:
		cb.toggled.connect(func(_on: bool):
			profile.musica = music_check.button_pressed
			profile.effetti = sfx_check.button_pressed
			profile.vibrazione = vibra_check.button_pressed
			Sfx.configure(profile.musica, profile.effetti, profile.vibrazione)
			if profile.musica:
				Sfx.music("menu")
			Sfx.buzz("light")
			profile.save())
	fast_check.text = "Animazioni rapide"
	fast_check.button_pressed = profile.veloce
	fast_check.toggled.connect(func(on: bool): profile.veloce = on; profile.save())
	for cb in [auto_check, fast_check, motion_check, music_check, sfx_check, vibra_check]:
		cb.custom_minimum_size = Vector2(0, 40)
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
	Sfx.music("menu")
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
	friend_button.size = Vector2(play_button.size.x, 46)
	friend_button.position = play_button.position - Vector2(0, 56)
	lobby.position = Vector2(W / 2.0 - 190, H * 0.12)
	lobby.size = Vector2(380, 0)
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
	Sfx.play("swish")
	_update(d)


func _cycle_band(k: int) -> void:
	var n := DeckFactory.BANDS.size()
	var v: int = (band_sel[k] + 1) % n
	if v == band_sel[1 - k]:
		v = (v + 1) % n
	band_sel[k] = v
	Sfx.play("pop", 1.0 + 0.08 * v)
	Sfx.buzz("tap")
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
	Sfx.play("play")
	Sfx.buzz("heavy")
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


## Rotellina delle impostazioni disegnata (otto denti, foro al centro), bianca con contorno.
class GearIcon extends Control:
	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var c := size / 2.0
		var r := minf(size.x, size.y) * 0.26
		var pts := PackedVector2Array()
		for k in 32:
			var a := TAU * k / 32.0
			var tooth := 1.0 if (k % 4) < 2 else 0.74
			pts.append(c + Vector2(cos(a), sin(a)) * r * 1.3 * tooth)
		var ink := Art.c("inchiostro")
		var outline := pts.duplicate()
		outline.append(pts[0])
		draw_colored_polygon(pts, Art.c("bianco"))
		draw_polyline(outline, ink, 2.0, true)
		draw_circle(c, r * 0.45, Art.c("ferro_2"))
		draw_arc(c, r * 0.45, 0, TAU, 20, ink, 2.0, true)



# --- Gioca con un amico (online, D-025) ----------------------------------------------------------
## Pannello: "Crea partita" dà un codice da dire all'amico; "Entra" usa il codice dell'amico.

func _build_lobby() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Art.c("ferro_1")
	sb.border_color = Art.c("inchiostro")
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(14)
	sb.set_content_margin_all(14)
	lobby.add_theme_stylebox_override("panel", sb)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	var title := Label.new()
	title.text = "Gioca con un amico"
	title.add_theme_font_size_override("font_size", Ui.MID + 2)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)
	var create := Button.new()
	create.text = "Crea partita"
	create.custom_minimum_size = Vector2(0, 46)
	create.pressed.connect(_create_room)
	Juice.press(create)
	vb.add_child(create)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	code_edit.placeholder_text = "Codice dell'amico"
	code_edit.max_length = 8
	code_edit.custom_minimum_size = Vector2(0, 46)
	code_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	code_edit.add_theme_font_size_override("font_size", Ui.MID)
	code_edit.text_submitted.connect(func(_t: String): _join_room())
	row.add_child(code_edit)
	var enter := Button.new()
	enter.text = "Entra"
	enter.custom_minimum_size = Vector2(90, 46)
	enter.pressed.connect(_join_room)
	Juice.press(enter)
	row.add_child(enter)
	vb.add_child(row)
	lobby_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lobby_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lobby_status.add_theme_font_override("font", Ui.body())
	lobby_status.add_theme_font_size_override("font_size", Ui.BODY + 3)
	lobby_status.custom_minimum_size = Vector2(340, 0)
	vb.add_child(lobby_status)
	var cancel := Button.new()
	cancel.text = "Chiudi"
	cancel.custom_minimum_size = Vector2(0, 40)
	cancel.pressed.connect(_close_lobby)
	Juice.press(cancel)
	vb.add_child(cancel)
	lobby.add_child(vb)
	lobby.visible = false
	lobby.z_index = 20
	add_child(lobby)


func _open_lobby() -> void:
	settings.visible = false
	lobby.visible = true
	lobby_status.text = "Crea una partita e di' il codice al tuo amico,\noppure scrivi il suo codice ed entra." if Realtime.available() \
		else "Il gioco online non è configurato su questo dispositivo."


func _close_lobby() -> void:
	if _og:
		_og.leave()
		_og.queue_free()
		_og = null
	lobby.visible = false


func _my_info() -> Dictionary:
	var h: Dictionary = db.heroes[hero_ids[hero_index]]
	return {"hero": hero_ids[hero_index], "bands": [DeckFactory.BANDS[band_sel[0]], DeckFactory.BANDS[band_sel[1]]], "name": h.get("name", "Amico")}


func _new_og() -> OnlineGame:
	if _og:
		_og.leave()
		_og.queue_free()
	_og = OnlineGame.new()
	add_child(_og)
	_og.failed.connect(func(r: String): lobby_status.text = "Non riesco a collegarmi (%s). Controlla internet e riprova." % r)
	_og.ready_to_start.connect(func(info: Dictionary):
		lobby_status.text = "Si parte!"
		Sfx.play("play")
		var og := _og
		_og = null
		play_online.emit(og, info))
	return _og


func _create_room() -> void:
	if not Realtime.available():
		return
	var code := OnlineGame.new_code()
	_new_og().host(code, _my_info())
	lobby_status.text = "Il tuo codice è  %s\nDillo al tuo amico. Aspetto che entri…" % code


func _join_room() -> void:
	if not Realtime.available():
		return
	var code := OnlineGame.clean_code(code_edit.text)
	if code.length() < 4:
		lobby_status.text = "Scrivi il codice che ti ha dato l'amico (es. MUCA42)."
		return
	var og := _new_og()
	og.join(code, _my_info())
	lobby_status.text = "Entro nella partita %s…" % code
	get_tree().create_timer(12.0).timeout.connect(func():
		if is_instance_valid(og) and og == _og and not og.started:
			lobby_status.text = "Nessuna partita con il codice %s. Controlla il codice, o chiedi all'amico di crearne una nuova." % code)
