class_name SpriteView
extends Control
## Uno sprite animato su un riquadro di terreno, a scala intera (per menu e schede).

var tex: Texture2D
var terrain := "erba"
var scale_px := Art.SCALE
var flip := false
var art_id := ""      ## se impostato: usa l'illustrazione 3D (o la figura) di questa carta/sopravvissuto
var art_hero := false
var _last := -1


func _init(t: Texture2D = null, s: int = Art.SCALE) -> void:
	tex = t
	scale_px = s
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_texture(t: Texture2D) -> void:
	tex = t
	queue_redraw()


func _process(_d: float) -> void:
	if tex:
		var f := Art.frame_now(tex)
		if f != _last:
			_last = f
			queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	Art.draw_panel(self, r, Art.c("legno_2"), "legno_5", "legno_1", 2.0)
	var win := r.grow(-5)
	if terrain != "":
		Art.draw_terrain(self, terrain, win)
	if art_id != "":
		Art.draw_art(self, art_id, art_hero, win.grow_individual(0, 0, 0, -4), 0, flip)
	elif tex:
		Art.draw_frame(self, tex, Art.frame_now(tex), win.grow_individual(0, 0, 0, -4), scale_px, flip)
	draw_rect(win, Art.c("legno_1"), false, 1.0)
