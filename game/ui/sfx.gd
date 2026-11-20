class_name Sfx
extends Node
## Suoni, musica e vibrazioni del gioco, da un solo posto (skill godot-audio, audio-design, game-feel).
## Uso: Sfx.play("hit"), Sfx.music("match"), Sfx.buzz("crit"). Il nodo si crea da solo la prima volta.
## Bus: Master <- Musica, Effetti. Sul Master un limitatore: tanti colpi insieme non gracchiano.
## I suoni sono originali, sintetizzati da art/audio/gen_audio.py.

const SFX_DIR := "res://assets/audio/sfx/"
const MUSIC_DIR := "res://assets/audio/music/"
const MUSIC_DB := -9.0         ## la musica sta sotto agli effetti
const DUCK_DB := -10.0         ## quanto si abbassa la musica sotto i colpi grossi

## Volume per suono (dB): i colpi davanti, i clic dietro.
const LEVEL := {
	"tap": -8.0, "card_pick": -6.0, "card_drop": -8.0, "whoosh": -6.0, "land": -2.0, "clank": -3.0,
	"jump": -7.0, "hit": -1.0, "hit_hero": 0.0, "botta": 0.0, "death": -3.0, "boing": -4.0, "zap": -6.0,
	"buff": -5.0, "debuff": -5.0, "caos": -6.0, "hero_power": -3.0, "turn_you": -5.0, "turn_opp": -6.0,
	"lever": -4.0, "tick": -10.0, "dial_colpo": -3.0, "dial_botta": -1.0, "dial_normale": -5.0,
	"deny": -10.0, "win": -1.0, "lose": -3.0, "coins": -4.0, "resurrect": -2.0, "play": -2.0,
	"swish": -6.0, "pop": -6.0,
}

## Vibrazioni: [millisecondi, intensità 0..1].
const BUZZ := {
	"tap": [12, 0.25], "light": [20, 0.4], "land": [30, 0.55], "hit": [45, 0.8], "heavy": [70, 1.0],
	"crit": [140, 1.0], "death": [35, 0.6], "win": [90, 0.7],
}

static var muted := false        ## test e simulazioni: niente audio
static var music_on := true
static var sfx_on := true
static var vibra_on := true
static var _inst: Sfx

var _players := {}
var _music_a := AudioStreamPlayer.new()
var _music_b := AudioStreamPlayer.new()
var _music_name := ""
var _duck_tw: Tween
var _ticker := Timer.new()


static func _node() -> Sfx:
	if _inst and is_instance_valid(_inst):
		return _inst
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	_inst = Sfx.new()
	_inst.name = "Sfx"
	tree.root.add_child.call_deferred(_inst)
	return _inst


## Applica le impostazioni del profilo (Musica, Effetti, Vibrazione).
static func configure(music: bool, effects: bool, vibra: bool) -> void:
	music_on = music
	sfx_on = effects
	vibra_on = vibra
	var s := _node()
	if s:
		s._apply_buses()


## Un effetto: pitch leggermente diverso ogni volta, così i colpi ripetuti non sono identici.
static func play(id: String, pitch := 1.0, vary := 0.06, gain_db := 0.0) -> void:
	if muted or not sfx_on:
		return
	var s := _node()
	if s:
		s._play(id, pitch * randf_range(1.0 - vary, 1.0 + vary), gain_db)


## Effetto in ritardo (per farlo coincidere con l'impatto di un'animazione).
static func play_at(delay: float, id: String, pitch := 1.0, vary := 0.06) -> void:
	if muted or not sfx_on:
		return
	var s := _node()
	if s == null:
		return
	if delay <= 0.0:
		play(id, pitch, vary)
		return
	var tree := Engine.get_main_loop() as SceneTree
	tree.create_timer(delay, true, false, true).timeout.connect(func(): play(id, pitch, vary))


## Musica in sottofondo, a giro continuo; cambiando brano si incrocia in 0,8 s. "" = silenzio.
static func music(id: String) -> void:
	if muted:
		return
	var s := _node()
	if s:
		s._music(id)


## Abbassa per un attimo la musica (Botta Atomica, vittoria, sconfitta).
static func duck(seconds := 0.8) -> void:
	var s := _node()
	if s and not muted:
		s._duck(seconds)


