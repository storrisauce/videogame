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


## Attacco e vita sopra la testa della creatura: due gettoni come sulle carte (tondo rosso, cuore verde).
## Il cuore diventa arancione quando la creatura è ferita. Gli stati (scossa, inerme, protetta) sono piccole icone.
func _draw_stats(at: Vector2) -> void:
	var atk := m.atk_of(creature)
	var hp := m.health_of(creature)
	var mx := maxi(m.def_of(creature), 1)
	var r := 13.0
	var ac := (at + Vector2(-r - 2, 0)).round()
	draw_circle(ac + Vector2(0, 2), r, Ui.ink())
	draw_circle(ac, r, Ui.ink())
	draw_circle(ac, r - 3, Art.c("rosso_2"))
	draw_circle(ac + Vector2(-4, -4), 3, Color(1, 1, 1, 0.35))
	Ui.text(self, Vector2(ac.x - r, ac.y + 6), str(atk), Ui.SMALL + 3, Art.c("bianco"), HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, 3.0)
	var hc := (at + Vector2(r + 2, 0)).round()
	Ui.heart(self, hc + Vector2(0, 1), r * 2.5, Art.c("verde_4") if hp >= mx else Art.c("arancio_3"))
	Ui.text(self, Vector2(hc.x - r, hc.y + 6), str(hp), Ui.SMALL + 3, Art.c("bianco"), HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, 3.0)
	var icons := []
	if creature.scossa:
		icons.append(["radio_1", "✓"])
	if creature.helpless:
		icons.append(["ferro_2", "z"])
	if creature.protected:
		icons.append(["acqua_4", "+"])
	for k in icons.size():
		var c := at + Vector2(-8 + k * 16, -r - 8)
		draw_circle(c, 7, Ui.ink())
		draw_circle(c, 5, Art.c(icons[k][0]))
