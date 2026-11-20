class_name MatchScreen
extends Control
## Schermata di partita in orizzontale (docs/features/schermo-di-gioco/design.md).
## Tu (giocatore 0) in basso, l'IA (giocatore 1) in alto. Grafica provvisoria disegnata da codice.

signal exit_to_menu
signal rematch

const HUMAN := 0
const AI := 1
const SIDE := 100.0
const MID_H := 16.0
const HAND_H := 112.0
const HAND_FRAC := 0.35          ## la mano occupa il terzo inferiore dello schermo

var db: CardDB
var profile: Profile
var m: Match
var rng := RandomNumberGenerator.new()
var speed := 1.0                 ## 0 = nessuna attesa (test)
var autoplay_human := false      ## test: il giocatore umano è guidato dall'IA
var state := "busy"              ## "play", "target", "busy", "over"
var selected_hand := -1
var pending: Dictionary = {}
var log_lines: Array[String] = []
var _loss_recorded := false
var _detail_rect := Rect2()
var _detail_strip := Rect2()

var lane_views := [[], []]
var hero_views: Array[HeroView] = []
var hand_layer := Control.new()
var caos_label := Label.new()
var info_label := Label.new()
var opp_label := Label.new()
var board3d := Board3D.new()      ## il tavolo in 3D
var fx := FxLayer.new()
var my_deck := StatChip.new("deck")
var my_discard := StatChip.new("discard")
var my_caos := StatChip.new("caos", "", true)
var opp_hand := StatChip.new("hand")
var opp_deck := StatChip.new("deck")
var opp_caos := StatChip.new("caos")
var _log_tw: Tween
var _snap: Dictionary = {}       ## stato del tavolo all'ultimo aggiornamento (per mostrare cosa cambia un'abilità)
var log_label := Label.new()
var end_button := Button.new()
var menu_button := Button.new()
var detail := PanelContainer.new()
var detail_text := Label.new()
var detail_buttons := HBoxContainer.new()
var banner := Label.new()
var dial := GeigerDial.new()
var over_panel := PanelContainer.new()
var over_text := Label.new()
var over_sub := Label.new()
var over_buttons := VBoxContainer.new()


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()


# --- Avvio --------------------------------------------------------------------

func start_match(card_db: CardDB, prof: Profile, hero: String, bands: Array, opp_hero: String, opp_bands: Array, seed_value: int) -> void:
	db = card_db
	profile = prof
	rng.seed = seed_value
	m = Match.new(db)
	m.setup(seed_value, [DeckFactory.build(db, bands), DeckFactory.build(db, opp_bands)],
		[DeckFactory.zones(bands), DeckFactory.zones(opp_bands)], [hero, opp_hero])
	m.allow_replace = [true, false]
	m.players[HUMAN].is_human = true
	m.players[HUMAN].empty_deck_rule = "bleed"
	m.players[AI].empty_deck_rule = "reshuffle"
	m.event.connect(_on_event)
	Sfx.music("match")
	m.start()
	_log("Inizia %s." % ("tu" if m.first_player == HUMAN else "l'avversario"))
	refresh()
	if _check_over():
		return
	if m.current == AI:
		await _ai_turn()
	else:
		_begin_human_turn()


# --- Costruzione dell'interfaccia --------------------------------------------

