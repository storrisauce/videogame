class_name LaneView
extends Control
## Un recinto: sfondo del colore della zona, creatura e struttura affiancate.

signal tapped(player: int, lane: int)
signal long_pressed_card(card: CardInst)

var player := 0
var lane := 0
var zone := ""
var highlighted := false
var target_mark := false
var creature_view := CardView.new()
var structure_view := CardView.new()


func _init(p: int, i: int) -> void:
	player = p
	lane = i
	mouse_filter = Control.MOUSE_FILTER_STOP
	for v: CardView in [creature_view, structure_view]:
		v.visible = false
		v.compact = true
		v.tapped.connect(func(_v): tapped.emit(player, lane))
		v.long_pressed.connect(func(cv: CardView): long_pressed_card.emit(cv.card))
		add_child(v)


func refresh(m: Match) -> void:
	var l := m.players[player].lanes[lane]
	zone = l.zone
	_show(creature_view, l.creature, m)
	_show(structure_view, l.structure, m)
	_layout()
	queue_redraw()


func _show(v: CardView, c: CardInst, m: Match) -> void:
	v.visible = c != null
	if c:
		v.setup(c, m)
		v.queue_redraw()


func _layout() -> void:
	var cw := minf(80.0, size.x * 0.55)
	var ch := minf(108.0, size.y - 6.0)
	var sw := minf(46.0, size.x - cw - 10.0)
	var sh := sw * 1.35
	# la creatura sta verso il centro del tavolo, la struttura dietro (verso il bordo)
	creature_view.size = Vector2(cw, ch)
	creature_view.position = Vector2(4, (size.y - ch) / 2.0)
	structure_view.size = Vector2(sw, sh)
	var sy := 4.0 if player == 1 else size.y - sh - 4.0
	structure_view.position = Vector2(cw + 8, sy)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and not e.pressed:
		tapped.emit(player, lane)
		accept_event()


func _draw() -> void:
	var col := Pal.band_color(zone)
	draw_rect(Rect2(Vector2.ZERO, size), col.darkened(0.72))
	draw_rect(Rect2(Vector2.ZERO, size).grow(-1), col.darkened(0.35), false, 1.5)
	if highlighted:
		draw_rect(Rect2(Vector2.ZERO, size).grow(-2), Pal.HILITE, false, 3.0)
	if target_mark:
		draw_rect(Rect2(Vector2.ZERO, size).grow(-2), Pal.RED, false, 3.0)
	var short: String = Pal.BAND_NAME.get(zone, zone).split(" ")[0]
	draw_string(Pal.font(), Vector2(0, size.y - 3 if player == 1 else 10), short, HORIZONTAL_ALIGNMENT_RIGHT, size.x - 4, 8, col.lightened(0.2))
