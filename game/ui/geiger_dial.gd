class_name GeigerDial
extends Control
## Il mirino Geiger: la lancetta gira, il giocatore tocca per fermarla.
## Zona verde = colpo, zona rossa subito dopo = Botta Atomica. Fuori o a tempo scaduto = colpo normale.

signal finished(result: String)   ## "botta", "colpo", "normale"

var green := 0.25
var red := 0.08
var green_start := 0.0
var spin_time := 1.4
var max_turns := 3.0
var title := ""
var _t := 0.0
var _running := false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false


## empty_lane: contro un recinto vuoto tutto il quadrante tranne il rosso è verde.
func start(rng: RandomNumberGenerator, label: String, empty_lane: bool, green_size: float, red_size: float, spin_min: float, spin_max: float, turns: float) -> void:
	red = red_size
	green = 1.0 - red if empty_lane else minf(green_size, 1.0 - red)
	green_start = rng.randf_range(0.0, maxf(0.0, 1.0 - green - red))
	spin_time = rng.randf_range(spin_min, spin_max)
	max_turns = turns
	title = label
	_t = 0.0
	_running = true
	visible = true
	queue_redraw()


func _process(delta: float) -> void:
	if not _running:
		return
	_t += delta
	if _t >= spin_time * max_turns:
		_stop()
	queue_redraw()


func _angle_frac() -> float:
	return fmod(_t / spin_time, 1.0)


func _gui_input(e: InputEvent) -> void:
	if not _running:
		return
	if e is InputEventMouseButton and e.pressed:
		_stop()
		accept_event()


func _stop() -> void:
	if not _running:
		return
	_running = false
	var a := _angle_frac()
	var res := "normale"
	if _t < spin_time * max_turns:
		if a >= green_start and a <= green_start + green:
			res = "colpo"
		elif a > green_start + green and a <= green_start + green + red:
			res = "botta"
	visible = false
	finished.emit(res)


## Usato dai test e dal mirino automatico.
func force(result: String) -> void:
	_running = false
	visible = false
	finished.emit(result)


func _draw() -> void:
	# contatore Geiger: cassa di ferro, quadrante di carta, zona verde radio e zona rossa d'allarme
	draw_rect(Rect2(Vector2.ZERO, size), Color(Art.c("notte"), 0.6))
	var c := (size / 2.0).round()
	var rad := roundf(minf(size.x, size.y) * 0.32)
	draw_rect(Rect2(c - Vector2(rad + 16, rad + 16), Vector2(rad + 16, rad + 16) * 2), Art.c("inchiostro"))
	draw_rect(Rect2(c - Vector2(rad + 14, rad + 14), Vector2(rad + 14, rad + 14) * 2), Art.c("ferro_2"))
	draw_rect(Rect2(c - Vector2(rad + 14, rad + 14), Vector2((rad + 14) * 2, 3)), Art.c("ferro_4"))
	for k in 4:   # bulloni negli angoli
		var b := c + Vector2(rad + 8 if k % 2 else -rad - 8, rad + 8 if k / 2 else -rad - 8)
		draw_rect(Rect2(b - Vector2(2, 2), Vector2(4, 4)), Art.c("ferro_4"))
		draw_rect(Rect2(b - Vector2(2, 2), Vector2(4, 1)), Art.c("ferro_5"))
	draw_circle(c, rad + 8, Art.c("legno_1"))
	draw_circle(c, rad + 6, Art.c("legno_9"))
	draw_arc(c, rad, 0, TAU, 64, Art.c("legno_8"), 10.0)
	var a0 := -PI / 2.0
	draw_arc(c, rad, a0 + green_start * TAU, a0 + (green_start + green) * TAU, 48, Art.c("radio_1"), 12.0)
	draw_arc(c, rad, a0 + (green_start + green) * TAU, a0 + (green_start + green + red) * TAU, 24, Art.c("allarme"), 12.0)
	for k in 24:   # tacche
		var a := a0 + k * TAU / 24.0
		draw_line(c + Vector2(cos(a), sin(a)) * (rad - 12), c + Vector2(cos(a), sin(a)) * (rad - 8), Art.c("legno_4"), 2.0)
	var ang := a0 + _angle_frac() * TAU
	draw_line(c, c + Vector2(cos(ang), sin(ang)) * (rad + 4), Art.c("inchiostro"), 4.0)
	draw_line(c, c + Vector2(cos(ang), sin(ang)) * (rad + 4), Art.c("rosso_2"), 2.0)
	draw_circle(c, 6, Art.c("inchiostro"))
	draw_circle(c, 4, Art.c("ferro_4"))
	var f := Pal.font()
	draw_string(f, Vector2(0, c.y - rad - 22), title, HORIZONTAL_ALIGNMENT_CENTER, size.x, 14, Pal.TEXT)
	draw_string(f, Vector2(0, c.y + rad + 34), "Tocca lo schermo per fermare la lancetta", HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, Pal.YELLOW)
