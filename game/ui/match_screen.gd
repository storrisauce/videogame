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
var board := BoardView.new()      ## consolle laterali e vassoio (2D)
var board3d := Board3D.new()      ## il tavolo in 3D
var fx := FxLayer.new()
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
	add_child(board)
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
	for l: Label in [caos_label, info_label, opp_label, log_label, banner]:
		l.add_theme_color_override("font_color", Pal.TEXT)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(l)
	caos_label.add_theme_font_size_override("font_size", 16)
	caos_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.add_theme_font_size_override("font_size", 9)
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	opp_label.add_theme_font_size_override("font_size", 9)
	opp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	log_label.add_theme_font_size_override("font_size", 10)
	log_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	log_label.clip_text = true
	banner.add_theme_font_size_override("font_size", 22)
	banner.add_theme_constant_override("outline_size", 7)
	banner.add_theme_color_override("font_outline_color", Art.c("inchiostro"))
	banner.add_theme_color_override("font_color", Pal.YELLOW)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_button.text = "Fine\nturno"
	end_button.pressed.connect(_on_end_turn)
	end_button.add_theme_font_size_override("font_size", 16)
	Juice.press(end_button)
	Juice.press(menu_button)
	add_child(end_button)
	menu_button.text = "Menu"
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
	sb.bg_color = Art.c("legno_2")
	sb.border_color = Art.c("legno_6")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(0)
	sb.set_content_margin_all(8)
	detail.add_theme_stylebox_override("panel", sb)
	over_panel.add_theme_stylebox_override("panel", sb)
	add_child(detail)
	# fine partita
	var ob := VBoxContainer.new()
	over_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	over_text.add_theme_font_size_override("font_size", 18)
	ob.add_child(over_text)
	ob.add_child(over_buttons)
	over_panel.add_child(ob)
	over_panel.visible = false
	add_child(over_panel)
	add_child(fx)
	dial.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dial)
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
	# tavolo 3D tra le due consolle laterali; la mano su un vassoio sotto
	var x0 := SIDE + 4
	var x1 := W - SIDE - 4
	var y_hand := H - HAND_H
	board3d.position = Vector2(x0, 0)
	board3d.size = Vector2(x1 - x0, y_hand + 2)
	board.y_near = 0.0   # il tavolo 2D disegna solo consolle e vassoio
	_place_lanes()
	_place_lanes.call_deferred()
	# consolle: a sinistra il tuo sopravvissuto e il tuo Caos, a destra l'avversario e Fine turno
	var col_h := y_hand - 8
	board.panels = [Rect2(4, 4, SIDE - 4, col_h), Rect2(W - SIDE, 4, SIDE - 4, col_h)]
	board.tray = Rect2(SIDE + 4, y_hand + 2, W - 2 * SIDE - 8, HAND_H - 4)
	var por_h := minf(150.0, col_h - 70.0)
	hero_views[HUMAN].position = Vector2(10, 10)
	hero_views[HUMAN].size = Vector2(SIDE - 16, por_h)
	hero_views[AI].position = Vector2(W - SIDE + 6, 10)
	hero_views[AI].size = Vector2(SIDE - 16, por_h)
	info_label.position = Vector2(8, 14 + por_h)
	info_label.size = Vector2(SIDE - 12, col_h - por_h - 14)
	opp_label.position = Vector2(W - SIDE + 2, 14 + por_h)
	opp_label.size = Vector2(SIDE - 12, col_h - por_h - 14)
	caos_label.position = Vector2(6, y_hand + 10)
	caos_label.size = Vector2(SIDE - 8, 40)
	menu_button.position = Vector2(12, H - 44)
	menu_button.size = Vector2(SIDE - 24, 34)
	end_button.position = Vector2(W - SIDE + 4, y_hand + 6)
	end_button.size = Vector2(SIDE - 12, HAND_H - 14)
	hand_layer.position = Vector2(SIDE + 12, y_hand + 8)
	hand_layer.size = Vector2(W - 2 * SIDE - 24, HAND_H - 12)
	var mid_y := (board3d.project(Vector3(0, 0, 0)).y if board3d.vp.size.x > 0 else y_hand * 0.45)
	log_label.position = Vector2(x0, y_hand - 18)
	log_label.size = Vector2(x1 - x0, 16)
	banner.position = Vector2(x0, mid_y - 14)
	banner.size = Vector2(x1 - x0, 28)
	var lanes_w := x1 - x0
	_detail_rect = Rect2(x0 + 4, 2, lanes_w - 8, 0)
	_detail_strip = Rect2(x0 + 4, 2, lanes_w - 8, 0)
	_place_detail()
	over_panel.position = Vector2(W / 2 - 170, H / 2 - 80)
	over_panel.custom_minimum_size = Vector2(340, 0)
	board.queue_redraw()
	_layout_hand()


