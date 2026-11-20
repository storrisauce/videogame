class_name OnlineGame
extends Node
## Una partita online con un amico (D-025), sopra Realtime.
## - Chi crea la stanza ("host") riceve un codice tipo MUCA42; l'amico lo scrive ed entra ("ospite").
## - L'ospite manda "hello" (sopravvissuto e bande) finché l'host non risponde "start" con il seme della partita.
## - Le mosse viaggiano numerate: chi riceve le applica in ordine; se ne manca una la richiede ("need").
## - "ping" ogni 2 secondi; se l'altro tace per 12 secondi → opponent_lost (e opponent_back se ritorna).

signal ready_to_start(info: Dictionary)   ## {seed, host: bool, me: {...}, them: {...}}
signal move_received(a: Dictionary)
signal opponent_lost
signal opponent_back
signal opponent_left
signal failed(reason: String)

const LETTERS := "ABCDEFGHJKLMNPQRSTUVWXYZ"   # niente I e O (si confondono con 1 e 0)
const LOST_AFTER := 12.0

var rt := Realtime.new()
var is_host := false
var room := ""
var me_info := {}
var them_info := {}
var seed := 0
var started := false
var lost := false
var _out_seq := 0
var _sent: Array = []
var _in_expect := 0
var _buffer := {}
var _last_heard := 0.0
var _ping_t := 0.0
var _hello_t := 0.0


static func new_code() -> String:
	var s := ""
	for i in 4:
		s += LETTERS[randi() % LETTERS.length()]
	return s + "%02d" % (randi() % 100)


static func clean_code(t: String) -> String:
	return t.strip_edges().to_upper().replace(" ", "").replace("-", "")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(rt)
	rt.message.connect(_on_message)
	rt.failed.connect(func(r: String): failed.emit(r))
	rt.closed.connect(func():
		if started and not lost:
			lost = true
			opponent_lost.emit())


## Crea la stanza. `info` = {hero, bands, name}.
func host(code: String, info: Dictionary) -> void:
	is_host = true
	room = code
	me_info = info
	rt.join(code)


## Entra nella stanza di un amico.
func join(code: String, info: Dictionary) -> void:
	is_host = false
	room = clean_code(code)
	me_info = info
	rt.join(room)


func send_move(a: Dictionary) -> void:
	var msg := {"seq": _out_seq, "a": Protocol.encode(a)}
	_sent.append(msg)
	_out_seq += 1
	rt.send("move", msg)


func leave() -> void:
	if rt.is_joined():
		rt.send("bye", {})
	rt.leave()


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


func _process(delta: float) -> void:
	if not rt.is_joined():
		return
	_ping_t += delta
	if _ping_t >= 2.0:
		_ping_t = 0.0
		rt.send("ping", {"next": _in_expect, "sent": _out_seq})
	if not is_host and not started:
		_hello_t += delta
		if _hello_t >= 1.0:
			_hello_t = 0.0
			rt.send("hello", me_info)
	if started and not lost and _now() - _last_heard > LOST_AFTER:
		lost = true
		opponent_lost.emit()


func _on_message(ev: String, p: Dictionary) -> void:
	_last_heard = _now()
	if lost and ev != "bye":
		lost = false
		opponent_back.emit()
	match ev:
		"hello":
			if not is_host:
				return
			if not started:
				seed = randi()
				them_info = p
				started = true
				ready_to_start.emit({"seed": seed, "host": true, "me": me_info, "them": them_info})
			rt.send("start", {"seed": seed, "host_info": me_info, "guest_info": them_info})
		"start":
			if is_host or started:
				return
			seed = int(p.get("seed", 0))
			them_info = p.get("host_info", {})
			started = true
			ready_to_start.emit({"seed": seed, "host": false, "me": me_info, "them": them_info})
		"move":
			_receive(int(p.get("seq", -1)), p.get("a", {}))
		"need":
			var from := int(p.get("from", 0))
			for k in range(from, _sent.size()):
				rt.send("move", _sent[k])
		"ping":
			# l'altro ha mandato più mosse di quelle arrivate: chiedi quelle mancanti
			if int(p.get("sent", 0)) > _in_expect:
				rt.send("need", {"from": _in_expect})
		"bye":
			opponent_left.emit()


func _receive(seq: int, a: Dictionary) -> void:
	if seq < _in_expect:
		return   # già vista
	if seq > _in_expect:
		_buffer[seq] = a
		rt.send("need", {"from": _in_expect})
		return
	move_received.emit(Protocol.decode(a))
	_in_expect += 1
	while _buffer.has(_in_expect):
		var nxt: Dictionary = _buffer[_in_expect]
		_buffer.erase(_in_expect)
		move_received.emit(Protocol.decode(nxt))
		_in_expect += 1
