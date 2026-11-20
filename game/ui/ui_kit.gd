class_name Ui
extends RefCounted
## Linguaggio visivo dell'interfaccia (strada A, docs/art/design-system.md §cartoon): contorni neri spessi,
## lamiera rivettata, legno di recinto, carta; font Lilita One con contorno per titoli e numeri, Nunito per i testi.
## Tre misure fisse di testo: GRANDE 30, MEDIO 20, PICCOLO 14 (più il testo delle abilità a 12).

const BIG := 30
const MID := 20
const SMALL := 14
const BODY := 12
const OUTLINE := 4.0     ## spessore dei contorni (punti)

static var _display: Font
static var _body: Font


static func display() -> Font:
	if _display == null:
		_display = load("res://assets/fonts/LilitaOne-Regular.ttf")
	return _display


static func body() -> Font:
	if _body == null:
		var base: FontFile = load("res://assets/fonts/Nunito.ttf")
		var fv := FontVariation.new()
		fv.base_font = base
		fv.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 850}
		_body = fv
	return _body


static func ink() -> Color:
	return Art.c("inchiostro")


## Testo con contorno spesso (prima il contorno, poi il riempimento).
static func text(ci: CanvasItem, pos: Vector2, t: String, size: int, color := Color.WHITE, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0, outline := OUTLINE, font: Font = null) -> void:
	var f := font if font else display()
	if outline > 0.0:
		ci.draw_string_outline(f, pos, t, align, width, size, int(outline * 2.0), ink())
	ci.draw_string(f, pos, t, align, width, size, color)


## Testo che si restringe fino a stare nella larghezza (mai tagliato); va a capo su due righe se serve.
static func fit_text(ci: CanvasItem, rect: Rect2, t: String, max_size: int, color := Color.WHITE, min_size := 9) -> void:
	var f := display()
	var size := max_size
	while size > min_size and f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > rect.size.x:
		size -= 1
	if f.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= rect.size.x:
		text(ci, Vector2(rect.position.x, rect.position.y + rect.size.y / 2.0 + size * 0.36), t, size, color, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x)
		return
	# due righe: spezza vicino a metà
	var words := t.split(" ")
	var best := 1
	var best_d := 1e9
	for i in range(1, words.size()):
		var a := " ".join(words.slice(0, i))
		var b := " ".join(words.slice(i))
		var d := absf(f.get_string_size(a, 0, -1, size).x - f.get_string_size(b, 0, -1, size).x)
		if d < best_d:
			best_d = d
			best = i
	var l1 := " ".join(words.slice(0, best))
	var l2 := " ".join(words.slice(best))
	size = max_size
	while size > min_size and maxf(f.get_string_size(l1, 0, -1, size).x, f.get_string_size(l2, 0, -1, size).x) > rect.size.x:
		size -= 1
	var lh := size * 1.0
	var y0 := rect.position.y + rect.size.y / 2.0 - lh / 2.0 + size * 0.36
	text(ci, Vector2(rect.position.x, y0), l1, size, color, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, OUTLINE * 0.8)
	text(ci, Vector2(rect.position.x, y0 + lh), l2, size, color, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, OUTLINE * 0.8)


static func _box(fill: Color, radius: int, border: int, shadow := 4) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = ink()
	sb.set_border_width_all(border)
	sb.set_corner_radius_all(radius)
	sb.anti_aliasing = true
	if shadow > 0:
		sb.shadow_color = ink()
		sb.shadow_offset = Vector2(0, shadow)
		sb.shadow_size = 1
	return sb


## Pannello: contorno nero, riempimento, luce in alto, ombra in basso, bulloni negli angoli (se `rivets`).
static func plate(ci: CanvasItem, r: Rect2, fill: Color, radius := 10, rivets := true, shadow := 4) -> void:
	r = Rect2(r.position.round(), r.size.round())
	ci.draw_style_box(_box(fill, radius, 4, shadow), r)
	var hl := _box(Color(1, 1, 1, 0.22), maxi(radius - 4, 0), 0, 0)
	ci.draw_style_box(hl, Rect2(r.position + Vector2(6, 5), Vector2(r.size.x - 12, 4)))
	var sh := _box(Color(0, 0, 0, 0.18), maxi(radius - 4, 0), 0, 0)
	ci.draw_style_box(sh, Rect2(r.position.x + 5, r.end.y - 10, r.size.x - 10, 5))
	if rivets and r.size.x > 40 and r.size.y > 30:
		for k in 4:
			var p := Vector2(r.position.x + 11 if k % 2 == 0 else r.end.x - 11, r.position.y + 11 if k < 2 else r.end.y - 13)
			ci.draw_circle(p, 4.5, ink())
			ci.draw_circle(p, 3, Art.c("ferro_4"))
			ci.draw_circle(p + Vector2(-1, -1), 1.2, Art.c("ferro_6"))


