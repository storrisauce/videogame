class_name CardView
extends Control
## Carta in stile C "targa di lamiera" (D-017): lamiera con contorno nero, finestra ad arco con l'illustrazione 3D sul
## colore del terreno, nome su targhetta del colore della banda (mai tagliato), attacco e vita in gettoni grandi, costo
## in gemma; il testo dell'abilità compare quando la carta è ingrandita (scelta o in campo, tenendo premuto).

signal tapped(view: CardView)
signal long_pressed(view: CardView)

const BAND_FRAME := {"porcile": "rosso_4", "pollaio": "arancio_4", "stagno": "acqua_4", "patate": "verde_4", "discarica": "ferro_4", "cratere": "viola_3"}
const BAND_SKY := {"porcile": ["rosa_4", "legno_5"], "pollaio": ["giallo_1", "legno_7"], "stagno": ["acqua_6", "acqua_3"],
	"patate": ["verde_5", "legno_4"], "discarica": ["ferro_5", "ferro_2"], "cratere": ["viola_4", "viola_1"]}

var card: CardInst
var match_ref: Match
var highlighted := false
var dimmed := false
var compact := false
var _press_time := -1.0
var _last_frame := -1


func setup(c: CardInst, m: Match) -> void:
	card = c
	match_ref = m
	tooltip_text = ""
	queue_redraw()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed:
			_press_time = Time.get_ticks_msec() / 1000.0
		elif _press_time >= 0.0:
			var held := Time.get_ticks_msec() / 1000.0 - _press_time
			_press_time = -1.0
			if held > 0.45:
				long_pressed.emit(self)
			else:
				tapped.emit(self)
		accept_event()


func _process(_delta: float) -> void:
	var t := _art()
	if t:
		var f := Art.frame_now(t, _anim_offset())
		if f != _last_frame:
			_last_frame = f
			queue_redraw()


func _art() -> Texture2D:
	return Art.card_tex(card.def.get("id", "")) if card else null


func _anim_offset() -> int:
	return int(card.get_instance_id() % 4) if card else 0