func _build() -> void:
	add_child(board3d)
	board3d.framed.connect(_place_lanes)
	for p in 2:
		for i in 4:
			var lv := LaneView.new(p, i)
			lv.tapped.connect(_on_lane_tapped)
			lv.long_pressed_card.connect(_show_card_detail)
			add_child(lv)
			lane_views[p].append(lv)
		var hv := HeroView.new(p)
		hv.tapped.connect(_on_hero_tapped)
		add_child(hv)
		hero_views.append(hv)
	add_child(hand_layer)
	for l: Label in [caos_label, info_label, opp_label]:
		l.visible = false   # sostituite dai contatori con icona
		add_child(l)
	for chip in [my_deck, my_discard, my_caos, opp_hand, opp_deck, opp_caos]:
		add_child(chip)
	for l: Label in [log_label, banner]:
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(l)
	# registro delle azioni: un banner leggibile in alto che appare a ogni azione e poi svanisce
	log_label.add_theme_font_size_override("font_size", Ui.SMALL)
	log_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	log_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var lsb := StyleBoxFlat.new()
	lsb.bg_color = Color(Art.c("inchiostro"), 0.82)
	lsb.border_color = Art.c("legno_6")
	lsb.set_border_width_all(3)
	lsb.set_corner_radius_all(14)
	lsb.set_content_margin_all(6)
	log_label.add_theme_stylebox_override("normal", lsb)
	log_label.modulate.a = 0.0
	banner.add_theme_font_size_override("font_size", Ui.BIG)
	banner.add_theme_constant_override("outline_size", 10)
	banner.add_theme_color_override("font_outline_color", Art.c("inchiostro"))
	banner.add_theme_color_override("font_color", Art.c("giallo_2"))
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_button.text = "Fine\nturno"
	end_button.pressed.connect(func():
		if state == "play":
			Sfx.play("lever")
			Sfx.buzz("light")
		_on_end_turn())
	end_button.add_theme_font_size_override("font_size", Ui.MID + 2)
	end_button.add_theme_color_override("font_color", Art.c("bianco"))
	for st in ["normal", "hover", "pressed", "disabled", "focus"]:
		var esb := StyleBoxFlat.new()
		esb.bg_color = Art.c({"normal": "radio_1", "hover": "radio_2", "pressed": "verde_4", "disabled": "ferro_2", "focus": "radio_1"}[st])
		esb.border_color = Art.c("inchiostro")
		esb.set_border_width_all(4)
		esb.set_corner_radius_all(16)
		esb.shadow_color = Art.c("inchiostro")
		esb.shadow_offset = Vector2(0, 0 if st == "pressed" else 5)
		esb.shadow_size = 1
		end_button.add_theme_stylebox_override(st, esb)
	Juice.press(end_button)
	Juice.press(menu_button)
	add_child(end_button)
	menu_button.text = "II"
	for st in ["normal", "hover", "pressed", "focus"]:
		var psb := StyleBoxFlat.new()
		psb.bg_color = Art.c({"normal": "ferro_2", "hover": "ferro_3", "pressed": "ferro_1", "focus": "ferro_2"}[st])
		psb.border_color = Art.c("inchiostro")
		psb.set_border_width_all(3)
		psb.set_corner_radius_all(22)
		psb.shadow_color = Art.c("inchiostro")
		psb.shadow_offset = Vector2(0, 0 if st == "pressed" else 3)
		psb.shadow_size = 1
		menu_button.add_theme_stylebox_override(st, psb)
	menu_button.tooltip_text = "Menu"
	menu_button.pressed.connect(func(): exit_to_menu.emit())
	add_child(menu_button)
	# pannello dettagli e azioni
	# scheda compatta in alto: testo a sinistra, azioni a destra (non copre i recinti da cui dipende la scelta)
	var vb := HBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	detail_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_text.add_theme_font_size_override("font_size", 11)
	detail_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(detail_text)
	detail_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	detail_buttons.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vb.add_child(detail_buttons)
	detail.add_child(vb)
	detail.visible = false
	var sb := StyleBoxFlat.new()
	sb.bg_color = Art.c("ferro_1")
	sb.border_color = Art.c("inchiostro")
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(12)
	sb.shadow_color = Art.c("inchiostro")
	sb.shadow_offset = Vector2(0, 4)
	sb.shadow_size = 1
	sb.set_content_margin_all(10)
	detail_text.add_theme_font_override("font", Ui.body())
	detail_text.add_theme_font_size_override("font_size", Ui.BODY + 1)
	detail_text.add_theme_constant_override("outline_size", 0)
	detail.add_theme_stylebox_override("panel", sb)
	over_panel.add_theme_stylebox_override("panel", sb)
	add_child(detail)
	# fine partita
	var ob := VBoxContainer.new()
	ob.add_theme_constant_override("separation", 10)
	over_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	over_text.add_theme_font_size_override("font_size", 46)
	over_text.add_theme_constant_override("outline_size", 14)
	ob.add_child(over_text)
	over_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	over_sub.add_theme_font_size_override("font_size", Ui.MID)
	over_sub.add_theme_color_override("font_color", Art.c("legno_9"))
	ob.add_child(over_sub)
	over_buttons.add_theme_constant_override("separation", 8)
	ob.add_child(over_buttons)
	over_panel.add_child(ob)
	over_panel.visible = false
	add_child(over_panel)
	add_child(fx)
	dial.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dial)
	# sopra a tutto (anche alla carta scelta, che sta a z 5 nella mano)
	fx.z_index = 10
	detail.z_index = 12
	over_panel.z_index = 20
	dial.z_index = 30
	_layout()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_inside_tree():
		_layout()


