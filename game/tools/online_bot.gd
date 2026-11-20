extends SceneTree
## Avversario di prova per il gioco online (D-025): crea la stanza CODICE e gioca con l'IA, via internet,
## come farebbe un amico. Dal telefono: "Con un amico" → scrivi CODICE → Entra.
## godot --headless --path game --script res://tools/online_bot.gd -- PROVA1

var db: CardDB
var info := {}
var inbox: Array = []


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var code: String = args[0] if args.size() > 0 else "PROVA1"
	db = CardDB.load_default()
	var og := OnlineGame.new()
	root.add_child(og)
	og.ready_to_start.connect(func(i): info = i)
	og.move_received.connect(func(a): inbox.append(a))
	og.opponent_left.connect(func(): print("l'amico è uscito"); quit(0))
	og.host(code, {"hero": "veterinario", "bands": ["porcile", "stagno"], "name": "Bot di prova"})
	print("stanza aperta: ", code, " — aspetto che entri qualcuno")
	while info.is_empty():
		await create_timer(0.2).timeout
	print("entrato: ", info["them"])
	var me: Dictionary = info["me"]
	var them: Dictionary = info["them"]
	var m := Match.new(db)
	m.setup(int(info["seed"]), [DeckFactory.build(db, me["bands"]), DeckFactory.build(db, them["bands"])],
		[DeckFactory.zones(me["bands"]), DeckFactory.zones(them["bands"])], [me["hero"], them["hero"]])
	m.mirrored = false
	m.allow_replace = [true, true]
	for ps in m.players:
		ps.is_human = true
		ps.empty_deck_rule = "bleed"
	m.start()
	while m.winner < 0:
		if m.current == 0:
			await create_timer(2.0).timeout
			for n in 30:
				var a := GreedyAI.choose(m, 0)
				if a.is_empty() or not m.apply(0, a):
					break
				var mv := {"type": a["type"], "target": a.get("target")}
				for k in ["hand", "lane"]:
					if a.has(k):
						mv[k] = a[k]
				og.send_move(mv)
				print("gioco: ", mv)
				await create_timer(1.5).timeout
				if m.winner >= 0:
					break
			if m.winner < 0 and m.can_attack_this_turn(0):
				for i in 4:
					var crit := randf() < 0.25
					if m.winner < 0 and m.attack_lane(0, i, crit) != "":
						og.send_move({"type": "attack", "lane": i, "crit": crit})
						await create_timer(1.0).timeout
			if m.winner < 0:
				m.end_turn(0)
				og.send_move({"type": "end", "sum": Protocol.checksum(m, 0)})
				print("fine turno")
		else:
			while inbox.is_empty():
				await create_timer(0.1).timeout
			var mv: Dictionary = inbox.pop_front()
			Protocol.apply(m, 1, mv)
			print("ricevo: ", mv)
			if mv["type"] == "end" and int(mv["sum"]) != Protocol.checksum(m, 1):
				print("ATTENZIONE: checksum diverso!")
	print("partita finita, vince: ", "bot" if m.winner == 0 else "tu")
	await create_timer(3.0).timeout
	og.leave()
	quit(0)
