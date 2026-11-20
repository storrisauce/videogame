class_name HeroView
extends Control
## Ritratto provvisorio del sopravvissuto: nome, Pazienza, ricarica dell'abilità.

signal tapped(player: int)

var player := 0
var m: Match
var highlighted := false


func _init(p: int) -> void:
	player = p
	mouse_filter = Control.MOUSE_FILTER_STOP


func refresh(match_ref: Match) -> void:
	m = match_ref
	queue_redraw()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and not e.pressed:
		tapped.emit(player)
		accept_event()


func _draw() -> void:
	if m == null:
		return
	var ps := m.players[player]
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, Pal.DARK)
	draw_rect(r.grow(-1), Pal.YELLOW.darkened(0.3) if player == 0 else Pal.RED.darkened(0.3), false, 2.0)
	if highlighted:
		draw_rect(r.grow(-3), Pal.HILITE, false, 3.0)
	var f := Pal.font()
	draw_multiline_string(f, Vector2(4, 14), ps.hero["name"], HORIZONTAL_ALIGNMENT_CENTER, size.x - 8, 9, 3, Pal.TEXT)
	# Pazienza
	var frac := clampf(float(ps.hp) / float(ps.max_hp), 0.0, 1.0)
	var bar := Rect2(6, size.y - 34, size.x - 12, 12)
	draw_rect(bar, Pal.RED.darkened(0.6))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * frac, bar.size.y)), Pal.GREEN.darkened(0.2))
	draw_string(f, Vector2(0, size.y - 24), "Pazienza %d" % ps.hp, HORIZONTAL_ALIGNMENT_CENTER, size.x, 9, Pal.TEXT)
	var cd := "Abilità pronta" if ps.cooldown <= 0 else "Ricarica: %d" % ps.cooldown
	draw_string(f, Vector2(0, size.y - 8), cd, HORIZONTAL_ALIGNMENT_CENTER, size.x, 8, Pal.YELLOW if ps.cooldown <= 0 else Pal.TEXT)