func _layout() -> void:
	if lane_views[0].is_empty():
		return
	var W := size.x
	var H := size.y
	if W <= 0 or H <= 0:
		return
	# tabellone 3D dietro a tutto; il campo occupa i 2/3 superiori tra i due ritratti
	var y_hand := roundf(H * (1.0 - HAND_FRAC))
	var hero_w := clampf(W * 0.118, 84.0, 108.0)
	board3d.position = Vector2.ZERO
	board3d.size = Vector2(W, H)
	# il tabellone usa tutta la larghezza: solo il fondo (stretto, in prospettiva) passa tra i due ritratti
	board3d.focus = Rect2(4, 0, W - 8, y_hand + 16)
	var hh := minf(hero_w + 84.0, y_hand - 6)
	board3d.avoid = [Rect2(0, 0, hero_w + 16, hh + 52), Rect2(W - hero_w - 16, 0, hero_w + 16, hh + 52)]
	_place_lanes()
	_place_lanes.call_deferred()
	# sopravvissuti negli angoli in alto
	var hero_h := minf(hero_w + 84.0, y_hand - 6)
	hero_views[HUMAN].position = Vector2(8, 6)
	hero_views[HUMAN].size = Vector2(hero_w, hero_h)
	hero_views[AI].position = Vector2(W - hero_w - 8, 6)
	hero_views[AI].size = Vector2(hero_w, hero_h)
	# sotto il ritratto avversario: la sua mano, il suo mazzo e il suo Caos
	var oc := (hero_w - 4) / 3.0
	for k in 3:
		var chip: StatChip = [opp_hand, opp_deck, opp_caos][k]
		chip.position = Vector2(W - hero_w - 8 + k * (oc + 2), hero_h + 8)
		chip.size = Vector2(oc, oc + 12)
	# terzo inferiore: mazzo e Letamaio a sinistra, mano al centro, Caos e Fine turno a destra
	var bottom := H - y_hand
	var side_w := clampf(W * 0.17, 118.0, 170.0)
	var chip_s := minf(bottom - 16, side_w / 2.0 - 6)
	my_deck.position = Vector2(8, H - chip_s - 8)
	my_deck.size = Vector2(chip_s, chip_s)
	my_discard.position = Vector2(8 + chip_s + 4, H - chip_s - 8)
	my_discard.size = Vector2(chip_s, chip_s)
	menu_button.position = Vector2(8, y_hand - 8 - 44) if y_hand > hero_h + 60 else Vector2(8, hero_h + 10)
	menu_button.size = Vector2(44, 44)
	# Caos e Fine turno: il gettone del Caos grande, il bottone evidente ma non più grande della mano
	my_caos.position = Vector2(W - side_w - 6, H - bottom + 6)
	my_caos.size = Vector2(side_w * 0.42, bottom - 12)
	end_button.position = Vector2(W - side_w * 0.58 - 4, H - bottom + 18)
	end_button.size = Vector2(side_w * 0.58 - 4, bottom - 30)
	hand_layer.position = Vector2(side_w + 16, y_hand)
	hand_layer.size = Vector2(W - 2 * side_w - 32, bottom)
	var mid_y := board3d.project(Vector3(0, 0, 0)).y if board3d.has_view() else y_hand * 0.45
	banner.position = Vector2(hero_w + 16, mid_y - 20)
	banner.size = Vector2(W - 2 * hero_w - 32, 40)
	log_label.position = Vector2(W / 2.0 - 180, 6)
	log_label.size = Vector2(360, 0)
	_detail_rect = Rect2(hero_w + 16, 4, W - 2 * hero_w - 32, 0)
	# scelta del bersaglio: la striscia sta sopra la mano (che intanto non serve), così si vedono tutte e due le file
	_detail_strip = Rect2(side_w + 16, y_hand + 10, W - 2 * side_w - 32, 0)
	_place_detail()
	over_panel.custom_minimum_size = Vector2(320, 0)
	over_panel.position = Vector2(W / 2 - 160, H * 0.18)
	_layout_hand()


## Mette i livelli 2D dei recinti sopra i trapezi del tavolo 3D.
func _place_lanes() -> void:
	if lane_views[0].is_empty() or not board3d.has_view():
		return
	for p in 2:
		for i in 4:
			var lv: LaneView = lane_views[p][i]
			var poly := board3d.cell_poly(p, i)
			var bb := Rect2(poly[0], Vector2.ZERO)
			for v in poly:
				bb = bb.expand(v)
			lv.position = board3d.position + bb.position
			lv.size = bb.size
			var local := PackedVector2Array()
			for v in poly:
				local.append(v - bb.position)
			lv.poly = local
			lv.head = board3d.head_point(p, i) - bb.position
			lv.queue_redraw()


