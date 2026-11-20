class_name Art
extends RefCounted
## Arte in pixel art (docs/art/design-system.md): colori della palette, sprite a strisce, terreni.
## Gli sprite sono PNG a strisce orizzontali di fotogrammi quadrati, in res://assets/cards/<id>.png e
## res://assets/heroes/<id>.png. Si disegnano sempre a scala intera (×SCALE) e appoggiati in basso.

const SCALE := 2          ## un pixel dello sprite = 2 punti dello schermo, per tutto il gioco
const FPS := 5.0          ## velocità delle animazioni di riposo

static var _colors: Dictionary = {}
static var _tex: Dictionary = {}


## Colore della palette per nome (es. "legno_3"). Colori sconosciuti: magenta, per vederli subito.
static func c(name: String) -> Color:
	if _colors.is_empty():
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/palette.json"))
		for ramp: Dictionary in data["ramps"].values():
			for k: String in ramp:
				_colors[k] = Color(ramp[k])
	return _colors.get(name, Color.MAGENTA)


static func _load(path: String) -> Texture2D:
	if not _tex.has(path):
		_tex[path] = load(path) if ResourceLoader.exists(path) else null
	return _tex[path]


static func card_tex(id: String) -> Texture2D:
	return _load("res://assets/cards/%s.png" % id)


static func hero_tex(id: String) -> Texture2D:
	return _load("res://assets/heroes/%s.png" % id)


static func terrain_tex(band: String) -> Texture2D:
	return _load("res://assets/board/%s.png" % band)


## Fotogramma corrente dell'animazione di riposo; `offset` sfasa le creature tra loro.
static func frame_now(tex: Texture2D, offset: int = 0) -> int:
	var n := maxi(1, tex.get_width() / maxi(1, tex.get_height()))
	return (int(Time.get_ticks_msec() / 1000.0 * FPS) + offset) % n


## Disegna un fotogramma dentro `area`, centrato in orizzontale e appoggiato in basso, a scala intera.
## Se lo sprite è più grande dell'area viene tagliato (la scala non cambia mai: le taglie restano vere).
static func draw_frame(ci: CanvasItem, tex: Texture2D, frame: int, area: Rect2, scale: int = SCALE, flip := false, modulate := Color.WHITE) -> void:
	if tex == null:
		return
	var fh := tex.get_height()
	var fw := fh
	var vw := mini(fw, int(area.size.x / scale))
	var vh := mini(fh, int(area.size.y / scale))
	var src := Rect2(frame * fw + (fw - vw) / 2, fh - vh, vw, vh)
	var dst_size := Vector2(vw, vh) * scale
	var dst := Rect2(Vector2(roundf(area.position.x + (area.size.x - dst_size.x) / 2.0), roundf(area.end.y - dst_size.y)), dst_size)
	if flip:   # specchio orizzontale attorno al centro della destinazione
		ci.draw_set_transform(Vector2(2.0 * dst.position.x + dst.size.x, 0), 0.0, Vector2(-1, 1))
	ci.draw_texture_rect_region(tex, dst, src, modulate)
	if flip:
		ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Riempie `r` con un terreno ripetuto a scala intera.
static func draw_terrain(ci: CanvasItem, band: String, r: Rect2, scale: int = SCALE, modulate := Color.WHITE) -> void:
	var t := terrain_tex(band)
	if t == null:
		ci.draw_rect(r, c("verde_4"))
		return
	# ripetizione a scala intera: si disegna in coordinate ridotte e si ingrandisce
	ci.draw_set_transform(r.position, 0.0, Vector2(scale, scale))
	ci.draw_texture_rect(t, Rect2(Vector2.ZERO, (r.size / scale).floor()), true, modulate)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Riquadro di legno in stile 9 fette: contorno scuro, bordo, interno. `inset` = spessore del bordo.
static func draw_panel(ci: CanvasItem, r: Rect2, inner: Color, border := "legno_5", outline := "legno_1", inset := 2.0) -> void:
	r = Rect2(r.position.round(), r.size.round())
	ci.draw_rect(r, c(outline))
	ci.draw_rect(r.grow(-1), c(border))
	ci.draw_rect(Rect2(r.position + Vector2(1, 1), Vector2(r.size.x - 2, 1)), c("legno_7"))   # luce in alto
	ci.draw_rect(r.grow(-1 - inset), inner)


## Recinto di legno attorno a `r`: traversa chiara con ombra e paletti ogni 16 px (scala del mondo).
static func draw_fence(ci: CanvasItem, r: Rect2, scale: int = SCALE) -> void:
	var t := float(scale) * 2.0
	var rail := c("legno_7")
	var dark := c("legno_3")
	var line := c("legno_1")
	for side in 4:
		var rr: Rect2
		match side:
			0: rr = Rect2(r.position.x, r.position.y, r.size.x, t)
			1: rr = Rect2(r.position.x, r.end.y - t, r.size.x, t)
			2: rr = Rect2(r.position.x, r.position.y, t, r.size.y)
			_: rr = Rect2(r.end.x - t, r.position.y, t, r.size.y)
		ci.draw_rect(rr.grow(1), line)
	for side in 4:
		var rr: Rect2
		match side:
			0: rr = Rect2(r.position.x, r.position.y, r.size.x, t)
			1: rr = Rect2(r.position.x, r.end.y - t, r.size.x, t)
			2: rr = Rect2(r.position.x, r.position.y, t, r.size.y)
			_: rr = Rect2(r.end.x - t, r.position.y, t, r.size.y)
		ci.draw_rect(rr, rail)
		ci.draw_rect(Rect2(rr.position.x, rr.end.y - scale, rr.size.x, scale) if side < 2 else Rect2(rr.end.x - scale, rr.position.y, scale, rr.size.y), dark)
	# paletti
	var step := 16.0 * scale
	var post := Vector2(t + 2.0 * scale, t + 2.0 * scale)
	var x := r.position.x
	while x <= r.end.x - post.x + 0.5:
		for y in [r.position.y - scale, r.end.y - post.y + scale]:
			_post(ci, Rect2(Vector2(x, y), post), scale)
		x += step
	var y2 := r.position.y + step
	while y2 < r.end.y - step * 0.5:
		for x2 in [r.position.x - scale, r.end.x - post.x + scale]:
			_post(ci, Rect2(Vector2(x2, y2), post), scale)
		y2 += step


static func _post(ci: CanvasItem, p: Rect2, scale: int) -> void:
	ci.draw_rect(p.grow(1), c("legno_1"))
	ci.draw_rect(p, c("legno_5"))
	ci.draw_rect(Rect2(p.position, Vector2(p.size.x, scale)), c("legno_7"))
	ci.draw_rect(Rect2(p.position.x, p.end.y - scale, p.size.x, scale), c("legno_3"))
