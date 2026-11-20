class_name FxLayer
extends Control
## Effetti 2D sopra tutto: numeri di danno che saltano fuori, carte che volano dalla mano al recinto,
## scuotimento di un pannello. Non prende mai i tocchi. Regole di movimento (skill animate / game-feel):
## entrate in ease-out, mai da scala 0, 150–400 ms, i colpi forti più grandi e più lunghi.

var reduce_motion := false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## Numero che salta fuori (danno, cura, testo breve) e sale svanendo.
func pop_number(text: String, at: Vector2, color: Color, big := false) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 26 if big else 18)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Art.c("inchiostro"))
	l.add_theme_constant_override("outline_size", 6)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	l.size = Vector2(maxf(160.0, text.length() * (14.0 if big else 10.0)), 40)
	# sempre dentro lo schermo
	l.position = Vector2(clampf(at.x - l.size.x / 2.0, 4.0, size.x - l.size.x - 4.0), clampf(at.y - 20.0, 4.0, size.y - 44.0))
	l.pivot_offset = l.size / 2.0
	if reduce_motion or not is_inside_tree():
		get_tree().create_timer(0.8).timeout.connect(l.queue_free) if is_inside_tree() else l.queue_free()
		return
	l.scale = Vector2(0.6, 0.6)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "scale", Vector2(1.25, 1.25) if big else Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "position:y", l.position.y - (46 if big else 32), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(l, "modulate:a", 0.0, 0.25)
	tw.chain().tween_callback(l.queue_free)


## Una copia della carta vola dalla mano al recinto e si rimpicciolisce (continuità: è la stessa cosa).
func fly_card(card: CardInst, m: Match, from: Rect2, to: Vector2) -> void:
	if reduce_motion or not is_inside_tree():
		return
	var v := CardView.new()
	v.setup(card, m)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.set_process(false)
	add_child(v)
	v.position = from.position
	v.size = from.size
	v.pivot_offset = from.size / 2.0
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(v, "position", to - from.size / 2.0, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(v, "scale", Vector2(0.45, 0.45), 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(v, "modulate:a", 0.0, 0.1).set_delay(0.14)
	tw.chain().tween_callback(v.queue_free)


## Tremolio breve di un controllo (es. il ritratto colpito).
func shake_control(c: Control, strength := 6.0) -> void:
	if reduce_motion or c == null:
		return
	var rest := c.position
	var tw := create_tween()
	for k in 5:
		var d := strength * (1.0 - k / 5.0)
		tw.tween_property(c, "position", rest + Vector2(d if k % 2 == 0 else -d, 0), 0.03)
	tw.tween_property(c, "position", rest, 0.04)