## Mano a ventaglio: carte grandi sovrapposte, leggermente ruotate su un arco. La carta scelta sale,
## si raddrizza e si ingrandisce mostrando il testo dell'abilità (entrate in ease-out, 180 ms).
func _layout_hand() -> void:
	var n := hand_layer.get_child_count()
	if n == 0:
		return
	var mid := (n - 1) / 2.0
	var arc := 1.4
	var ch := minf(hand_layer.size.y - 20.0 - mid * mid * arc, 160.0)   # resta spazio per la rotazione del ventaglio
	# le carte si sovrappongono al massimo del 6%: con tante carte o schermi stretti diventano più piccole, mai coperte
	var cw := roundf(minf(ch * 0.74, hand_layer.size.x / (n - (n - 1) * 0.06)))
	ch = roundf(cw / 0.74)
	var step := minf(cw * 0.94, (hand_layer.size.x - cw) / maxf(n - 1, 1))
	var total := step * (n - 1) + cw
	var start := (hand_layer.size.x - total) / 2.0
	for i in n:
		var v := hand_layer.get_child(i) as CardView
		var d := i - mid
		var target_pos := Vector2(start + i * step, 4 + d * d * arc)
		var target_rot := deg_to_rad(d * 3.5)
		var target_size := Vector2(cw, ch)
		if i == selected_hand:
			target_size = Vector2(cw * 1.6, ch * 1.6)
			target_pos = Vector2(start + i * step + cw / 2.0 - target_size.x / 2.0, hand_layer.size.y - target_size.y - 8)
			target_pos.x = clampf(target_pos.x, -hand_layer.position.x + 4, hand_layer.size.x + 40 - target_size.x)
			target_rot = 0.0
			v.z_index = 5
		v.pivot_offset = Vector2(cw / 2.0, ch)
		v.size = target_size
		if speed > 0.0 and is_inside_tree() and i == selected_hand:
			v.position = Vector2(start + i * step, 4)
			var tw := create_tween().set_parallel(true)
			tw.tween_property(v, "position", target_pos, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tw.tween_property(v, "rotation", target_rot, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		else:
			v.position = target_pos
			v.rotation = target_rot
		v.set_meta("rest_y", target_pos.y)


## Passaggio del mouse (solo dove c'è un mouse): la carta sale un po'.
func _hover_card(v: CardView, on: bool) -> void:
	if not is_instance_valid(v) or speed <= 0.0:
		return
	if v.z_index > 0:   # la carta scelta resta dov'è
		return
	var rest: float = v.get_meta("rest_y", v.position.y)
	var tw := v.create_tween()
	tw.tween_property(v, "position:y", rest - 16.0 if on else rest, 0.14).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


# --- Aggiornamento ------------------------------------------------------------

func refresh() -> void:
	if m == null:
		return
	for p in 2:
		for i in 4:
			var lv: LaneView = lane_views[p][i]
			lv.refresh(m)
			lv.highlighted = false
			lv.target_mark = false
		hero_views[p].refresh(m)
		hero_views[p].highlighted = false
	# carte selezionabili e bersagli
	if state == "play" and selected_hand >= 0 and selected_hand < m.players[HUMAN].hand.size():
		var c := m.players[HUMAN].hand[selected_hand]
		if c.type() != "event":
			for i in 4:
				lane_views[HUMAN][i].highlighted = m.can_play(HUMAN, c, i)
	if state == "target":
		for t in pending.get("targets", []):
			if t is Dictionary and t.has("lane"):
				lane_views[t["p"]][t["lane"]].target_mark = true
	if state == "play":
		hero_views[HUMAN].highlighted = m.can_use_hero(HUMAN)
	for p in 2:
		for i in 4:
			lane_views[p][i].queue_redraw()
		hero_views[p].queue_redraw()
	# mano
	for ch in hand_layer.get_children():
		hand_layer.remove_child(ch)
		ch.queue_free()
	var hand := m.players[HUMAN].hand
	for i in hand.size():
		var v := CardView.new()
		v.setup(hand[i], m)
		v.highlighted = (i == selected_hand)
		v.dimmed = not _playable_anywhere(hand[i])
		v.tapped.connect(_on_hand_tapped)
		v.mouse_entered.connect(_hover_card.bind(v, true))
		v.mouse_exited.connect(_hover_card.bind(v, false))
		v.long_pressed.connect(func(cv: CardView): _show_card_detail(cv.card))
		hand_layer.add_child(v)
	_layout_hand()
	var me := m.players[HUMAN]
	my_deck.set_value(me.deck.size())
	my_discard.set_value(me.discard.size())
	my_caos.set_value(me.caos)
	opp_hand.set_value(m.players[AI].hand.size())
	opp_deck.set_value(m.players[AI].deck.size())
	opp_caos.set_value(m.players[AI].caos)
	caos_label.text = "Caos\n%d" % me.caos
	info_label.text = "Mazzo %d\nLetamaio %d" % [me.deck.size(), me.discard.size()]
	opp_label.text = "Mano %d · Mazzo %d\nCaos %d" % [m.players[AI].hand.size(), m.players[AI].deck.size(), m.players[AI].caos]
	hand_layer.modulate.a = 0.3 if state == "target" else 1.0
	board3d.reduce_motion = speed <= 0.0 or (profile != null and profile.meno_movimento)
	fx.reduce_motion = board3d.reduce_motion
	board3d.refresh(m)
	_place_lanes()
	end_button.disabled = state != "play"
	_end_pulse(state == "play" and GreedyAI.choose(m, HUMAN).is_empty())
	_snap = _snapshot()


func _playable_anywhere(c: CardInst) -> bool:
	if c.type() == "event":
		return m.can_play(HUMAN, c, -1)
	for i in 4:
		if m.can_play(HUMAN, c, i):
			return true
	return false


# --- Effetti delle abilità ------------------------------------------------------
## Ogni abilità (Scuotere, eroe, evento, struttura) mostra cosa ha cambiato davvero: si confronta il tavolo prima
## (ultimo refresh) e dopo. Un raggio verde va dalla fonte a ogni bersaglio, poi compaiono i numeri:
## danno rosso, cura verde, +DEF azzurro, ±ATK arancio, Caos e carte pescate. Funziona per tutte le famiglie.

func _snapshot() -> Dictionary:
	var s := {}
	if m == null:
		return s
	for p in 2:
		var ps := m.players[p]
		s["hp%d" % p] = ps.hp
		s["caos%d" % p] = ps.caos
		s["hand%d" % p] = ps.hand.size()
		for i in 4:
			var c := ps.lanes[i].creature
			if c:
				s["c%d_%d" % [p, i]] = [c.get_instance_id(), m.atk_of(c), m.def_of(c), m.health_of(c)]
	return s


func _lane_point(p: int, i: int) -> Vector2:
	return board3d.position + board3d.head_point(p, i)


func _hero_point(p: int) -> Vector2:
	var hv := hero_views[p]
	return hv.position + hv.size * Vector2(0.5, 0.3)


func _ability_fx(p: int, src: Vector2, card_name: String) -> void:
	if speed <= 0.0 or not is_inside_tree() or _snap.is_empty():
		return
	var after := _snapshot()
	var before := _snap
	_snap = after
	var hits: Array = []   # [punto, testo, colore, grande, controllo da scuotere, lane]
	for q in 2:
		for i in 4:
			var k := "c%d_%d" % [q, i]
			var b: Array = before.get(k, [])
			var a: Array = after.get(k, [])
			if b.is_empty() or a.is_empty() or b[0] != a[0]:
				continue
			var at := _lane_point(q, i)
			if a[3] < b[3]:
				hits.append([at, "-%d" % (b[3] - a[3]), Art.c("rosso_3"), true, null, [q, i]])
			elif a[3] > b[3] and a[2] == b[2]:
				hits.append([at, "+%d" % (a[3] - b[3]), Art.c("verde_4"), false, null, [q, i]])
			if a[2] != b[2]:
				hits.append([at + Vector2(0, -22), "%+d DEF" % (a[2] - b[2]), Art.c("acqua_5"), false, null, [q, i]])
			if a[1] != b[1]:
				hits.append([at + Vector2(0, -44), "%+d ATK" % (a[1] - b[1]), Art.c("arancio_4"), false, null, [q, i]])
		var dh: int = after.get("hp%d" % q, 0) - before.get("hp%d" % q, 0)
		if dh != 0:
			hits.append([_hero_point(q), "%+d" % dh, Art.c("rosso_3") if dh < 0 else Art.c("verde_4"), dh < 0, hero_views[q], null])
		var dc: int = after.get("caos%d" % q, 0) - before.get("caos%d" % q, 0)
		if dc != 0 and not (q == p and dc < 0):   # il costo pagato non è un effetto
			var chip := my_caos if q == HUMAN else opp_caos
			hits.append([chip.position + chip.size / 2.0, "%+d Caos" % dc, Art.c("radio_2"), false, null, null])
		var dd: int = after.get("hand%d" % q, 0) - before.get("hand%d" % q, 0)
		if dd > 0 and q == p:
			var chip2 := my_deck if q == HUMAN else opp_hand
			hits.append([chip2.position + chip2.size / 2.0, "+%d carte" % dd, Art.c("legno_9"), false, null, null])
	_play_ability_fx(src, hits)


func _play_ability_fx(src: Vector2, hits: Array) -> void:
	var t := 0.0
	for h in hits:
		t = maxf(t, fx.beam(src, h[0], Art.c("radio_2")))
	if t > 0.0:
		Sfx.play("zap")
		await get_tree().create_timer(t).timeout
	# un suono per tipo di effetto (non uno per bersaglio): cura/+, -, Caos, carte
	var kinds := {}
	for h in hits:
		var txt: String = h[1]
		if txt.ends_with("Caos"):
			kinds["caos"] = true
		elif txt.ends_with("carte"):
			kinds["card_pick"] = true
		elif h[2] == Art.c("rosso_3"):
			kinds["hit_hero" if h[4] else "hit"] = true
		elif txt.begins_with("-"):
			kinds["debuff"] = true
		else:
			kinds["buff"] = true
	for k: String in kinds:
		if k != "hit":   # il colpo sulla creatura suona già in board3d.hit
			Sfx.play(k)
	for h in hits:
		fx.pop_number(h[1], h[0], h[2], h[3])
		if h[4]:
			fx.shake_control(h[4], 7.0 if h[3] else 4.0)
		if h[5] is Array:
			var lane: Array = h[5]
			if h[2] == Art.c("rosso_3"):
				board3d.hit(lane[0], lane[1], false)
			else:
				board3d.glow(lane[0], lane[1], h[2])


## Il numero compare quando il colpo arriva (lo scatto in avanti dura ~0,2 s).
func _delayed_pop(text: String, at: Vector2, color: Color, big: bool, shake_target: Control = null) -> void:
	if speed <= 0.0 or not is_inside_tree():
		return
	await get_tree().create_timer(0.19).timeout
	fx.pop_number(text, at, color, big)
	if shake_target:
		fx.shake_control(shake_target, 8.0 if big else 5.0)


## "Fine turno" pulsa quando non restano mosse utili.
var _end_tw: Tween
func _end_pulse(on: bool) -> void:
	if _end_tw:
		_end_tw.kill()
		_end_tw = null
	end_button.offset_transform_enabled = true
	end_button.offset_transform_pivot = end_button.size / 2.0
	if not on or speed <= 0.0 or (profile and profile.meno_movimento):
		end_button.offset_transform_scale = Vector2.ONE
		return
	_end_tw = create_tween().set_loops()
	_end_tw.tween_property(end_button, "offset_transform_scale", Vector2(1.06, 1.06), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_end_tw.tween_property(end_button, "offset_transform_scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _log(t: String) -> void:
	log_lines.append(t)
	log_label.text = t
	log_label.size = Vector2(log_label.size.x, 0)
	if speed > 0.0 and is_inside_tree():
		if _log_tw:
			_log_tw.kill()
		log_label.modulate.a = 1.0
		_log_tw = create_tween()
		_log_tw.tween_interval(2.2)
		_log_tw.tween_property(log_label, "modulate:a", 0.0, 0.3)
	if log_lines.size() > 50:
		log_lines.remove_at(0)


func _on_event(kind: String, d: Dictionary) -> void:
	var who := "Tu" if d.get("player", 0) == HUMAN else "Avversario"
	match kind:
		"play":
			_log("%s: %s" % [who, db.card(d["card"]).get("name", "?")])
			var ctype: String = db.card(d["card"]).get("type", "")
			if ctype != "creature":
				var src := _lane_point(d["player"], d["lane"]) if d["lane"] >= 0 else board3d.project(Vector3(0, 0.6, 0))
				_ability_fx(d["player"], src, db.card(d["card"]).get("name", ""))
		"scuoti":
			_log("%s scuote %s" % [who, db.card(d["card"]).get("name", "?")])
			board3d.wiggle(d["player"], d["lane"])
			_ability_fx(d["player"], _lane_point(d["player"], d["lane"]), db.card(d["card"]).get("name", ""))
		"hero":
			_log("%s: %s!" % [who, m.players[d["player"]].hero["ability_name"]])
			if speed > 0.0:
				Sfx.play("hero_power")
				Sfx.buzz("hit")
			var hv := hero_views[d["player"]]
			if speed > 0.0:
				fx.pop_number(m.players[d["player"]].hero["ability_name"], hv.position + Vector2(hv.size.x / 2.0, hv.size.y * 0.35), Art.c("giallo_2"))
			_ability_fx(d["player"], hv.position + hv.size * Vector2(0.5, 0.3), "")
		"attack":
			_log("%s colpisce %s: -%d%s" % [db.card(d["card"])["name"], db.card(d["target"])["name"], d["damage"], " BOTTA ATOMICA!" if d["crit"] else ""])
			board3d.attack(d["player"], d["lane"], true, d["crit"])
			var at := board3d.position + board3d.head_point(1 - d["player"], d["lane"])
			_delayed_pop("-%d" % d["damage"], at, Art.c("allarme") if d["crit"] else Art.c("rosso_3"), d["crit"])
		"attack_hero":
			_log("%s colpisce la Pazienza: -%d%s" % [db.card(d["card"])["name"], d["damage"], " BOTTA ATOMICA!" if d["crit"] else ""])
			board3d.attack(d["player"], d["lane"], false, d["crit"])
			var hv2 := hero_views[1 - d["player"]]
			_delayed_pop("-%d" % d["damage"], hv2.position + Vector2(hv2.size.x / 2.0, hv2.size.y * 0.4), Art.c("allarme") if d["crit"] else Art.c("rosso_3"), d["crit"], hv2)
		"death":
			_log("%s finisce nel Letamaio" % db.card(d["card"])["name"])
		"empty_deck":
			_log("%s: mazzo finito!" % who)
		"resurrect":
			_log("Ti rialzi!")


# --- Input del giocatore ------------------------------------------------------

func _on_hand_tapped(v: CardView) -> void:
	if state != "play":
		return
	var idx := m.players[HUMAN].hand.find(v.card)
	if idx < 0:
		return
	if idx == selected_hand:
		Sfx.play("card_drop")
		_deselect()
		return
	Sfx.play("card_pick")
	Sfx.buzz("tap")
	selected_hand = idx
	var c := v.card
	if c.type() == "event":
		# la carta ingrandita dice già tutto: qui solo l'azione
		if m.can_play(HUMAN, c, -1):
			_show_detail("", [["Gioca", _play_event.bind(idx)]])
		else:
			detail.visible = false
	else:
		detail.visible = false   # i recinti illuminati bastano: niente scritte in più
	refresh()


func _on_lane_tapped(p: int, i: int) -> void:
	if state == "target":
		var t := {"p": p, "lane": i}
		if pending.get("targets", []).has(t):
			_resolve_pending(t)
		return
	if state != "play":
		return
	if selected_hand >= 0 and p == HUMAN:
		var c := m.players[HUMAN].hand[selected_hand]
		if c.type() != "event" and m.can_play(HUMAN, c, i):
			var hv_card := hand_layer.get_child(selected_hand) as CardView if selected_hand < hand_layer.get_child_count() else null
			Sfx.play("whoosh")
			if hv_card and speed > 0.0:
				fx.fly_card(c, m, Rect2(hv_card.global_position - global_position, hv_card.size), board3d.position + board3d.project(board3d.cell_center(HUMAN, i)))
			m.play_card(HUMAN, selected_hand, i)
			_deselect()
			_check_over()
			return
		elif c.type() != "event" and m.players[p].lanes[i].creature == null:
			Sfx.play("deny")
			Sfx.buzz("light")
			fx.shake_control(board3d, 3.0)
			return
	var l := m.players[p].lanes[i]
	var shown := l.creature if l.creature else l.structure
	if shown == null:
		_deselect()
		return
	var buttons := []
	if p == HUMAN and l.creature and m.can_scuoti(HUMAN, i):
		buttons.append(["Scuoti (%d Caos)" % l.creature.scuoti_cost(), _scuoti.bind(i)])
	var text := _card_text(shown)
	if l.creature and l.structure:
		text += "\n%s: %s" % [l.structure.def["name"], Abilities.describe(l.structure.def, l.structure.level)]
	selected_hand = -1
	_show_detail(text, buttons)
	refresh()


func _on_hero_tapped(p: int) -> void:
	if state != "play":
		return
	var h := m.players[p].hero
	var buttons := []
	if p == HUMAN and m.can_use_hero(HUMAN):
		buttons.append(["Usa abilità", _use_hero])
	selected_hand = -1
	_show_detail("%s: %s" % [h["name"], Abilities.describe_hero(h)], buttons)
	refresh()


func _scuoti(lane: int) -> void:
	var targets := Abilities.targets(m, HUMAN, m.players[HUMAN].lanes[lane].creature, lane)
	if targets == [null]:
		m.scuoti(HUMAN, lane, null)
		_after_action()
	else:
		_ask_target({"kind": "scuoti", "lane": lane, "targets": targets})


func _use_hero() -> void:
	var targets := Abilities.hero_targets(m, HUMAN)
	if targets == [null]:
		m.use_hero(HUMAN, null)
		_after_action()
	elif targets[0] is Dictionary and targets[0].has("band"):
		var buttons := []
		for t in targets:
			buttons.append([Pal.BAND_NAME[t["band"]].split(" ")[0], _resolve_hero_band.bind(t)])
		_show_detail("Scegli la banda che costerà meno:", buttons)
	else:
		_ask_target({"kind": "hero", "targets": targets})


func _resolve_hero_band(t: Dictionary) -> void:
	m.use_hero(HUMAN, t)
	_after_action()


func _play_event(idx: int) -> void:
	var c := m.players[HUMAN].hand[idx]
	var targets := Abilities.targets(m, HUMAN, c, -1)
	if targets == [null]:
		m.play_card(HUMAN, idx, -1, null)
		_after_action()
	else:
		_ask_target({"kind": "event", "hand": idx, "targets": targets})


func _ask_target(p: Dictionary) -> void:
	pending = p
	state = "target"
	_show_detail("Scegli il bersaglio", [["Annulla", _cancel_target]])
	refresh()


func _cancel_target() -> void:
	pending = {}
	state = "play"
	_deselect()


func _resolve_pending(t: Dictionary) -> void:
	match pending["kind"]:
		"scuoti":
			m.scuoti(HUMAN, pending["lane"], t)
		"hero":
			m.use_hero(HUMAN, t)
		"event":
			m.play_card(HUMAN, pending["hand"], -1, t)
	pending = {}
	state = "play"
	_after_action()


func _after_action() -> void:
	_deselect()
	_check_over()


func _deselect() -> void:
	selected_hand = -1
	detail.visible = false
	refresh()


func _show_detail(text: String, buttons: Array) -> void:
	detail_text.text = text
	detail_text.visible = text != ""
	for b in detail_buttons.get_children():
		detail_buttons.remove_child(b)
		b.queue_free()
	for spec in buttons:
		var b := Button.new()
		b.text = spec[0]
		b.custom_minimum_size = Vector2(0, 36)
		b.pressed.connect(spec[1])
		Juice.press(b)
		detail_buttons.add_child(b)
	if state != "target" and not buttons.is_empty():
		var close := Button.new()
		close.text = "Chiudi"
		close.custom_minimum_size = Vector2(0, 36)
		close.pressed.connect(_deselect)
		detail_buttons.add_child(close)
	detail.visible = true
	_place_detail()


func _place_detail() -> void:
	# Normale: sopra la fila avversaria (i tuoi recinti restano visibili).
	# Scelta del bersaglio: una striscia al centro, così si vedono entrambe le file.
	var r := _detail_strip if state == "target" else _detail_rect
	detail.position = r.position
	var bw := detail_buttons.get_combined_minimum_size().x + 12.0 if detail_buttons.get_child_count() > 0 else 0.0
	detail_text.custom_minimum_size = Vector2(maxf(r.size.x - 24.0 - bw, 120.0), 0)
	detail.custom_minimum_size = Vector2(r.size.x, 0)
	detail.size = Vector2(r.size.x, 0)
	_shrink_detail.call_deferred()


func _shrink_detail() -> void:
	detail.size = Vector2(detail.custom_minimum_size.x, 0)


func _show_card_detail(c: CardInst) -> void:
	if c and state in ["play", "target"]:
		_show_detail(_card_text(c), [])


func _card_text(c: CardInst) -> String:
	# breve: nome e abilità. Costo, attacco e vita si vedono già sulla carta e sul tavolo.
	return "%s: %s" % [c.def["name"], Abilities.describe(c.def, c.level)]


# --- Turni --------------------------------------------------------------------

func _begin_human_turn() -> void:
	state = "play"
	_flash("Tocca a te!")
	if speed > 0.0:
		Sfx.play("turn_you", 1.0, 0.0)
		Sfx.buzz("light")
	refresh()
	if autoplay_human:
		_auto_human.call_deferred()


func _auto_human() -> void:
	while state == "play":
		var a := GreedyAI.choose(m, HUMAN)
		if a.is_empty():
			break
		m.apply(HUMAN, a)
		if _check_over():
			return
	if state == "play":
		_on_end_turn()


func _on_end_turn() -> void:
	if state != "play":
		return
	state = "busy"
	_deselect()
	if m.can_attack_this_turn(HUMAN):
		for i in 4:
			if not m.attack_needs_dial(HUMAN, i):
				continue
			var att := m.players[HUMAN].lanes[i].creature
			var res := await _dial(att.def["name"], m.lane_undefended(HUMAN, i))
			m.attack_lane(HUMAN, i, res == "botta")
			refresh()
			if _check_over():
				return
			await _wait(0.55)
	else:
		_flash("Primo turno: niente attacco")
		await _wait(0.6)
	m.end_turn(HUMAN)
	refresh()
	if _check_over():
		return
	await _ai_turn()


func _ai_turn() -> void:
	state = "busy"
	_flash("Turno dell'avversario")
	if speed > 0.0:
		Sfx.play("turn_opp", 1.0, 0.0)
	refresh()
	await _wait(0.5)
	for n in 30:
		var a := GreedyAI.choose(m, AI)
		if a.is_empty() or not m.apply(AI, a):
			break
		refresh()
		if _check_over():
			return
		await _wait(0.6)
	if m.can_attack_this_turn(AI):
		for i in 4:
			if not m.attack_needs_dial(AI, i):
				continue
			# Il quadrante compare anche in difesa ma non cambia il danno (D-005, come nel genere).
			if not m.lane_undefended(AI, i):
				await _dial("Para!", false)
			m.attack_lane(AI, i, false)
			refresh()
			if _check_over():
				return
			await _wait(0.55)
	_finish_ai_turn()


func _finish_ai_turn() -> void:
	m.end_turn(AI)
	refresh()
	if _check_over():
		return
	_begin_human_turn()


func _dial(label: String, empty_lane: bool) -> String:
	if speed <= 0.0 or (profile and profile.mirino_automatico) or autoplay_human:
		return "colpo"
	detail.visible = false
	dial.start(rng, label, empty_lane, float(db.rule("ring_green")), float(db.rule("ring_red")),
		float(db.rule("ring_spin_min")), float(db.rule("ring_spin_max")), float(db.rule("ring_turns")))
	var r: String = await dial.finished
	Sfx.play("dial_" + r, 1.0, 0.0)
	Sfx.buzz({"botta": "heavy", "colpo": "light", "normale": "tap"}[r])
	_flash({"botta": "BOTTA ATOMICA!", "colpo": "Colpito!", "normale": "Colpo normale"}[r])
	return r


func _wait(t: float) -> void:
	if speed > 0.0:
		await get_tree().create_timer(t / speed).timeout


var _banner_tw: Tween


## Avviso al centro del tavolo: entra scivolando e ingrandendosi appena (ease-out), resta, svanisce più in fretta.
func _flash(t: String) -> void:
	banner.text = t
	banner.modulate.a = 1.0
	banner.pivot_offset = banner.size / 2.0
	if speed > 0.0 and is_inside_tree():
		if _banner_tw:
			_banner_tw.kill()
		banner.scale = Vector2(0.92, 0.92)
		banner.modulate.a = 0.0
		_banner_tw = create_tween()
		_banner_tw.set_parallel(true)
		_banner_tw.tween_property(banner, "modulate:a", 1.0, 0.16)
		_banner_tw.tween_property(banner, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_banner_tw.chain().tween_interval(0.9 / speed)
		_banner_tw.chain().tween_property(banner, "modulate:a", 0.0, 0.25 / speed)


# --- Fine partita --------------------------------------------------------------

func _check_over() -> bool:
	if m.winner < 0:
		return false
	state = "over"
	detail.visible = false
	for b in over_buttons.get_children():
		over_buttons.remove_child(b)
		b.queue_free()
	if m.winner == HUMAN:
		var reward := db.rule_i("reward_win_fagioli")
		over_text.text = "Hai vinto!"
		over_text.add_theme_color_override("font_color", Art.c("radio_1"))
		over_sub.text = "+%d scatolette di fagioli" % reward
		if speed > 0.0:
			Sfx.music("")
			Sfx.play("win", 1.0, 0.0)
			Sfx.play_at(1.3, "coins", 1.0, 0.0)
			Sfx.buzz("win")
		if profile:
			profile.fagioli += reward
			profile.vittorie += 1
			profile.save()
	else:
		over_text.text = "Hai perso"
		over_text.add_theme_color_override("font_color", Art.c("rosso_3"))
		over_sub.text = "Pazienza finita"
		if speed > 0.0:
			Sfx.music("")
			Sfx.play("lose", 1.0, 0.0)
			Sfx.buzz("heavy")
		if m.can_resurrect(HUMAN) and profile and profile.tonno > 0:
			_add_over_button("Rialzati (1 tonno)", _resurrect, true)
	_add_over_button("Rivincita", _end_and.bind("rematch"), m.winner == HUMAN or not (m.can_resurrect(HUMAN) and profile and profile.tonno > 0))
	_add_over_button("Menu", _end_and.bind("menu"))
	over_panel.visible = true
	if speed > 0.0 and is_inside_tree():
		over_panel.pivot_offset = over_panel.size / 2.0
		over_panel.scale = Vector2(0.9, 0.9)
		over_panel.modulate.a = 0.0
		var tw := create_tween().set_parallel(true)
		tw.tween_property(over_panel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(over_panel, "modulate:a", 1.0, 0.18)
	refresh()
	return true


func _add_over_button(t: String, cb: Callable, primary := false) -> void:
	var b := Button.new()
	b.text = t
	b.custom_minimum_size = Vector2(0, 54 if primary else 44)
	b.pressed.connect(cb)
	if primary:
		b.add_theme_font_size_override("font_size", Ui.MID + 2)
		for st in ["normal", "hover", "pressed", "focus"]:
			var sb := StyleBoxFlat.new()
			sb.bg_color = Art.c({"normal": "radio_1", "hover": "radio_2", "pressed": "verde_4", "focus": "radio_1"}[st])
			sb.border_color = Art.c("inchiostro")
			sb.set_border_width_all(4)
			sb.set_corner_radius_all(16)
			sb.shadow_color = Art.c("inchiostro")
			sb.shadow_offset = Vector2(0, 0 if st == "pressed" else 5)
			sb.shadow_size = 1
			b.add_theme_stylebox_override(st, sb)
	Juice.press(b)
	over_buttons.add_child(b)


func _record_loss() -> void:
	if m.winner == AI and profile and not _loss_recorded:
		_loss_recorded = true
		profile.fagioli += db.rule_i("reward_loss_fagioli")
		profile.sconfitte += 1
		profile.save()


func _end_and(what: String) -> void:
	_record_loss()
	if what == "rematch":
		rematch.emit()
	else:
		exit_to_menu.emit()


func _resurrect() -> void:
	profile.tonno -= 1
	profile.save()
	m.resurrect(HUMAN)
	over_panel.visible = false
	Sfx.play("resurrect", 1.0, 0.0)
	Sfx.music("match")
	if m.current == AI:
		_finish_ai_turn()
	else:
		_begin_human_turn()
