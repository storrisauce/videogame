class_name StatChip
extends Control
## Contatore leggibile: icona + nome + numero (Mano, Mazzo, Letamaio, Caos). Tocca = una frase che spiega.
## kind: "deck", "discard", "hand", "caos". big = la gemma grande del tuo Caos (vicino a "Fine turno").
## Dopo la prova su iPhone: le sole icone con un numero sopra non si capivano.

signal tapped(chip: StatChip)

const NAMES := {"deck": "Mazzo", "discard": "Letamaio", "hand": "Mano", "caos": "Caos"}

var kind := "deck"
var value := 0
var label := ""
var big := false
var mine := true   ## tuo o dell'avversario (cambia la spiegazione)


func _init(k: String = "deck", l: String = "", is_big := false) -> void:
	kind = k
	label = l if l != "" else NAMES.get(k, "")
	big = is_big
	mouse_filter = Control.MOUSE_FILTER_STOP


func set_value(v: int) -> void:
	if v != value:
		value = v
		queue_redraw()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and not e.pressed:
		tapped.emit(self)
		accept_event()


## Frase che spiega il contatore (si mostra toccandolo).
func explain() -> String:
	match kind:
		"caos":
			return ("Il tuo Caos" if mine else "Il Caos dell'avversario") + ": serve per giocare le carte (gemma verde in alto a sinistra sulla carta) e per Scuotere le creature. A ogni turno si ricarica, e a ogni giro ne arriva uno in più (massimo 8)."
		"deck":
			return ("Il tuo mazzo" if mine else "Il mazzo dell'avversario") + ": le carte ancora da pescare. Se ne pesca una a ogni turno."
		"hand":
			return ("Le tue carte in mano." if mine else "Quante carte ha in mano l'avversario.")
		"discard":
			return "Il Letamaio: qui finiscono le carte usate e le creature sconfitte."
	return ""


func _draw() -> void:
	if big:
		_draw_big()
		return
	# riga: pannellino scuro, icona a sinistra, nome piccolo, numero grande a destra
	var h := size.y
	var r := Rect2(Vector2.ZERO, size)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(Art.c("inchiostro"), 0.72)
	sb.set_corner_radius_all(int(h / 2.0))
	draw_style_box(sb, r)
	var ic := Vector2(h * 0.62, h / 2.0)
	_icon(ic, h * 0.42)
	var num := str(value)
	var nsize := int(clampf(h * 0.62, 12, 22))
	var nw := Ui.display().get_string_size(num, HORIZONTAL_ALIGNMENT_LEFT, -1, nsize).x
	Ui.text(self, Vector2(size.x - nw - h * 0.35, h / 2.0 + nsize * 0.36), num, nsize,
		Art.c("radio_1") if kind == "caos" else Art.c("bianco"), HORIZONTAL_ALIGNMENT_LEFT, -1, 3.0)
	var lsize := int(clampf(h * 0.42, 9, 13))
	Ui.text(self, Vector2(h * 1.2, h / 2.0 + lsize * 0.38), label, lsize, Art.c("legno_9"), HORIZONTAL_ALIGNMENT_LEFT, -1, 2.0, Ui.body())


func _draw_big() -> void:
	# il tuo Caos: gemma grande col numero, e sotto la scritta "Caos"
	var s := minf(size.x, size.y - 18)
	var c := Vector2(size.x / 2.0, s * 0.5)
	Ui.gem(self, c, s * 0.42, str(value), Ui.BIG)
	Ui.text(self, Vector2(0, c.y + s * 0.42 + Ui.SMALL + 4), label, Ui.SMALL, Art.c("radio_1"), HORIZONTAL_ALIGNMENT_CENTER, size.x, 3.0)


func _icon(c: Vector2, s: float) -> void:
	var ink := Ui.ink()
	match kind:
		"caos":
			# gemma verde radioattiva
			var pts := PackedVector2Array([c + Vector2(0, -s), c + Vector2(s * 0.9, 0), c + Vector2(0, s), c + Vector2(-s * 0.9, 0)])
			var o := pts.duplicate()
			o.append(pts[0])
			draw_colored_polygon(pts, Art.c("radio_1"))
			draw_polyline(o, ink, 2.0, true)
			draw_circle(c + Vector2(-s * 0.25, -s * 0.3), s * 0.18, Color(1, 1, 1, 0.7))
		"deck":
			# pila di carte
			for k in 3:
				var r := Rect2(c + Vector2(-s * 0.6 + k * 1.5, -s * 0.85 - k * 1.5), Vector2(s * 1.2, s * 1.6))
				_card(r, Art.c("legno_6"))
		"hand":
			# ventaglio di tre carte
			for k in 3:
				var a := (k - 1) * 0.35
				var xf := Transform2D(a, c + Vector2((k - 1) * s * 0.35, s * 0.2))
				draw_set_transform_matrix(xf)
				_card(Rect2(Vector2(-s * 0.45, -s * 0.95), Vector2(s * 0.9, s * 1.3)), Art.c("acqua_4"))
			draw_set_transform_matrix(Transform2D.IDENTITY)
		"discard":
			# bidone del letame
			var r := Rect2(c - Vector2(s * 0.7, s * 0.8), Vector2(s * 1.4, s * 1.7))
			_card(r, Art.c("verde_2"))
			draw_rect(Rect2(r.position.x - 2, r.position.y - 1, r.size.x + 4, 3), ink)
			draw_circle(r.get_center(), s * 0.22, Art.c("radio_1"))


func _card(r: Rect2, col: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.border_color = Ui.ink()
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(3)
	draw_style_box(sb, r)
