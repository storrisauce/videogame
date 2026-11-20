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
	# quadrante Geiger cartoon: velo scuro, ghiera nera spessa, ghiera di metallo, quadrante color carta,
	# zona verde (colpo) e rossa (Botta Atomica), lancetta con contorno; sopra il nome, sotto "Tocca!".
	draw_rect(Rect2(Vector2.ZERO, size), Color(Art.c("inchiostro"), 0.55))
	var c := (size / 2.0 + Vector2(0, 6)).round()
	var rad := roundf(minf(size.x, size.y) * 0.3)
	draw_circle(c + Vector2(0, 6), rad + 22, Ui.ink())
	draw_circle(c, rad + 22, Ui.ink())
	draw_circle(c, rad + 18, Art.c("arancio_4"))
	draw_arc(c, rad + 15, PI * 1.1, PI * 1.6, 24, Color(1, 1, 1, 0.45), 4.0)
	draw_circle(c, rad + 8, Ui.ink())
	draw_circle(c, rad + 5, Art.c("legno_9"))
	var a0 := -PI / 2.0
	draw_arc(c, rad - 6, a0 + green_start * TAU, a0 + (green_start + green) * TAU, 48, Ui.ink(), 22.0)
	draw_arc(c, rad - 6, a0 + green_start * TAU, a0 + (green_start + green) * TAU, 48, Art.c("radio_1"), 16.0)
	draw_arc(c, rad - 6, a0 + (green_start + green) * TAU, a0 + (green_start + green + red) * TAU, 24, Ui.ink(), 22.0)
	draw_arc(c, rad - 6, a0 + (green_start + green) * TAU, a0 + (green_start + green + red) * TAU, 24, Art.c("allarme"), 16.0)
	for k in 12:   # tacche
		var a := a0 + k * TAU / 12.0
		draw_line(c + Vector2(cos(a), sin(a)) * (rad - 26), c + Vector2(cos(a), sin(a)) * (rad - 18), Art.c("legno_4"), 3.0)
	BunkerSet.trefoil_2d(self, c + Vector2(0, rad * 0.38), rad * 0.16)
	var ang := a0 + _angle_frac() * TAU
	var tip := c + Vector2(cos(ang), sin(ang)) * (rad - 2)
	draw_line(c, tip, Ui.ink(), 9.0)
	draw_line(c, tip, Art.c("rosso_2"), 5.0)
	draw_circle(c, 11, Ui.ink())
	draw_circle(c, 8, Art.c("ferro_4"))
	Ui.pill(self, Vector2(size.x / 2.0, c.y - rad - 40), title, Ui.MID, Art.c("ferro_2"), Art.c("bianco"))
	Ui.text(self, Vector2(0, c.y + rad + 58), "Tocca!", Ui.BIG, Art.c("giallo_2"), HORIZONTAL_ALIGNMENT_CENTER, size.x)
