extends SceneTree
## Prova di rete (serve internet e data/supabase.local.json): due client entrano nella stessa stanza
## e si mandano un messaggio a testa. godot --headless --path game --script res://tests/test_realtime.gd

var got := {}

func _initialize() -> void:
	if not Realtime.available():
		print("SALTATO: manca data/supabase.local.json")
		quit(0)
		return
	var room := "TEST%d" % (randi() % 100000)
	var a := Realtime.new()
	var b := Realtime.new()
	root.add_child(a)
	root.add_child(b)
	a.failed.connect(func(r): print("A errore: ", r))
	b.failed.connect(func(r): print("B errore: ", r))
	a.message.connect(func(ev, p): got["a"] = [ev, p])
	b.message.connect(func(ev, p): got["b"] = [ev, p])
	a.join(room)
	b.join(room)
	var t := 0.0
	while t < 10.0 and not (a.is_joined() and b.is_joined()):
		await process_frame
		t += get_root().get_process_delta_time() if false else 0.016
		await create_timer(0.05).timeout
	print("entrati: A=", a.is_joined(), " B=", b.is_joined())
	await create_timer(0.5).timeout
	a.send("ciao", {"da": "A", "n": 1})
	b.send("ciao", {"da": "B", "n": 2})
	var w := 0
	while w < 100 and got.size() < 2:
		await create_timer(0.05).timeout
		w += 1
	print("A ha ricevuto: ", got.get("a"), "  B ha ricevuto: ", got.get("b"))
	var ok: bool = got.has("a") and got.has("b") and got["a"][1].get("da") == "B" and got["b"][1].get("da") == "A"
	print("Risultato rete: ", "OK" if ok else "FALLITO")
	a.leave()
	b.leave()
	quit(0 if ok else 1)