## Pillola (etichetta): fondo pieno con contorno, testo centrato.
static func pill(ci: CanvasItem, center: Vector2, t: String, size: int, fill: Color, color := Color.WHITE) -> Rect2:
	var w := display().get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x + size * 1.2
	var r := Rect2(center - Vector2(w / 2.0, size * 0.75), Vector2(w, size * 1.5))
	ci.draw_style_box(_box(fill, int(r.size.y / 2.0), 3, 2), r)
	text(ci, Vector2(r.position.x, r.position.y + r.size.y / 2.0 + size * 0.36), t, size, color, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, OUTLINE * 0.75)
	return r


## Gemma del costo/Caos: tondo verde radioattivo con riflesso e numero.
static func gem(ci: CanvasItem, c: Vector2, r: float, t: String, size: int) -> void:
	ci.draw_circle(c + Vector2(0, 3), r, ink())
	ci.draw_circle(c, r, ink())
	ci.draw_circle(c, r - 3.5, Art.c("radio_1"))
	ci.draw_circle(c + Vector2(-r * 0.3, -r * 0.32), r * 0.32, Art.c("radio_2"))
	text(ci, Vector2(c.x - r, c.y + size * 0.36), t, size, Art.c("bianco"), HORIZONTAL_ALIGNMENT_CENTER, r * 2.0)


## Icona dell'attacco: una lama (coltello da cucina) con contorno.
static func sword(ci: CanvasItem, c: Vector2, s: float) -> void:
	var blade := PackedVector2Array([c + Vector2(-0.55, 0.55) * s, c + Vector2(0.35, -0.35) * s, c + Vector2(0.55, -0.55) * s, c + Vector2(0.45, -0.25) * s, c + Vector2(-0.35, 0.65) * s])
	var handle := PackedVector2Array([c + Vector2(-0.55, 0.55) * s, c + Vector2(-0.35, 0.35) * s, c + Vector2(-0.15, 0.55) * s, c + Vector2(-0.35, 0.75) * s])
	ci.draw_colored_polygon(_grow(blade, 2.5), ink())
	ci.draw_colored_polygon(_grow(handle, 2.5), ink())
	ci.draw_colored_polygon(blade, Art.c("ferro_5"))
	ci.draw_colored_polygon(handle, Art.c("legno_5"))


## Icona della vita: un cuore verde (le creature) o rosso (la Pazienza).
static func heart(ci: CanvasItem, c: Vector2, s: float, fill: Color) -> void:
	var pts := PackedVector2Array()
	for i in 24:
		var t := TAU * i / 24.0
		var x := 16.0 * pow(sin(t), 3)
		var y := -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t))
		pts.append(c + Vector2(x, y) * s / 34.0)
	ci.draw_colored_polygon(_grow(pts, 2.5), ink())
	ci.draw_colored_polygon(pts, fill)
	ci.draw_circle(c + Vector2(-s * 0.18, -s * 0.12), s * 0.08, Color(1, 1, 1, 0.6))


static func _grow(pts: PackedVector2Array, d: float) -> PackedVector2Array:
	var g := Geometry2D.offset_polygon(pts, d)
	return g[0] if not g.is_empty() else pts


## Tema dei controlli standard (bottoni, caselle, pannelli) nello stesso linguaggio.
static func theme() -> Theme:
	var t := Theme.new()
	t.default_font = display()
	t.default_font_size = SMALL
	var looks := {"normal": "legno_5", "hover": "legno_6", "pressed": "legno_4", "disabled": "legno_3", "focus": "legno_5"}
	for st: String in looks:
		var sb := _box(Art.c(looks[st]), 12, 4, 0 if st == "pressed" else 4)
		sb.border_width_bottom = 4
		sb.set_content_margin_all(8)
		if st == "pressed":
			sb.content_margin_top = 11
		if st == "focus":
			sb.draw_center = false
			sb.border_color = Art.c("radio_2")
			sb.shadow_size = 0
		for cls in ["Button", "OptionButton", "CheckBox"]:
			t.set_stylebox(st, cls, sb)
	for cls in ["Button", "OptionButton", "CheckBox"]:
		for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
			t.set_color(k, cls, Art.c("bianco"))
		t.set_color("font_disabled_color", cls, Art.c("legno_8"))
		t.set_color("font_outline_color", cls, ink())
		t.set_constant("outline_size", cls, 7)
		t.set_font_size("font_size", cls, SMALL + 2)
	t.set_color("font_color", "Label", Art.c("bianco"))
	t.set_color("font_outline_color", "Label", ink())
	t.set_constant("outline_size", "Label", 6)
	var panel := _box(Art.c("ferro_2"), 12, 4, 4)
	panel.set_content_margin_all(12)
	t.set_stylebox("panel", "PanelContainer", panel)
	t.set_stylebox("panel", "PopupMenu", panel)
	return t
