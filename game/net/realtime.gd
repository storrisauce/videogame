class_name Realtime
extends Node
## Collegamento minimo a Supabase Realtime (protocollo Phoenix su WebSocket), solo "broadcast":
## i due telefoni entrano nello stesso canale (il codice della stanza) e si mandano messaggi JSON.
## Nessuna tabella nel database: basta URL e chiave pubblica (anon/publishable) in data/supabase.local.json.
## MAI la chiave service_role nel gioco.

signal joined
signal message(event: String, payload: Dictionary)
signal failed(reason: String)
signal closed

const CONFIG_PATH := "res://data/supabase.local.json"
const HEARTBEAT := 25.0

var ws := WebSocketPeer.new()
var topic := ""
var _ref := 0
var _join_ref := ""
var _state := "idle"   # idle, connecting, joining, joined, closed
var _hb := 0.0
var _outbox: Array = []


static func config() -> Dictionary:
	if not FileAccess.file_exists(CONFIG_PATH):
		return {}
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	return d if d is Dictionary else {}


static func available() -> bool:
	var c := config()
	return c.get("url", "") != "" and c.get("anon_key", "") != ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


## Entra nel canale `room` (es. "MUCA42").
func join(room: String) -> void:
	var c := config()
	if c.is_empty():
		failed.emit("manca la configurazione di Supabase")
		return
	var host := String(c["url"]).replace("https://", "wss://").replace("http://", "ws://")
	var url := "%s/realtime/v1/websocket?apikey=%s&vsn=1.0.0" % [host, c["anon_key"]]
	topic = "realtime:fattoria-" + room
	var err := ws.connect_to_url(url)
	if err != OK:
		failed.emit("connessione non riuscita (%d)" % err)
		return
	_state = "connecting"


func send(event: String, payload: Dictionary) -> void:
	var msg := {"topic": topic, "event": "broadcast", "ref": _next_ref(), "join_ref": _join_ref,
		"payload": {"type": "broadcast", "event": event, "payload": payload}}
	if _state == "joined":
		ws.send_text(JSON.stringify(msg))
	else:
		_outbox.append(msg)


func leave() -> void:
	if _state in ["joined", "joining", "connecting"]:
		ws.close()
	_state = "closed"


func is_joined() -> bool:
	return _state == "joined"


func _next_ref() -> String:
	_ref += 1
	return str(_ref)


func _process(delta: float) -> void:
	if _state in ["idle", "closed"]:
		return
	ws.poll()
	var st := ws.get_ready_state()
	if st == WebSocketPeer.STATE_OPEN:
		if _state == "connecting":
			_join_ref = _next_ref()
			var join := {"topic": topic, "event": "phx_join", "ref": _join_ref, "join_ref": _join_ref,
				"payload": {"config": {"broadcast": {"self": false, "ack": false}, "presence": {"key": ""}, "private": false}}}
			ws.send_text(JSON.stringify(join))
			_state = "joining"
		_hb += delta
		if _hb >= HEARTBEAT:
			_hb = 0.0
			ws.send_text(JSON.stringify({"topic": "phoenix", "event": "heartbeat", "payload": {}, "ref": _next_ref()}))
		while ws.get_available_packet_count() > 0:
			_on_text(ws.get_packet().get_string_from_utf8())
	elif st == WebSocketPeer.STATE_CLOSED:
		var was := _state
		_state = "closed"
		if was == "connecting":
			failed.emit("server non raggiungibile")
		else:
			closed.emit()


func _on_text(t: String) -> void:
	var d: Variant = JSON.parse_string(t)
	if not d is Dictionary:
		return
	var ev: String = d.get("event", "")
	var pl: Dictionary = d.get("payload", {}) if d.get("payload") is Dictionary else {}
	match ev:
		"phx_reply":
			if d.get("ref", "") == _join_ref and _state == "joining":
				if pl.get("status", "") == "ok":
					_state = "joined"
					for m in _outbox:
						m["join_ref"] = _join_ref
						ws.send_text(JSON.stringify(m))
					_outbox.clear()
					joined.emit()
				else:
					failed.emit("ingresso rifiutato: %s" % [pl.get("response", pl)])
		"broadcast":
			var inner: Dictionary = pl.get("payload", {}) if pl.get("payload") is Dictionary else {}
			message.emit(String(pl.get("event", "")), inner)
		"phx_error", "phx_close":
			closed.emit()
