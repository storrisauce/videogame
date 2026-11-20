class_name Juice
extends RefCounted
## Piccole risposte al tocco, uguali in tutto il gioco (skill emil-design-eng / game-feel):
## pressione a 0,97 in 100 ms, rilascio in 160 ms con un leggero rimbalzo. Funziona anche nei Container
## grazie a offset_transform_* (Godot 4.7), che il container non tocca.

static func press(b: Control) -> void:
	b.offset_transform_enabled = true
	b.resized.connect(func(): b.offset_transform_pivot = b.size / 2.0)
	b.offset_transform_pivot = b.size / 2.0
	var down := func():
		Sfx.play("tap", 1.0, 0.04)
		Sfx.buzz("tap")
		var tw := b.create_tween()
		tw.tween_property(b, "offset_transform_scale", Vector2(0.97, 0.97), 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var up := func():
		var tw := b.create_tween()
		tw.tween_property(b, "offset_transform_scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if b is BaseButton:
		(b as BaseButton).button_down.connect(down)
		(b as BaseButton).button_up.connect(up)


## Entrata di un elemento: da 0,94 e trasparente a pieno, in ease-out, con un ritardo per lo sfalsamento.
static func enter(c: Control, delay := 0.0, dy := 10.0) -> void:
	c.offset_transform_enabled = true
	c.offset_transform_pivot = c.size / 2.0
	c.offset_transform_scale = Vector2(0.94, 0.94)
	c.offset_transform_position = Vector2(0, dy)
	c.modulate.a = 0.0
	var tw := c.create_tween()
	tw.set_parallel(true)
	tw.tween_property(c, "modulate:a", 1.0, 0.22).set_delay(delay)
	tw.tween_property(c, "offset_transform_scale", Vector2.ONE, 0.32).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "offset_transform_position", Vector2.ZERO, 0.3).set_delay(delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
