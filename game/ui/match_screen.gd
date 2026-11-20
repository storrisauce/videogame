class_name MatchScreen
extends Control
## Schermata di partita in orizzontale (docs/features/schermo-di-gioco/design.md).
## Tu (giocatore 0) in basso, l'IA (giocatore 1) in alto. Grafica provvisoria disegnata da codice.

signal exit_to_menu
signal rematch

const HUMAN := 0
const AI := 1
const SIDE := 92.0
const MID_H := 24.0
const HAND_H := 108.0

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

var lane_views := [[], []]
var hero_views: Array[HeroView] = []
var hand_layer := Control.new()
var caos_label := Label.new()
var info_label := Label.new()
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
	var bg := ColorRect.new()
	bg.color = Pal.BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
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
	for l: Label in [caos_label, info_label, log_label, banner]:
		l.add_theme_color_override("font_color", Pal.TEXT)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(l)
	caos_label.add_theme_font_size_override("font_size", 18)
	caos_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.add_theme_font_size_override("font_size", 9)
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	log_label.add_theme_font_size_override("font_size", 10)
	log_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	log_label.clip_text = true
	banner.add_theme_font_size_override("font_size", 16)
	banner.add_theme_color_override("font_color", Pal.YELLOW)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_button.text = "Fine\nturno"
	end_button.pressed.connect(_on_end_turn)
	add_child(end_button)
	menu_button.text = "Menu"
	menu_button.pressed.connect(func(): exit_to_menu.emit())
	add_child(menu_button)
	# pannello dettagli e azioni
	var vb := VBoxContainer.new()
	detail_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_text.add_theme_font_size_override("font_size", 11)
	vb.add_child(detail_text)
	detail_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(detail_buttons)
	detail.add_child(vb)
	detail.visible = false
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
	var x0 := SIDE + 4
	var lanes_w := W - 2 * SIDE - 8
	var lw := lanes_w / 4.0
	var row_h := (H - HAND_H - MID_H - 8) / 2.0
	var y_opp := 4.0
	var y_mid := y_opp + row_h
	var y_me := y_mid + MID_H
	var y_hand := y_me + row_h + 4
	for i in 4:
		var opp: LaneView = lane_views[AI][i]
		opp.position = Vector2(x0 + i * lw + 2, y_opp)
		opp.size = Vector2(lw - 4, row_h)
		var me: LaneView = lane_views[HUMAN][i]
		me.position = Vector2(x0 + i * lw + 2, y_me)
		me.size = Vector2(lw - 4, row_h)
	hero_views[AI].position = Vector2(4, y_opp)
	hero_views[AI].size = Vector2(SIDE - 8, row_h)
	hero_views[HUMAN].position = Vector2(4, y_me)
	hero_views[HUMAN].size = Vector2(SIDE - 8, row_h)
	log_label.position = Vector2(x0, y_mid + 3)
	log_label.size = Vector2(lanes_w, MID_H - 4)
	caos_label.position = Vector2(W - SIDE, y_opp + 4)
	caos_label.size = Vector2(SIDE - 4, 28)
	info_label.position = Vector2(W - SIDE, y_opp + 34)
	info_label.size = Vector2(SIDE - 4, row_h - 34)
	end_button.position = Vector2(W - SIDE + 4, y_me + 8)
	end_button.size = Vector2(SIDE - 12, row_h - 16)
	menu_button.position = Vector2(W - SIDE + 4, y_hand + HAND_H - 40)
	menu_button.size = Vector2(SIDE - 12, 32)
	hand_layer.position = Vector2(x0, y_hand)
	hand_layer.size = Vector2(lanes_w, HAND_H - 6)
	banner.position = Vector2(x0, y_mid - 14)
	banner.size = Vector2(lanes_w, 24)
	detail.position = Vector2(x0 + 20, y_mid - 40)
	detail.size = Vector2(lanes_w - 40, 0)
	detail.custom_minimum_size = Vector2(lanes_w - 40, 0)
	over_panel.position = Vector2(W / 2 - 170, H / 2 - 80)
	over_panel.custom_minimum_size = Vector2(340, 0)
	_layout_hand()


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
		v.position = Vector2(start + i * step, 0 if i != selected_hand else -10)


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
	caos_label.text = "Caos %d" % me.caos
	info_label.text = "Mazzo %d\nLetamaio %d\n\nAvversario:\nmano %d · mazzo %d\nCaos %d" % [
		me.deck.size(), me.discard.size(), m.players[AI].hand.size(), m.players[AI].deck.size(), m.players[AI].caos]
	end_button.disabled = state != "play"
	log_label.text = "  ·  ".join(PackedStringArray(log_lines.slice(maxi(0, log_lines.size() - 2))))


func _playable_anywhere(c: CardInst) -> bool:
	if c.type() == "event":
		return m.can_play(HUMAN, c, -1)
	for i in 4:
		if m.can_play(HUMAN, c, i):
			return true
	return false


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
		"hero":
			_log("%s: %s!" % [who, m.players[d["player"]].hero["ability_name"]])
		"attack":
			_log("%s colpisce %s: -%d%s" % [db.card(d["card"])["name"], db.card(d["target"])["name"], d["damage"], " BOTTA ATOMICA!" if d["crit"] else ""])
		"attack_hero":
			_log("%s colpisce la Pazienza: -%d%s" % [db.card(d["card"])["name"], d["damage"], " BOTTA ATOMICA!" if d["crit"] else ""])
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
		_show_detail(_card_text(c) + "\nTocca un recinto illuminato per giocarla.", [])
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
		detail_buttons.add_child(b)
	if state != "target":
		var close := Button.new()
		close.text = "Chiudi"
		close.custom_minimum_size = Vector2(0, 36)
		close.pressed.connect(_deselect)
		detail_buttons.add_child(close)
	detail.visible = true


func _show_card_detail(c: CardInst) -> void:
	if c and state in ["play", "target"]:
		_show_detail(_card_text(c), [])


func _card_text(c: CardInst) -> String:
	var d := c.def
	var head := "%s  ·  %s %s  ·  costo %d" % [d["name"], Pal.TYPE_NAME.get(c.type(), ""), Pal.BAND_NAME.get(c.band(), "").split(" ")[0], c.cost()]
	if c.type() == "creature":
		head += "  ·  ATK %d / DEF %d" % [m.atk_of(c), m.def_of(c)] if m.lane_of(c) >= 0 else "  ·  ATK %d / DEF %d" % [c.base_atk(), c.base_def()]
	return "%s\n%s\n«%s»" % [head, Abilities.describe(d, c.level), d.get("flavor", "")]


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
			await _wait(0.25)
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
			await _wait(0.3)
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


func _flash(t: String) -> void:
	banner.text = t
	banner.modulate.a = 1.0
	if speed > 0.0 and is_inside_tree():
		var tw := create_tween()
		tw.tween_interval(0.8 / speed)
		tw.tween_property(banner, "modulate:a", 0.0, 0.4 / speed)


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
