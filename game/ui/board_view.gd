class_name BoardView
extends Control
## Il tavolo in prospettiva leggera ("alla 16 bit"): un altopiano di fattoria più stretto in fondo, con siepe,
## sentiero tra i due schieramenti, scogliera davanti e steccati tra i recinti. Il terreno di ogni recinto è
## disegnato in prospettiva; gli sprite restano pixel art a scala intera (×3 vicino, ×2 lontano: vedi LaneView).
## Le misure arrivano da MatchScreen._layout().

const STRIPS := 10          ## fasce per recinto: tengono dritta la trama del terreno
## Prospettiva leggera spenta: per ora il tavolo è piatto, visto dall'alto (decisione dell'utente: prima tutto in 2D).
## Con true il fondo si stringe e la trama rimpicciolisce; in MatchScreen vanno allora ristretti far_x e le scale.
const PERSPECTIVE := false

var y_far := 0.0            ## bordo lontano (fila dell'avversario)
var y_mid0 := 0.0           ## inizio del sentiero
var y_mid1 := 0.0           ## fine del sentiero
var y_near := 0.0           ## bordo vicino (la tua fila)
var near_x := Vector2.ZERO  ## x sinistra e destra del bordo vicino
var far_x := Vector2.ZERO   ## x sinistra e destra del bordo lontano
var zones := [[], []]       ## bande delle zone: [giocatore][recinto]
var tray := Rect2()
var panels: Array[Rect2] = []


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## Scala dei pixel del mondo a una certa altezza: 2 in fondo, 3 davanti.
func px_scale(y: float) -> float:
	if not PERSPECTIVE:
		return float(Art.SCALE)
	return lerpf(2.0, 3.0, clampf((y - y_far) / maxf(y_near - y_far, 1.0), 0.0, 1.0))


## Punto del tavolo: u = 0..1 da sinistra a destra, y in coordinate dello schermo.
func at(u: float, y: float) -> Vector2:
	var t := clampf((y - y_far) / maxf(y_near - y_far, 1.0), 0.0, 1.0)
	var l := lerpf(far_x.x, near_x.x, t)
	var r := lerpf(far_x.y, near_x.y, t)
	return Vector2(lerpf(l, r, u), y)


## I 4 angoli di un recinto (giocatore 0 = fila vicina).
func cell_poly(p: int, i: int) -> PackedVector2Array:
	var ya := y_mid1 if p == 0 else y_far
	var yb := y_near if p == 0 else y_mid0
	var u0 := i / 4.0
	var u1 := (i + 1) / 4.0
	return PackedVector2Array([at(u0, ya), at(u1, ya), at(u1, yb), at(u0, yb)])


func _draw() -> void:
	Art.draw_terrain(self, "erba", Rect2(Vector2.ZERO, size))
	if y_near <= y_far:
		return
	var nl := at(0, y_near)
	var nr := at(1, y_near)
	var fl := at(0, y_far)
	var fr := at(1, y_far)
	# ombra dell'altopiano sull'erba
	draw_colored_polygon(PackedVector2Array([fl + Vector2(8, 6), fr + Vector2(10, 6), nr + Vector2(12, 20), nl + Vector2(6, 20)]), Color(Art.c("notte"), 0.3))
	# siepe in fondo
	draw_rect(Rect2(fl.x - 6, y_far - 9, fr.x - fl.x + 12, 10), Art.c("verde_1"))
	var x := fl.x - 6
	var k := 0
	while x < fr.x + 4:
		var rr := 6.0 + float(k % 3)
		draw_circle(Vector2(x + 6, y_far - 6), rr + 1, Art.c("verde_0"))
		draw_circle(Vector2(x + 6, y_far - 6), rr, Art.c("verde_2"))
		draw_circle(Vector2(x + 4, y_far - 8), rr * 0.5, Art.c("verde_3"))
		x += 12.0
		k += 1
	# terreni dei recinti e sentiero, in prospettiva
	for p in 2:
		for i in 4:
			var band: String = zones[p][i] if zones[p].size() > i else "erba"
			_ground(band, i / 4.0, (i + 1) / 4.0, y_mid1 if p == 0 else y_far, y_near if p == 0 else y_mid0)
	_ground("pollaio", 0.0, 1.0, y_mid0, y_mid1)
	# bordi del sentiero
	for yy in [y_mid0, y_mid1 - 2]:
		draw_colored_polygon(PackedVector2Array([at(0, yy), at(1, yy), at(1, yy + 2), at(0, yy + 2)]), Color(Art.c("legno_4"), 0.9))
	# steccati tra i recinti
	for i in range(1, 4):
		var u := i / 4.0
		for seg in [[y_far, y_mid0], [y_mid1, y_near]]:
			_fence(u, seg[0], seg[1])
	# fianchi e scogliera davanti: lo spessore dell'altopiano
	var depth := 14.0
	draw_colored_polygon(PackedVector2Array([fl, nl, nl + Vector2(0, depth), fl + Vector2(0, 4)]), Art.c("legno_3"))
	draw_colored_polygon(PackedVector2Array([fr, nr, nr + Vector2(0, depth), fr + Vector2(0, 4)]), Art.c("legno_3"))
	var cliff := Rect2(nl.x, y_near, nr.x - nl.x, depth)
	draw_rect(cliff, Art.c("legno_4"))
	draw_rect(Rect2(cliff.position, Vector2(cliff.size.x, 3)), Art.c("verde_3"))
	draw_rect(Rect2(cliff.position.x, cliff.position.y + 3, cliff.size.x, 1), Art.c("verde_1"))
	var sx := cliff.position.x + 6
	var row := 0
	while sx < cliff.end.x - 12:
		draw_rect(Rect2(sx, cliff.position.y + 7 + (row % 2) * 3, 12, 2), Art.c("legno_3"))
		sx += 21
		row += 1
	draw_polyline(PackedVector2Array([fl, nl, nl + Vector2(0, depth), nr + Vector2(0, depth), nr, fr, fl]), Art.c("legno_1"), 2.0)
	# consolle laterali e vassoio della mano
	for pr in panels:
		_console(pr)
	if tray.size.x > 0:
		_console(tray)
		draw_rect(tray.grow(-6), Art.c("legno_2"))
		draw_rect(Rect2(tray.position + Vector2(6, 6), Vector2(tray.size.x - 12, 2)), Color(Art.c("inchiostro"), 0.45))