func _draw() -> void:
	if card == null:
		return
	# Stile C "targa di lamiera" (scelto dall'utente). Proporzioni in base all'importanza:
	# illustrazione ~2/3, nome su targhetta del colore della banda, attacco/vita in gettoni grandi, costo in gemma.
	var w := size.x
	var h := size.y
	var full := w >= 118.0              # carta ingrandita: c'è spazio per il testo dell'abilità
	var band := card.band()
	var bcol := Art.c(BAND_FRAME.get(band, "legno_5"))
	var r := Rect2(Vector2.ZERO, size)
	# lamiera: contorno nero, sfumatura chiaro → scuro, riflesso in alto
	draw_style_box(_sb(Art.c("ferro_3"), 11, 3, 4), r)
	draw_style_box(_sb(Art.c("ferro_4"), 9, 0, 0), Rect2(3, 3, w - 6, h * 0.45))
	draw_style_box(_sb(Color(1, 1, 1, 0.28), 4, 0, 0), Rect2(8, 4, w - 16, 3))
	# finestra ad arco con l'illustrazione
	var pad := maxf(4.0, w * 0.06)
	var tok := clampf(w * 0.125, 9.0, 13.0 if full else 18.0)   # raggio dei gettoni di attacco e vita
	var stats_h := tok * 2.0 + 4.0 if card.type() == "creature" else tok * 1.6
	var name_size := int(clampf(w * 0.15, 11.0, 16.0 if full else 21.0))
	var art_h := h * (0.3 if full else 0.56)
	var art := Rect2(pad, pad, w - pad * 2, art_h)
	var sky: Array = BAND_SKY.get(band, ["verde_5", "verde_3"])
	var arch := _sb(Art.c(sky[0]), int(w * 0.28), 3, 0)
	arch.corner_radius_bottom_left = 6
	arch.corner_radius_bottom_right = 6
	draw_style_box(arch, art)
	draw_style_box(_sb(Color(Art.c(sky[1]), 0.55), 6, 0, 0), Rect2(art.position.x + 3, art.position.y + art.size.y * 0.68, art.size.x - 6, art.size.y * 0.32 - 3))
	Art.draw_art(self, String(card.def.get("id", "")), false, art.grow(-3), _anim_offset())
	# targhetta del nome (colore della banda), sovrapposta al fondo della finestra
	var plate_h := name_size * 1.5
	var plate := Rect2(pad - 1, art.end.y - 4, w - pad * 2 + 2, plate_h)
	var label := String(card.def.get("name", "?"))
	if Ui.display().get_string_size(label, 0, -1, name_size).x > plate.size.x - 8:
		plate.size.y = name_size * 2.3
	draw_style_box(_sb(bcol, 7, 3, 2), plate)
	Ui.fit_text(self, plate.grow_individual(-4, -1, -4, -1), label, name_size, Art.c("bianco"), 9)
	# testo dell'abilità (solo carta ingrandita)
	if full:
		var tr := Rect2(pad, plate.end.y + 4, w - pad * 2, h - plate.end.y - 8 - stats_h)
		draw_style_box(_paper(), tr)
		var desc := Abilities.describe(card.def, card.level)
		var flavor := String(card.def.get("flavor", ""))
		# il testo si adatta al riquadro: carattere più piccolo fin dove serve, poi via la battuta
		var tw := tr.size.x - 10
		var chosen := ""
		var fs := 13
		for txt in [desc + ("\n«%s»" % flavor if flavor != "" else ""), desc]:
			fs = 13
			while fs > 8 and Ui.body().get_multiline_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, tw, fs).y > tr.size.y - 6:
				fs -= 1
			if Ui.body().get_multiline_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, tw, fs).y <= tr.size.y - 6:
				chosen = txt
				break
		if chosen == "":
			chosen = desc
		draw_multiline_string(Ui.body(), tr.position + Vector2(5, fs + 3), chosen, HORIZONTAL_ALIGNMENT_LEFT, tw, fs, int((tr.size.y - 4) / (fs * 1.25)), Ui.ink())
	# tipo, piccolo, sopra la finestra (solo strutture ed eventi: le creature si riconoscono dai gettoni)
	if card.type() != "creature":
		var tipo: String = {"structure": "Struttura", "event": "Evento"}.get(card.type(), "")
		Ui.pill(self, Vector2(w / 2.0, h - pad - stats_h / 2.0 + 2), tipo, int(clampf(w * 0.11, 9.0, 13.0)), Ui.ink(), Art.c("legno_9"))
	# attacco e vita: gettoni grandi negli angoli in basso
	if card.type() == "creature":
		var atk := match_ref.atk_of(card) if match_ref and match_ref.lane_of(card) >= 0 else card.base_atk()
		var hp := match_ref.health_of(card) if match_ref and match_ref.lane_of(card) >= 0 else card.base_def()
		var tr2 := tok
		var num := int(clampf(w * 0.17, 12.0, 24.0))
		var ac := Vector2(pad + tr2 + 1, h - pad - tr2)
		draw_circle(ac + Vector2(0, 2), tr2, Ui.ink())
		draw_circle(ac, tr2, Ui.ink())
		draw_circle(ac, tr2 - 3, Art.c("rosso_2"))
		draw_circle(ac + Vector2(-tr2 * 0.3, -tr2 * 0.35), tr2 * 0.25, Color(1, 1, 1, 0.35))
		Ui.text(self, Vector2(ac.x - tr2, ac.y + num * 0.36), str(atk), num, Art.c("bianco"), HORIZONTAL_ALIGNMENT_CENTER, tr2 * 2.0)
		var hc := Vector2(w - pad - tr2 - 1, h - pad - tr2)
		Ui.heart(self, hc + Vector2(0, 1), tr2 * 2.5, Art.c("verde_4"))
		Ui.text(self, Vector2(hc.x - tr2, hc.y + num * 0.32), str(hp), num, Art.c("bianco"), HORIZONTAL_ALIGNMENT_CENTER, tr2 * 2.0)
	# costo: gemma radioattiva nell'angolo in alto
	var gr := clampf(w * 0.15, 11.0, 20.0)
	Ui.gem(self, Vector2(gr + 1, gr + 1), gr, str(_cost()), int(gr * 1.25))
	if card.level > 1:
		Ui.text(self, Vector2(w - 26, 18), "L%d" % card.level, 12, Art.c("giallo_2"))
	if dimmed:
		draw_style_box(_veil(), r)
	if highlighted:
		var hl := StyleBoxFlat.new()
		hl.draw_center = false
		hl.border_color = Art.c("radio_2")
		hl.set_border_width_all(4)
		hl.set_corner_radius_all(14)
		draw_style_box(hl, r.grow(3))


func _sb(fill: Color, radius: int, border: int, shadow: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = Ui.ink()
	sb.set_border_width_all(border)
	sb.set_corner_radius_all(radius)
	sb.anti_aliasing = true
	if shadow > 0:
		sb.shadow_color = Ui.ink()
		sb.shadow_offset = Vector2(0, shadow)
		sb.shadow_size = 1
	return sb


func _paper() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Art.c("legno_9")
	sb.border_color = Ui.ink()
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(6)
	return sb


func _veil() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(Art.c("notte"), 0.55)
	sb.set_corner_radius_all(12)
	return sb


func _cost() -> int:
	if match_ref and card.owner >= 0 and card.owner < match_ref.players.size():
		return match_ref.cost_of(card.owner, card)
	return card.cost()
