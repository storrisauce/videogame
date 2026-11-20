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
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.55))
	var c := size / 2.0
	var rad := minf(size.x, size.y) * 0.32
	draw_circle(c, rad + 8, Pal.DARK)
	draw_arc(c, rad, 0, TAU, 64, Pal.TEXT.darkened(0.4), 10.0)
	var a0 := -PI / 2.0
	draw_arc(c, rad, a0 + green_start * TAU, a0 + (green_start + green) * TAU, 48, Pal.GREEN, 12.0)
	draw_arc(c, rad, a0 + (green_start + green) * TAU, a0 + (green_start + green + red) * TAU, 24, Pal.RED, 12.0)
	var ang := a0 + _angle_frac() * TAU
	draw_line(c, c + Vector2(cos(ang), sin(ang)) * (rad + 6), Pal.YELLOW, 4.0)
	draw_circle(c, 6, Pal.YELLOW)
	var f := Pal.font()
	draw_string(f, Vector2(0, c.y - rad - 18), title, HORIZONTAL_ALIGNMENT_CENTER, size.x, 14, Pal.TEXT)
	draw_string(f, Vector2(0, c.y + rad + 30), "Tocca lo schermo per fermare la lancetta", HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, Pal.YELLOW)
