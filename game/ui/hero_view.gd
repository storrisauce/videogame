class_name HeroView
extends Control
## Ritratto del sopravvissuto: sprite animato, nome, Pazienza, ricarica dell'abilità.

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
	Art.draw_panel(self, r, Art.c("legno_2"), "legno_5" if player == 0 else "ruggine_2", "legno_1", 2.0)
	# ritratto sul terreno erboso, sprite animato a scala ×2
	var win := Rect2(5, 5, size.x - 10, size.y - 56)
	Art.draw_terrain(self, "erba", win)
	var tex := Art.hero_tex(ps.hero["id"])
	if tex:
		Art.draw_frame(self, tex, Art.frame_now(tex, player * 2), win.grow_individual(0, 0, 0, -2), Art.SCALE, player == 1)
	draw_rect(win, Art.c("legno_1"), false, 1.0)
	if highlighted:
		draw_rect(r.grow(-1), Art.c("radio_2"), false, 3.0)
	var f := Pal.font()
	var hname: String = ps.hero["name"]
	var hs := 9
	while hs > 6 and f.get_string_size(hname, HORIZONTAL_ALIGNMENT_LEFT, -1, hs).x > size.x - 6:
		hs -= 1
	if f.get_string_size(hname, HORIZONTAL_ALIGNMENT_LEFT, -1, hs).x > size.x - 6:
		hname = " ".join(hname.split(" ").slice(0, 3))
	draw_string(f, Vector2(0, win.end.y + 10), hname, HORIZONTAL_ALIGNMENT_CENTER, size.x, hs, Pal.TEXT)
	# Pazienza
	var frac := clampf(float(ps.hp) / float(ps.max_hp), 0.0, 1.0)
	draw_string(f, Vector2(0, size.y - 28), "Pazienza %d/%d" % [ps.hp, ps.max_hp], HORIZONTAL_ALIGNMENT_CENTER, size.x, 10, Pal.TEXT)
	var bar := Rect2(6, size.y - 24, size.x - 12, 7)
	draw_rect(bar.grow(1), Art.c("legno_1"))
	draw_rect(bar, Art.c("rosso_1"))
	draw_rect(Rect2(bar.position, Vector2(roundf(bar.size.x * frac), bar.size.y)), Art.c("rosso_3"))
	draw_rect(Rect2(bar.position, Vector2(roundf(bar.size.x * frac), 2)), Art.c("rosso_4"))
	var cd := "Abilità pronta" if ps.cooldown <= 0 else "Ricarica: %d" % ps.cooldown
	draw_string(f, Vector2(0, size.y - 8), cd, HORIZONTAL_ALIGNMENT_CENTER, size.x, 8, Pal.YELLOW if ps.cooldown <= 0 else Pal.TEXT)


var _last_frame := -1


func _process(_delta: float) -> void:
	if m == null:
		return
	var tex := Art.hero_tex(m.players[player].hero["id"])
	if tex:
		var f := Art.frame_now(tex, player * 2)
		if f != _last_frame:
			_last_frame = f
			queue_redraw()
