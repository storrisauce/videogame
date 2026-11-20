class_name Ui3D
extends RefCounted
## Rifiniture comuni delle scene 3D (tavolo e home): colori e angoli scuri.


## Colori un po' più ricchi e contrastati (stessa resa su telefono: è nel passaggio finale del renderer).
static func grade(env: Environment) -> void:
	env.adjustment_enabled = true
	env.adjustment_contrast = 1.07
	env.adjustment_saturation = 1.14
	env.adjustment_brightness = 1.0


## Angoli scuri (vignettatura) sopra il 3D e sotto l'interfaccia: lo sguardo va al centro, dove c'è la luce.
## Copre sempre TUTTO lo schermo, anche fuori dai margini sicuri (tacca, angoli): altrimenti su iPhone si vede
## il rettangolo dove finisce (giro dei glitch su telefono).
static func vignette(parent: Control, strength := 0.6) -> ColorRect:
	var r := FullScreenRect.new()
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := ShaderMaterial.new()
	m.shader = preload("res://shaders/vignette.gdshader")
	m.set_shader_parameter("strength", strength)
	r.material = m
	parent.add_child(r)
	return r


class FullScreenRect extends ColorRect:
	# niente top_level (disegnerebbe sopra all'interfaccia): si sposta all'indietro di quanto è spostato il genitore
	func _enter_tree() -> void:
		_fit.call_deferred()
		if not get_viewport().size_changed.is_connected(_fit):
			get_viewport().size_changed.connect(_fit)
		var p := get_parent_control()
		if p and not p.resized.is_connected(_fit):
			p.resized.connect(_fit)

	func _fit() -> void:
		if not is_inside_tree():
			return
		size = get_viewport().get_visible_rect().size
		global_position = Vector2.ZERO