## Vibrazione del telefono (sul computer non fa niente).
static func buzz(kind: String) -> void:
	if muted or not vibra_on or not BUZZ.has(kind):
		return
	if not OS.has_feature("mobile"):
		return
	var b: Array = BUZZ[kind]
	Input.vibrate_handheld(int(b[0]), float(b[1]))


## Il ticchettio del contatore Geiger mentre il mirino gira.
static func geiger(on: bool) -> void:
	var s := _node()
	if s == null or muted:
		return
	if on and sfx_on:
		s._next_tick()
	else:
		s._ticker.stop()


# --- dentro ------------------------------------------------------------------------

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_make_buses()
	for p in [_music_a, _music_b]:
		p.bus = &"Musica"
		p.volume_db = -60.0
		add_child(p)
	_ticker.one_shot = true
	_ticker.timeout.connect(_on_tick)
	add_child(_ticker)
	if _music_name != "":
		var n := _music_name
		_music_name = ""
		_music(n)


func _make_buses() -> void:
	for bus_name in ["Musica", "Effetti"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var i := AudioServer.bus_count - 1
			AudioServer.set_bus_name(i, bus_name)
			AudioServer.set_bus_send(i, &"Master")
	var master := AudioServer.get_bus_index(&"Master")
	var has_limiter := false
	for k in AudioServer.get_bus_effect_count(master):
		if AudioServer.get_bus_effect(master, k) is AudioEffectHardLimiter:
			has_limiter = true
	if not has_limiter:
		var lim := AudioEffectHardLimiter.new()
		lim.ceiling_db = -0.5
		lim.pre_gain_db = 0.0
		AudioServer.add_bus_effect(master, lim)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Musica"), MUSIC_DB)
	_apply_buses()


func _apply_buses() -> void:
	var mi := AudioServer.get_bus_index(&"Musica")
	var ei := AudioServer.get_bus_index(&"Effetti")
	if mi >= 0:
		AudioServer.set_bus_mute(mi, not music_on)
	if ei >= 0:
		AudioServer.set_bus_mute(ei, not sfx_on)


func _player(id: String) -> AudioStreamPlayer:
	if _players.has(id):
		return _players[id]
	var path := SFX_DIR + id + ".wav"
	if not ResourceLoader.exists(path):
		push_warning("Suono mancante: " + id)
		_players[id] = null
		return null
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.bus = &"Effetti"
	p.max_polyphony = 6
	p.volume_db = LEVEL.get(id, -6.0)
	add_child(p)
	_players[id] = p
	return p


func _play(id: String, pitch: float, gain_db: float) -> void:
	if not is_inside_tree():
		_play.call_deferred(id, pitch, gain_db)
		return
	var p := _player(id)
	if p == null:
		return
	p.pitch_scale = pitch
	p.volume_db = LEVEL.get(id, -6.0) + gain_db
	p.play()


func _music(id: String) -> void:
	if id == _music_name:
		return
	_music_name = id
	if not is_inside_tree():
		return
	var old := _music_a
	var nw := _music_b
	_music_a = nw
	_music_b = old
	var tw := create_tween().set_parallel(true)
	tw.tween_property(old, "volume_db", -60.0, 0.8)
	tw.chain().tween_callback(old.stop)
	if id == "":
		return
	var path := MUSIC_DIR + id + ".ogg"
	if not ResourceLoader.exists(path):
		push_warning("Musica mancante: " + id)
		return
	var st: AudioStream = load(path)
	if st is AudioStreamOggVorbis:
		(st as AudioStreamOggVorbis).loop = true
	nw.stream = st
	nw.volume_db = -30.0
	nw.play()
	create_tween().tween_property(nw, "volume_db", 0.0, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _duck(seconds: float) -> void:
	var mi := AudioServer.get_bus_index(&"Musica")
	if mi < 0:
		return
	if _duck_tw:
		_duck_tw.kill()
	AudioServer.set_bus_volume_db(mi, MUSIC_DB + DUCK_DB)
	_duck_tw = create_tween()
	_duck_tw.tween_interval(seconds)
	_duck_tw.tween_method(func(v: float): AudioServer.set_bus_volume_db(mi, v), MUSIC_DB + DUCK_DB, MUSIC_DB, 0.6)


func _next_tick() -> void:
	_ticker.start(randf_range(0.035, 0.16))


func _on_tick() -> void:
	_play("tick", randf_range(0.85, 1.25), randf_range(-4.0, 0.0))
	_next_tick()
