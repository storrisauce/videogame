class_name LaneView
extends Control
## Il livello 2D di un recinto, sopra il tavolo 3D (Board3D): riceve i tocchi dentro il trapezio del recinto,
## lo illumina quando ci si può giocare o mirare, e mostra ATK e Vita sopra la testa della creatura.
## Tocco = scegli il recinto; tocco lungo = dettagli della carta.

signal tapped(player: int, lane: int)
signal long_pressed_card(card: CardInst)

var player := 0
var lane := 0
var zone := ""
var highlighted := false
var target_mark := false
var creature: CardInst
var structure: CardInst
var m: Match
var _press_time := -1.0
var poly := PackedVector2Array()   ## i 4 angoli del recinto in prospettiva, in coordinate locali
var head := Vector2.ZERO           ## punto sopra la testa della creatura (coordinate locali), dal tavolo 3D


func _init(p: int, i: int) -> void:
	player = p
	lane = i
	mouse_filter = Control.MOUSE_FILTER_STOP


func refresh(match_ref: Match) -> void:
	m = match_ref
	var l := m.players[player].lanes[lane]
	zone = l.zone
	creature = l.creature
	structure = l.structure
	queue_redraw()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed:
			_press_time = Time.get_ticks_msec() / 1000.0
		elif _press_time >= 0.0:
			var held := Time.get_ticks_msec() / 1000.0 - _press_time
			_press_time = -1.0
			var c := creature if creature else structure
			if held > 0.45 and c:
				long_pressed_card.emit(c)
			else:
				tapped.emit(player, lane)
		accept_event()


func _has_point(pt: Vector2) -> bool:
	# il tocco vale dentro il trapezio del recinto, non nel rettangolo che lo contiene
	return Geometry2D.is_point_in_polygon(pt, poly) if poly.size() == 4 else Rect2(Vector2.ZERO, size).has_point(pt)


func _draw() -> void:
	var outline := poly if poly.size() == 4 else PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), size, Vector2(0, size.y)])
	var closed := outline.duplicate()
	closed.append(outline[0])
	if highlighted:
		draw_colored_polygon(outline, Color(Art.c("radio_2"), 0.22))
		draw_polyline(closed, Art.c("radio_2"), 3.0)
	if target_mark:
		draw_colored_polygon(outline, Color(Art.c("allarme"), 0.22))
		draw_polyline(closed, Art.c("allarme"), 3.0)
	if creature and m:
		_draw_stats(head)


## ATK in un tondo rosso e barra della Vita con i numeri, sopra la testa della creatura.
func _draw_stats(at: Vector2) -> void:
	var f := Pal.font()
	var atk := m.atk_of(creature)
	var hp := m.health_of(creature)
	var mx := maxi(m.def_of(creature), 1)
	var w := 46.0
	var o := (at - Vector2(w / 2.0 + 6.0, 10.0)).round()
	var bar := Rect2(o.x + 14, o.y + 6, w, 7)
	draw_rect(bar.grow(1), Art.c("legno_1"))
	draw_rect(bar, Art.c("verde_1"))
	var frac := clampf(float(hp) / float(mx), 0.0, 1.0)
	draw_rect(Rect2(bar.position, Vector2(roundf(bar.size.x * frac), bar.size.y)), Art.c("verde_4"))
	draw_rect(Rect2(bar.position, Vector2(roundf(bar.size.x * frac), 2)), Art.c("verde_5"))
	draw_string_outline(f, Vector2(bar.position.x, bar.position.y - 1), "%d/%d" % [hp, mx], HORIZONTAL_ALIGNMENT_CENTER, bar.size.x, 10, 3, Art.c("inchiostro"))
	draw_string(f, Vector2(bar.position.x, bar.position.y - 1), "%d/%d" % [hp, mx], HORIZONTAL_ALIGNMENT_CENTER, bar.size.x, 10, Art.c("bianco"))
	var cc := Vector2(o.x + 8, o.y + 9)
	draw_circle(cc, 9, Art.c("rosso_1"))
	draw_circle(cc, 8, Art.c("rosso_2"))
	draw_circle(cc + Vector2(-2, -3), 2.5, Art.c("rosso_4"))
	draw_string_outline(f, Vector2(cc.x - 9, cc.y + 4), str(atk), HORIZONTAL_ALIGNMENT_CENTER, 18, 12, 3, Art.c("rosso_1"))
	draw_string(f, Vector2(cc.x - 9, cc.y + 4), str(atk), HORIZONTAL_ALIGNMENT_CENTER, 18, 12, Art.c("bianco"))
	var flags := []
	if creature.scossa:
		flags.append("scossa")
	if creature.helpless:
		flags.append("inerme")
	if creature.protected:
		flags.append("protetta")
	if not flags.is_empty():
		draw_string_outline(f, Vector2(o.x, bar.end.y + 11), ", ".join(flags), HORIZONTAL_ALIGNMENT_CENTER, w + 20, 9, 3, Art.c("inchiostro"))
		draw_string(f, Vector2(o.x, bar.end.y + 11), ", ".join(flags), HORIZONTAL_ALIGNMENT_CENTER, w + 20, 9, Art.c("giallo_2"))