## Terreno ripetuto dentro una fascia del tavolo, con la trama che rimpicciolisce in fondo.
func _ground(band: String, u0: float, u1: float, ya: float, yb: float) -> void:
	var tex := Art.terrain_tex(band)
	if tex == null:
		draw_colored_polygon(PackedVector2Array([at(u0, ya), at(u1, ya), at(u1, yb), at(u0, yb)]), Art.c("verde_4"))
		return
	var tw := float(tex.get_width())
	var th := float(tex.get_height())
	# coordinate del mondo: u in pixel misurati sul bordo vicino (scala 3), v accumulato fascia per fascia
	var world_w := (near_x.y - near_x.x) / px_scale(y_near)
	var v := (ya - y_far) / 2.5
	for s in STRIPS:
		var y0 := lerpf(ya, yb, float(s) / STRIPS)
		var y1 := lerpf(ya, yb, float(s + 1) / STRIPS)
		var dv := (y1 - y0) / px_scale((y0 + y1) / 2.0)
		var pts := PackedVector2Array([at(u0, y0), at(u1, y0), at(u1, y1), at(u0, y1)])
		var uvs := PackedVector2Array([
			Vector2(u0 * world_w / tw, v / th), Vector2(u1 * world_w / tw, v / th),
			Vector2(u1 * world_w / tw, (v + dv) / th), Vector2(u0 * world_w / tw, (v + dv) / th)])
		draw_polygon(pts, PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE]), uvs, tex)
		v += dv


## Steccato basso lungo il confine u, dalla y a alla y b: traversa e paletti che rimpiccioliscono in fondo.
func _fence(u: float, ya: float, yb: float) -> void:
	var a := at(u, ya)
	var b := at(u, yb)
	var sa := px_scale(ya)
	var sb := px_scale(yb)
	draw_colored_polygon(PackedVector2Array([a + Vector2(-sa - 1, 0), a + Vector2(sa + 1, 0), b + Vector2(sb + 1, 0), b + Vector2(-sb - 1, 0)]), Art.c("legno_1"))
	draw_colored_polygon(PackedVector2Array([a + Vector2(-sa, 0), a + Vector2(sa, 0), b + Vector2(sb, 0), b + Vector2(-sb, 0)]), Art.c("legno_6"))
	var y := ya + 4.0
	while y < yb - 4.0:
		var s := px_scale(y)
		var c := at(u, y)
		var post := Rect2(c.x - 1.5 * s, y, 3.0 * s, 3.0 * s).abs()
		post = Rect2(post.position.round(), post.size.round())
		draw_rect(post.grow(1), Art.c("legno_1"))
		draw_rect(post, Art.c("legno_5"))
		draw_rect(Rect2(post.position, Vector2(post.size.x, s)), Art.c("legno_7"))
		y += 14.0 * s


## Cornice di legno con bulloni di ferro agli angoli.
func _console(r: Rect2) -> void:
	Art.draw_panel(self, r, Art.c("legno_3"), "legno_6", "legno_1", 3.0)
	for k in 4:
		var b := Vector2(r.position.x + 5 if k % 2 == 0 else r.end.x - 8, r.position.y + 5 if k < 2 else r.end.y - 8)
		draw_rect(Rect2(b, Vector2(3, 3)), Art.c("ferro_2"))
		draw_rect(Rect2(b, Vector2(3, 1)), Art.c("ferro_5"))
