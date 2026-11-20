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
static func vignette(parent: Control, strength := 0.6) -> ColorRect:
	var r := ColorRect.new()
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var m := ShaderMaterial.new()
	m.shader = preload("res://shaders/vignette.gdshader")
	m.set_shader_parameter("strength", strength)
	r.material = m
	parent.add_child(r)
	return r
