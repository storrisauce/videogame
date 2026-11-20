class_name CardView
extends Control
## Carta disegnata senza immagini (grafica provvisoria). Mostra costo, nome, ATK/Vita e stati.

signal tapped(view: CardView)
signal long_pressed(view: CardView)

var card: CardInst
var match_ref: Match
var highlighted := false
var dimmed := false
var compact := false
var _press_time := -1.0


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


func _draw() -> void:
	if card == null:
		return
	var r := Rect2(Vector2.ZERO, size)
	var col := Pal.band_color(card.band())
	var body := col.darkened(0.55) if not dimmed else col.darkened(0.8)
	draw_rect(r, body)
	draw_rect(r.grow(-2), col.darkened(0.2) if not dimmed else col.darkened(0.7), false, 2.0)
	if highlighted:
		draw_rect(r.grow(1), Pal.HILITE, false, 3.0)
	var f := Pal.font()
	var fs := 9 if compact else 10
	# costo
	draw_circle(Vector2(11, 11), 9, Pal.YELLOW)
	draw_string(f, Vector2(2, 15), str(_cost()), HORIZONTAL_ALIGNMENT_CENTER, 18, 11, Pal.DARK)
	# nome
	draw_multiline_string(f, Vector2(4, 32), card.def.get("name", "?"), HORIZONTAL_ALIGNMENT_CENTER, size.x - 8, fs, 3, Pal.TEXT)
	if card.level > 1:
		draw_string(f, Vector2(size.x - 22, 14), "L%d" % card.level, HORIZONTAL_ALIGNMENT_RIGHT, 20, 9, Pal.TEXT)
	match card.type():
		"creature":
			var atk := match_ref.atk_of(card) if match_ref else card.base_atk()
			var hp := match_ref.health_of(card) if match_ref else card.base_def()
			var y := size.y - 6
			draw_rect(Rect2(2, y - 14, 26, 16), Pal.RED.darkened(0.2))
			draw_string(f, Vector2(2, y - 1), str(atk), HORIZONTAL_ALIGNMENT_CENTER, 26, 12, Pal.TEXT)
			draw_rect(Rect2(size.x - 28, y - 14, 26, 16), Pal.GREEN.darkened(0.45))
			draw_string(f, Vector2(size.x - 28, y - 1), str(hp), HORIZONTAL_ALIGNMENT_CENTER, 26, 12, Pal.TEXT)
			var flags := ""
			if card.scossa:
				flags += "✓"
			if card.helpless:
				flags += " inerme"
			if card.protected:
				flags += " protetta"
			if flags != "":
				draw_string(f, Vector2(4, size.y - 24), flags, HORIZONTAL_ALIGNMENT_CENTER, size.x - 8, 8, Pal.YELLOW)
		"structure":
			draw_string(f, Vector2(0, size.y - 6), "STRUTTURA", HORIZONTAL_ALIGNMENT_CENTER, size.x, 8, Pal.TEXT)
		"event":
			draw_string(f, Vector2(0, size.y - 6), "EVENTO", HORIZONTAL_ALIGNMENT_CENTER, size.x, 8, Pal.TEXT)


func _cost() -> int:
	if match_ref and card.owner >= 0 and card.owner < match_ref.players.size():
		return match_ref.cost_of(card.owner, card)
	return card.cost()
