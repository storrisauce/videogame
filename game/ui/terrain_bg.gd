class_name TerrainBG
extends Control
## Sfondo di terreno ripetuto (erba del tavolo per default), a scala intera. Non prende i tocchi.

var band := "erba"
var shade := 0.0   ## 0 = pieno, 0.3 = un po' scurito (per far risaltare l'interfaccia)


func _init(b: String = "erba", s: float = 0.0) -> void:
	band = b
	shade = s
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	Art.draw_terrain(self, band, r)
	if shade > 0.0:
		draw_rect(r, Color(Art.c("notte"), shade))
