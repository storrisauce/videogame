class_name CardView
extends Control
## Carta cartoon (strada A): cornice del colore del terreno con contorno nero spesso, gemma del costo in alto a
## sinistra, tipo in alto a destra, illustrazione grande, nome mai tagliato, testo dell'abilità (quando la carta è
## abbastanza grande, cioè ingrandita), attacco e vita con le icone. Gerarchia: costo > illustrazione > nome > numeri.

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
	var r := Rect2(Vector2.ZERO, size)
	var band := card.band()
	var full := size.x >= 130.0          # carta ingrandita: mostra anche il testo dell'abilità
	var pad := 6.0
	# cornice del terreno
	Ui.plate(self, r, Art.c(BAND_FRAME.get(band, "legno_5")), 12, false, 5)
	# illustrazione
	var stats_h := 26.0 if card.type() == "creature" else 0.0
	var name_h := 34.0 if full else 30.0
	var text_h := 58.0 if full else 0.0
	var art := Rect2(pad, 20, size.x - pad * 2, size.y - 20 - pad - name_h - text_h - stats_h)
	var sky: Array = BAND_SKY.get(band, ["verde_5", "verde_3"])
	draw_rect(art, Art.c(sky[0]))
	draw_rect(Rect2(art.position.x, art.position.y + art.size.y * 0.62, art.size.x, art.size.y * 0.38), Art.c(sky[1]))
	var tex := _art()
	if tex:
		var sc := clampi(int(minf(art.size.x / 30.0, art.size.y / 26.0)), 1, 4)
		Art.draw_frame(self, tex, Art.frame_now(tex, _anim_offset()), art.grow_individual(0, 0, 0, -2), sc)
	draw_rect(art, Ui.ink(), false, 3.0)
	# tipo (in alto a destra)
	var tipo: String = {"creature": "Creatura", "structure": "Struttura", "event": "Evento"}.get(card.type(), "")
	Ui.pill(self, Vector2(size.x - 6 - Ui.display().get_string_size(tipo, 0, -1, 10).x / 2.0 - 7, 11), tipo, 10, Ui.ink(), Art.c("legno_9"))
	# nome: mai tagliato
	var name_rect := Rect2(pad, art.end.y + 1, size.x - pad * 2, name_h)
	Ui.fit_text(self, name_rect, String(card.def.get("name", "?")), Ui.SMALL + (4 if full else 1), Art.c("bianco"))
	# testo dell'abilità (solo ingrandita)
	if full:
		var tr := Rect2(pad, name_rect.end.y, size.x - pad * 2, text_h - 4)
		draw_style_box(_paper(), tr)
		var desc := Abilities.describe(card.def, card.level)
		var flavor := String(card.def.get("flavor", ""))
		var txt := desc + ("\n«%s»" % flavor if flavor != "" else "")
		draw_multiline_string(Ui.body(), tr.position + Vector2(5, 13), txt, HORIZONTAL_ALIGNMENT_LEFT, tr.size.x - 10, Ui.BODY - 1, 4, Ui.ink())
	# attacco e vita
	if card.type() == "creature":
		var atk := match_ref.atk_of(card) if match_ref and match_ref.lane_of(card) >= 0 else card.base_atk()
		var hp := match_ref.health_of(card) if match_ref and match_ref.lane_of(card) >= 0 else card.base_def()
		var y := size.y - pad - stats_h / 2.0
		Ui.sword(self, Vector2(pad + 12, y), 22)
		Ui.text(self, Vector2(pad + 22, y + 8), str(atk), Ui.MID, Art.c("bianco"))
		Ui.heart(self, Vector2(size.x - pad - 12, y), 22, Art.c("verde_4"))
		Ui.text(self, Vector2(size.x - pad - 60, y + 8), str(hp), Ui.MID, Art.c("bianco"), HORIZONTAL_ALIGNMENT_RIGHT, 36)
	# costo (sopra a tutto, sporge dall'angolo)
	Ui.gem(self, Vector2(13, 13), 14, str(_cost()), Ui.MID)
	if card.level > 1:
		Ui.text(self, Vector2(size.x - 28, 34), "L%d" % card.level, Ui.SMALL, Art.c("giallo_2"))
	if dimmed:
		draw_style_box(_veil(), r)
	if highlighted:
		var hl := StyleBoxFlat.new()
		hl.draw_center = false
		hl.border_color = Art.c("radio_2")
		hl.set_border_width_all(4)
		hl.set_corner_radius_all(14)
		draw_style_box(hl, r.grow(3))


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
