class_name StatChip
extends Control
## Contatore con icona e numero (mazzo, Letamaio, carte in mano, Caos): niente testo di debug.
## kind: "deck", "discard", "hand", "caos".

var kind := "deck"
var value := 0
var label := ""
var big := false


func _init(k: String = "deck", l: String = "", is_big := false) -> void:
	kind = k
	label = l
	big = is_big
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_value(v: int) -> void:
	if v != value:
		value = v
		queue_redraw()


func _draw() -> void:
	var s := minf(size.x, size.y)
	var c := Vector2(size.x / 2.0, s * 0.42)
	match kind:
		"caos":
			Ui.gem(self, c, s * 0.36, str(value), Ui.BIG if big else Ui.MID)
		"deck", "hand":
			# pila di carte con contorno
			for k in 3:
				var r := Rect2(c + Vector2(-s * 0.2 + k * 3, -s * 0.28 - k * 3), Vector2(s * 0.4, s * 0.52))
				Ui.plate(self, r, Art.c("legno_6") if kind == "deck" else Art.c("acqua_4"), 5, false, 0)
			Ui.text(self, Vector2(0, c.y + 8), str(value), Ui.MID, Art.c("bianco"), HORIZONTAL_ALIGNMENT_CENTER, size.x)
		"discard":
			# bidone del Letamaio
			var r := Rect2(c + Vector2(-s * 0.22, -s * 0.26), Vector2(s * 0.44, s * 0.52))
			Ui.plate(self, r, Art.c("verde_2"), 6, false, 0)
			draw_rect(Rect2(r.position.x + 3, r.position.y + r.size.y * 0.3, r.size.x - 6, 3), Ui.ink())
			draw_rect(Rect2(r.position.x + 3, r.position.y + r.size.y * 0.65, r.size.x - 6, 3), Ui.ink())
			draw_circle(r.get_center() + Vector2(0, -2), 4, Art.c("radio_1"))
			Ui.text(self, Vector2(0, c.y + 8), str(value), Ui.MID, Art.c("bianco"), HORIZONTAL_ALIGNMENT_CENTER, size.x)
	if label != "":   # di solito vuota: le icone bastano
		Ui.text(self, Vector2(0, size.y - 3), label, 11, Art.c("legno_9"), HORIZONTAL_ALIGNMENT_CENTER, size.x, 3.0)
