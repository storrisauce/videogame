class_name LaneView
extends Control
## Un recinto sul tavolo visto di tre quarti: terreno della banda, creatura in piedi con ATK e Vita
## sopra la testa, struttura dietro di lei. Tocco = scegli il recinto; tocco lungo = dettagli della carta.

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
var _last_frame := -1
var poly := PackedVector2Array()   ## i 4 angoli del recinto in prospettiva, in coordinate locali
var sprite_scale := Art.SCALE      ## ×3 nella fila vicina, ×2 in quella lontana


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


func _process(_d: float) -> void:
	var f := int(Time.get_ticks_msec() / 1000.0 * Art.FPS)
	if f != _last_frame:
		_last_frame = f
		queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var outline := poly if poly.size() == 4 else PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), size, Vector2(0, size.y)])
	var flip := player == 1
	var sc := sprite_scale
	# struttura: dietro (lontano dal centro del tavolo), un po' di lato
	if structure:
		var t := Art.card_tex(structure.def.get("id", ""))
		var sa := Rect2(size.x * 0.52, 2, size.x * 0.48 - 2, size.y * 0.62) if player == 1 \
			else Rect2(size.x * 0.52, size.y * 0.30, size.x * 0.48 - 2, size.y * 0.70 - 4)
		if t:
			Art.draw_frame(self, t, Art.frame_now(t, lane), sa, maxi(sc - 1, Art.SCALE) if player == 0 else sc, flip)
	# creatura: davanti, verso il centro del tavolo
	if creature:
		var t := Art.card_tex(creature.def.get("id", ""))
		var ca := Rect2(4, 20, size.x * 0.62, size.y - 24)
		var dim := Color.WHITE if not creature.helpless else Color(0.7, 0.7, 0.8, 0.85)
		if t:
			Art.draw_frame(self, t, Art.frame_now(t, lane + player * 2), ca, sc, flip, dim)
		_draw_stats(ca)
	var closed := outline.duplicate()
	closed.append(outline[0])
	if highlighted:
		draw_colored_polygon(outline, Color(Art.c("radio_2"), 0.18))
		draw_polyline(closed, Art.c("radio_2"), 3.0)
	if target_mark:
		draw_colored_polygon(outline, Color(Art.c("allarme"), 0.18))
		draw_polyline(closed, Art.c("allarme"), 3.0)
	# cartellino con il nome della zona
	var short: String = Pal.BAND_NAME.get(zone, zone).split(" ")[0]
	var f := Pal.font()
	var tw := f.get_string_size(short, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x + 6
	var tag := Rect2(size.x - tw - 5, size.y - 13, tw, 10)
	tag.position = tag.position.round()
	draw_rect(tag.grow(1), Art.c("legno_1"))
	draw_rect(tag, Art.c("legno_9"))
	draw_string(f, Vector2(tag.position.x, tag.end.y - 2), short, HORIZONTAL_ALIGNMENT_CENTER, tag.size.x, 8, Art.c("legno_1"))


## ATK in un tondo rosso e barra della Vita con i numeri, sopra la testa della creatura.
func _draw_stats(ca: Rect2) -> void:
	var f := Pal.font()
	var atk := m.atk_of(creature)
	var hp := m.health_of(creature)
	var mx := maxi(m.def_of(creature), 1)
	var y := 4.0 if player == 0 else 4.0
	var cx := ca.position.x + 10.0
	draw_circle(Vector2(cx, y + 7), 8, Art.c("rosso_1"))
	draw_circle(Vector2(cx, y + 7), 7, Art.c("rosso_2"))
	draw_string(f, Vector2(cx - 8, y + 11), str(atk), HORIZONTAL_ALIGNMENT_CENTER, 16, 11, Art.c("bianco"))
	var bar := Rect2(cx + 10, y + 7, minf(56.0, ca.size.x - 24.0), 6)
	draw_rect(bar.grow(1), Art.c("legno_1"))
	draw_rect(bar, Art.c("verde_1"))
	var frac := clampf(float(hp) / float(mx), 0.0, 1.0)
	draw_rect(Rect2(bar.position, Vector2(roundf(bar.size.x * frac), bar.size.y)), Art.c("verde_4"))
	draw_rect(Rect2(bar.position, Vector2(roundf(bar.size.x * frac), 2)), Art.c("verde_5"))
	draw_string(f, Vector2(bar.position.x, bar.position.y - 1), "%d/%d" % [hp, mx], HORIZONTAL_ALIGNMENT_CENTER, bar.size.x, 9, Art.c("bianco"))
	var flags := ""
	if creature.scossa:
		flags += "scossa "
	if creature.helpless:
		flags += "inerme "
	if creature.protected:
		flags += "protetta"
	if flags != "":
		draw_string(f, Vector2(ca.position.x, ca.end.y - 2), flags.strip_edges(), HORIZONTAL_ALIGNMENT_CENTER, ca.size.x, 8, Art.c("giallo_2"))
