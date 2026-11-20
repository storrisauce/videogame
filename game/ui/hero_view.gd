class_name HeroView
extends Control
## Sopravvissuto in un angolo in alto: ritratto grande, nome, Pazienza come numero con cuore e barra,
## badge dell'abilità (pulsa quando è pronta, altrimenti mostra i turni di ricarica). Tocca = usa l'abilità.

signal tapped(player: int)

var player := 0
var m: Match
var highlighted := false
var _last_frame := -1
var _shown_hp := -1.0


func _init(p: int) -> void:
	player = p
	mouse_filter = Control.MOUSE_FILTER_STOP


func refresh(match_ref: Match) -> void:
	m = match_ref
	if _shown_hp < 0.0:
		_shown_hp = m.players[player].hp
	queue_redraw()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and not e.pressed:
		tapped.emit(player)
		accept_event()


func _process(delta: float) -> void:
	if m == null:
		return
	var redraw := false
	# la barra scende verso il valore vero (si vede il colpo)
	var hp := float(m.players[player].hp)
	if absf(_shown_hp - hp) > 0.01:
		_shown_hp = move_toward(_shown_hp, hp, maxf(absf(_shown_hp - hp) * 6.0, 4.0) * delta)
		redraw = true
	var tex := Art.hero_tex(m.players[player].hero["id"])
	if tex:
		var f := Art.frame_now(tex, player * 2)
		if f != _last_frame:
			_last_frame = f
			redraw = true
	if m.players[player].cooldown <= 0:
		redraw = true   # badge che pulsa
	if redraw:
		queue_redraw()


func _draw() -> void:
	if m == null:
		return
	var ps := m.players[player]
	var w := size.x
	# ritratto
	var por := Rect2(0, 0, w, minf(w, size.y * 0.56))
	Ui.plate(self, por, Art.c("legno_5") if player == 0 else Art.c("ruggine_2"), 14, true, 5)
	var win := por.grow(-9)
	draw_rect(win, Art.c("verde_5"))
	draw_rect(Rect2(win.position.x, win.position.y + win.size.y * 0.6, win.size.x, win.size.y * 0.4), Art.c("verde_3"))
	Art.draw_art(self, String(ps.hero["id"]), true, win, player * 2, player == 1)
	draw_rect(win, Ui.ink(), false, 3.0)
	if highlighted:
		var hl := StyleBoxFlat.new()
		hl.draw_center = false
		hl.border_color = Art.c("radio_2")
		hl.set_border_width_all(4)
		hl.set_corner_radius_all(16)
		draw_style_box(hl, por.grow(3))
	# nome
	Ui.fit_text(self, Rect2(0, por.end.y + 2, w, 18), String(ps.hero["name"]), Ui.SMALL, Art.c("legno_9"), 9)
	# Pazienza: cuore + numero grande + barra
	var y := por.end.y + 22
	Ui.heart(self, Vector2(14, y + 14), 26, Art.c("rosso_2"))
	Ui.text(self, Vector2(30, y + 24), str(ps.hp), Ui.BIG, Art.c("bianco"))
	Ui.text(self, Vector2(30 + Ui.display().get_string_size(str(ps.hp), 0, -1, Ui.BIG).x + 3, y + 24), "/%d" % ps.max_hp, Ui.SMALL, Art.c("legno_9"))
	var bar := Rect2(2, y + 32, w - 4, 10)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Art.c("rosso_1")
	sb.border_color = Ui.ink()
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(5)
	draw_style_box(sb, bar)
	var frac := clampf(_shown_hp / float(maxi(ps.max_hp, 1)), 0.0, 1.0)
	if frac > 0.0:
		var fill := StyleBoxFlat.new()
		fill.bg_color = Art.c("rosso_3")
		fill.set_corner_radius_all(3)
		draw_style_box(fill, Rect2(bar.position + Vector2(3, 3), Vector2((bar.size.x - 6) * frac, bar.size.y - 6)))
	# badge dell'abilità
	var by := bar.end.y + 14
	if ps.cooldown <= 0:
		var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * 5.0)
		var c := Art.c("radio_1").lerp(Art.c("radio_2"), pulse)
		Ui.pill(self, Vector2(w / 2.0, by), "Abilità pronta" if player == 0 else "Abilità carica", 12, c.darkened(0.25), Art.c("bianco"))
	else:
		Ui.pill(self, Vector2(w / 2.0, by), "Abilità fra %d" % ps.cooldown, 12, Art.c("ferro_2"), Art.c("legno_9"))