## Mette i livelli 2D dei recinti sopra i trapezi del tavolo 3D.
func _place_lanes() -> void:
	if lane_views[0].is_empty() or board3d.vp.size.x <= 0:
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


func _layout_hand() -> void:
	var n := hand_layer.get_child_count()
	if n == 0:
		return
	var cw := 74.0
	var ch := HAND_H - 8
	var step := minf(cw + 6, (hand_layer.size.x - cw) / maxf(n - 1, 1))
	var total := step * (n - 1) + cw
	var start := (hand_layer.size.x - total) / 2.0
	for i in n:
		var v := hand_layer.get_child(i) as CardView
		v.size = Vector2(cw, ch)
		v.position = Vector2(start + i * step, 0)
		if i == selected_hand:
			if speed > 0.0 and is_inside_tree():
				create_tween().tween_property(v, "position:y", -14.0, 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			else:
				v.position.y = -14


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
		v.long_pressed.connect(func(cv: CardView): _show_card_detail(cv.card))
		hand_layer.add_child(v)
	_layout_hand()
	var me := m.players[HUMAN]
	caos_label.text = "Caos\n%d" % me.caos
	info_label.text = "Mazzo %d\nLetamaio %d" % [me.deck.size(), me.discard.size()]
	opp_label.text = "Mano %d · Mazzo %d\nCaos %d" % [m.players[AI].hand.size(), m.players[AI].deck.size(), m.players[AI].caos]
	board3d.reduce_motion = speed <= 0.0 or (profile != null and profile.meno_movimento)
	fx.reduce_motion = board3d.reduce_motion
	board3d.refresh(m)
	_place_lanes()
	board.queue_redraw()
	end_button.disabled = state != "play"
	log_label.text = "  ·  ".join(PackedStringArray(log_lines.slice(maxi(0, log_lines.size() - 2))))


func _playable_anywhere(c: CardInst) -> bool:
	if c.type() == "event":
		return m.can_play(HUMAN, c, -1)
	for i in 4:
		if m.can_play(HUMAN, c, i):
			return true
	return false


## Il numero compare quando il colpo arriva (lo scatto in avanti dura ~0,2 s).
func _delayed_pop(text: String, at: Vector2, color: Color, big: bool, shake_target: Control = null) -> void:
	if speed <= 0.0 or not is_inside_tree():
		return
	await get_tree().create_timer(0.19).timeout
	fx.pop_number(text, at, color, big)
	if shake_target:
		fx.shake_control(shake_target, 8.0 if big else 5.0)


func _log(t: String) -> void:
	log_lines.append(t)
	if log_lines.size() > 50:
		log_lines.remove_at(0)


func _on_event(kind: String, d: Dictionary) -> void:
	var who := "Tu" if d.get("player", 0) == HUMAN else "Avversario"
	match kind:
		"play":
			_log("%s: %s" % [who, db.card(d["card"]).get("name", "?")])
		"scuoti":
			_log("%s scuote %s" % [who, db.card(d["card"]).get("name", "?")])
			board3d.wiggle(d["player"], d["lane"])
		"hero":
			_log("%s: %s!" % [who, m.players[d["player"]].hero["ability_name"]])
			var hv := hero_views[d["player"]]
			if speed > 0.0:
				fx.pop_number(m.players[d["player"]].hero["ability_name"], hv.position + Vector2(hv.size.x / 2.0, hv.size.y * 0.35), Art.c("giallo_2"))
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
		_deselect()
		return
	selected_hand = idx
	var c := v.card
	if c.type() == "event":
		var buttons := []
		if m.can_play(HUMAN, c, -1):
			buttons.append(["Gioca (%d Caos)" % m.cost_of(HUMAN, c), _play_event.bind(idx)])
		_show_detail(_card_text(c), buttons)
	else:
		_show_detail(_card_text(c), [])
		_flash("Scegli un recinto illuminato")
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
			if hv_card and speed > 0.0:
				fx.fly_card(c, m, Rect2(hv_card.global_position - global_position, hv_card.size), board3d.position + board3d.project(board3d.cell_center(HUMAN, i)))
			m.play_card(HUMAN, selected_hand, i)
			_deselect()
			_check_over()
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
		text += "\nDietro: %s — %s" % [l.structure.def["name"], Abilities.describe(l.structure.def, l.structure.level)]
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
	_show_detail("%s\n%s" % [h["name"], Abilities.describe_hero(h)], buttons)
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
	_show_detail("Scegli un bersaglio (bordo rosso).", [["Annulla", _cancel_target]])
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
	var d := c.def
	var head := "%s  (%s %s, costo %d" % [d["name"], Pal.TYPE_NAME.get(c.type(), "").to_lower(), Pal.BAND_NAME.get(c.band(), "").split(" ")[0], c.cost()]
	if c.type() == "creature":
		head += ", attacco %d, vita %d)" % [m.atk_of(c), m.def_of(c)] if m.lane_of(c) >= 0 else ", attacco %d, vita %d)" % [c.base_atk(), c.base_def()]
	else:
		head += ")"
	return "%s\n%s  «%s»" % [head, Abilities.describe(d, c.level), d.get("flavor", "")]


# --- Turni --------------------------------------------------------------------

func _begin_human_turn() -> void:
	state = "play"
	_flash("Tocca a te!")
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
			var res := await _dial("Attacca con %s!" % att.def["name"], m.lane_undefended(HUMAN, i))
			m.attack_lane(HUMAN, i, res == "botta")
			refresh()
			if _check_over():
				return
			await _wait(0.55)
	else:
		_flash("Primo turno: niente attacchi")
		await _wait(0.6)
	m.end_turn(HUMAN)
	refresh()
	if _check_over():
		return
	await _ai_turn()


func _ai_turn() -> void:
	state = "busy"
	_flash("Turno dell'avversario")
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
				await _dial("Tocca per parare!", false)
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
	dial.start(rng, label, empty_lane, float(db.rule("ring_green")), float(db.rule("ring_red")),
		float(db.rule("ring_spin_min")), float(db.rule("ring_spin_max")), float(db.rule("ring_turns")))
	var r: String = await dial.finished
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
		over_text.text = "HAI VINTO!\n+%d scatolette di fagioli" % reward
		if profile:
			profile.fagioli += reward
			profile.vittorie += 1
			profile.save()
	else:
		over_text.text = "HAI PERSO.\nLa tua Pazienza è finita."
		if m.can_resurrect(HUMAN) and profile and profile.tonno > 0:
			_add_over_button("Rialzati (1 scatoletta di tonno, ne hai %d)" % profile.tonno, _resurrect)
	_add_over_button("Rivincita", _end_and.bind("rematch"))
	_add_over_button("Torna al menu", _end_and.bind("menu"))
	over_panel.visible = true
	refresh()
	return true


func _add_over_button(t: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = t
	b.custom_minimum_size = Vector2(0, 40)
	b.pressed.connect(cb)
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
	if m.current == AI:
		_finish_ai_turn()
	else:
		_begin_human_turn()
