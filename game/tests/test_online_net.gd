extends SceneTree
## Partita intera via internet (serve data/supabase.local.json): due OnlineGame, host e ospite, giocano con l'IA
## ciascuno dal proprio telefono finto; le mosse passano davvero per Supabase Realtime. Alla fine i due Match
## devono coincidere. godot --headless --path game --script res://tests/test_online_net.gd

var db: CardDB
var info := {}
var inbox := {"h": [], "g": []}


func _initialize() -> void:
	if not Realtime.available():
		print("SALTATO: manca data/supabase.local.json")
		quit(0)
		return
	db = CardDB.load_default()
	var host := OnlineGame.new()
	var guest := OnlineGame.new()
	root.add_child(host)
	root.add_child(guest)
	host.ready_to_start.connect(func(i): info["h"] = i)
	guest.ready_to_start.connect(func(i): info["g"] = i)
	host.move_received.connect(func(a): inbox["h"].append(a))
	guest.move_received.connect(func(a): inbox["g"].append(a))
	var code := OnlineGame.new_code()
	host.host(code, {"hero": "nonna", "bands": ["porcile", "pollaio"], "name": "Gertrude"})
	await create_timer(1.0).timeout
	guest.join(code, {"hero": "gianni", "bands": ["stagno", "patate"], "name": "Gianni"})
	var t := 0
	while info.size() < 2 and t < 200:
		await create_timer(0.05).timeout
		t += 1
	if info.size() < 2:
		print("FALLITO: la partita non parte (", info.keys(), ")")
		quit(1)
		return
	print("stanza ", code, ": seme host ", info["h"]["seed"], " ospite ", info["g"]["seed"])
	var H := _make(info["h"])
	var G := _make(info["g"])
	H.start()
	G.start()
	var turns := 0
	var ok := H.first_player == 1 - G.first_player
	while H.winner < 0 and turns < 60 and ok:
		var host_turn := H.current == 0
		var me: Match = H if host_turn else G
		var og: OnlineGame = host if host_turn else guest
		var other: Match = G if host_turn else H
		var box: String = "g" if host_turn else "h"
		var sent := 0
		for n in 30:
			var a := GreedyAI.choose(me, 0)
			if a.is_empty() or not me.apply(0, a):
				break
			var mv := {"type": a["type"], "target": a.get("target")}
			for k in ["hand", "lane"]:
				if a.has(k):
					mv[k] = a[k]
			og.send_move(mv)
			sent += 1
			if me.winner >= 0:
				break
		if me.winner < 0 and me.can_attack_this_turn(0):
			for i in 4:
				if me.winner < 0 and me.attack_lane(0, i, i == 1) != "":
					og.send_move({"type": "attack", "lane": i, "crit": i == 1})
					sent += 1
		if me.winner < 0:
			me.end_turn(0)
			og.send_move({"type": "end", "sum": Protocol.checksum(me, 0)})
			sent += 1
		# l'altro telefono aspetta le mosse dalla rete e le applica
		var got := 0
		var w := 0
		while got < sent and w < 400:
			if inbox[box].is_empty():
				await create_timer(0.02).timeout
				w += 1
				continue
			var mv: Dictionary = inbox[box].pop_front()
			Protocol.apply(other, 1, mv)
			if mv["type"] == "end" and int(mv["sum"]) != Protocol.checksum(other, 1):
				ok = false
			got += 1
		if got < sent:
			print("FALLITO: arrivate %d mosse su %d" % [got, sent])
			ok = false
		if Protocol.checksum(H, 0) != Protocol.checksum(G, 1):
			ok = false
		turns += 1
	print("turni giocati: ", turns, "  vincitore host-side: ", H.winner, "  ospite-side: ", G.winner)
	print("Risultato partita via rete: ", "OK" if ok else "FALLITO")
	host.leave()
	guest.leave()
	quit(0 if ok else 1)


func _make(i: Dictionary) -> Match:
	var me: Dictionary = i["me"]
	var them: Dictionary = i["them"]
	var m := Match.new(db)
	m.setup(int(i["seed"]), [DeckFactory.build(db, me["bands"]), DeckFactory.build(db, them["bands"])],
		[DeckFactory.zones(me["bands"]), DeckFactory.zones(them["bands"])], [me["hero"], them["hero"]])
	m.mirrored = not i["host"]
	m.allow_replace = [true, true]
	for ps in m.players:
		ps.is_human = true
		ps.empty_deck_rule = "bleed"
	return m
