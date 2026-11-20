class_name CardView
extends Control
## Carta in pixel art: cornice di legno, terreno della banda, sprite animato, costo, nome, ATK/Vita e stati.

signal tapped(view: CardView)
signal long_pressed(view: CardView)

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
	var r := Rect2(Vector2.ZERO, size).abs()
	var small := size.x < 60.0
	# cornice di legno
	Art.draw_panel(self, r, Art.c("legno_3"), "legno_5", "legno_1", 1.0)
	# finestra con il terreno della banda e lo sprite
	var stats_h := 0.0 if card.type() != "creature" else 15.0
	var name_h := 0.0 if small else 13.0
	var win := Rect2(3, 3, size.x - 6, size.y - 6 - stats_h - name_h).abs()
	Art.draw_terrain(self, card.band(), win)
	var tex := _art()
	if tex:
		Art.draw_frame(self, tex, Art.frame_now(tex, _anim_offset()), win.grow_individual(0, 0, 0, -2))
	draw_rect(win, Art.c("legno_1"), false, 1.0)
	var f := Pal.font()
	# nome su targhetta di carta
	if not small:
		var plate := Rect2(3, win.end.y + 1, size.x - 6, name_h - 2)
		draw_rect(plate, Art.c("legno_9"))
		draw_rect(Rect2(plate.position.x, plate.end.y - 1, plate.size.x, 1), Art.c("legno_7"))
		var label := card.def.get("name", "?") as String
		var fs := 9
		while fs > 6 and f.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > plate.size.x - 2:
			fs -= 1
		draw_string(f, Vector2(plate.position.x, plate.position.y + 9), label, HORIZONTAL_ALIGNMENT_CENTER, plate.size.x, fs, Art.c("legno_1"))
	# costo in Caos: gemma radioattiva in alto a sinistra
	var cc := Vector2(10, 10)
	draw_circle(cc, 8, Art.c("verde_1"))
	draw_circle(cc, 7, Art.c("radio_1"))
	draw_circle(cc + Vector2(-2, -2), 2, Art.c("radio_2"))
	draw_string(f, Vector2(2, 14), str(_cost()), HORIZONTAL_ALIGNMENT_CENTER, 16, 11, Art.c("verde_0"))
	if card.level > 1:
		draw_string(f, Vector2(size.x - 22, 12), "L%d" % card.level, HORIZONTAL_ALIGNMENT_RIGHT, 18, 9, Art.c("bianco"))
	match card.type():
		"creature":
			var atk := match_ref.atk_of(card) if match_ref else card.base_atk()
			var hp := match_ref.health_of(card) if match_ref else card.base_def()
			var y := size.y - 3 - stats_h
			_badge(Rect2(3, y, 24, stats_h), str(atk), "rosso_1", "rosso_2", f)
			_badge(Rect2(size.x - 27, y, 24, stats_h), str(hp), "verde_1", "verde_3", f)
			var flags := ""
			if card.scossa:
				flags += "✓"
			if card.helpless:
				flags += " inerme"
			if card.protected:
				flags += " protetta"
			if flags != "":
				draw_string(f, Vector2(0, y + 11), flags, HORIZONTAL_ALIGNMENT_CENTER, size.x, 8, Art.c("giallo_2"))
		"structure", "event":
			if small:
				draw_string(f, Vector2(0, size.y - 5), "STRUTTURA" if card.type() == "structure" else "EVENTO", HORIZONTAL_ALIGNMENT_CENTER, size.x, 7, Art.c("legno_9"))
	if dimmed:
		draw_rect(r, Color(Art.c("notte"), 0.55))
	if highlighted:
		draw_rect(r.grow(-1), Art.c("radio_2"), false, 2.0)


func _badge(b: Rect2, text: String, dark: String, base: String, f: Font) -> void:
	draw_rect(b, Art.c(dark))
	draw_rect(b.grow(-1), Art.c(base))
	draw_rect(Rect2(b.position + Vector2(1, 1), Vector2(b.size.x - 2, 1)), Color(1, 1, 1, 0.35))
	draw_string(f, Vector2(b.position.x, b.end.y - 3), text, HORIZONTAL_ALIGNMENT_CENTER, b.size.x, 11, Art.c("bianco"))


func _cost() -> int:
	if match_ref and card.owner >= 0 and card.owner < match_ref.players.size():
		return match_ref.cost_of(card.owner, card)
	return card.cost()
