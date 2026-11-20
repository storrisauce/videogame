extends SceneTree
## Partita online senza rete (D-025): due Match, uno per telefono (l'ospite "a specchio"), si scambiano le mosse
## passando per il JSON come in rete. Devono restare identici fino alla fine, in tante partite.
## godot --headless --path game --script res://tests/test_online.gd   (uscita 1 se qualcosa non torna)

var passed := 0
var failed := 0


func check(ok: bool, label: String) -> void:
	if ok:
		passed += 1
	else:
		failed += 1
		push_error("FAIL " + label)


func _initialize() -> void:
	var db := CardDB.load_default()
	var heroes: Array = db.heroes.keys()
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	for game in 40:
		var seed := rng.randi()
		var bands_h := DeckFactory.random_pair(rng)
		var bands_g := DeckFactory.random_pair(rng)
		var hero_h: String = heroes[rng.randi_range(0, heroes.size() - 1)]
		var hero_g: String = heroes[rng.randi_range(0, heroes.size() - 1)]
		var H := _make(db, seed, bands_h, bands_g, hero_h, hero_g, false)
		var G := _make(db, seed, bands_g, bands_h, hero_g, hero_h, true)
		H.start()
		G.start()
		var same := H.first_player == 1 - G.first_player
		for k in 2:
			same = same and _ids(H.players[k].hand) == _ids(G.players[1 - k].hand)
		check(same, "partita %d: stessa mano iniziale e stesso primo turno" % game)
		var turns := 0
		var in_sync := true
		while H.winner < 0 and turns < 120 and in_sync:
			var host_turn := H.current == 0
			var me: Match = H if host_turn else G
			var other: Match = G if host_turn else H
			# mosse del turno: scelte dall'IA dal punto di vista di chi gioca (sempre giocatore 0 sul suo telefono)
			var moves := []
			for n in 30:
				var a := GreedyAI.choose(me, 0)
				if a.is_empty() or not me.apply(0, a):
					break
				var m := {"type": a["type"], "target": a.get("target")}
				if a.has("hand"):
					m["hand"] = a["hand"]
				if a.has("lane"):
					m["lane"] = a["lane"]
				moves.append(m)
				if me.winner >= 0:
					break
			if me.winner < 0 and me.can_attack_this_turn(0):
				for i in 4:
					if me.winner >= 0:
						break
					var crit := rng.randf() < 0.25
					if me.attack_lane(0, i, crit) != "":
						moves.append({"type": "attack", "lane": i, "crit": crit})
			if me.winner < 0:
				me.end_turn(0)
				moves.append({"type": "end", "sum": Protocol.checksum(me, 0)})
			# in rete: JSON e ritorno, poi l'altro telefono la applica al giocatore 1
			for mv in moves:
				var wire: Dictionary = JSON.parse_string(JSON.stringify(Protocol.encode(mv)))
				var local := Protocol.decode(wire)
				if not Protocol.apply(other, 1, local):
					in_sync = false
				if local["type"] == "end" and int(local["sum"]) != Protocol.checksum(other, 1):
					in_sync = false
			if Protocol.checksum(H, 0) != Protocol.checksum(G, 1):
				in_sync = false
			turns += 1
		check(in_sync, "partita %d: i due telefoni restano uguali fino alla fine (%d turni)" % [game, turns])
		check(H.winner < 0 or (H.winner == 0) == (G.winner == 1), "partita %d: stesso vincitore" % game)
	print("Risultati online: %d ok, %d falliti" % [passed, failed])
	quit(1 if failed > 0 else 0)


func _make(db: CardDB, seed: int, mine: Array, theirs: Array, hero_me: String, hero_them: String, mirrored: bool) -> Match:
	var m := Match.new(db)
	m.setup(seed, [DeckFactory.build(db, mine), DeckFactory.build(db, theirs)],
		[DeckFactory.zones(mine), DeckFactory.zones(theirs)], [hero_me, hero_them])
	m.mirrored = mirrored
	m.allow_replace = [true, true]
	for ps in m.players:
		ps.is_human = true
		ps.empty_deck_rule = "bleed"
	return m


func _ids(arr: Array) -> Array:
	var out := []
	for c in arr:
		out.append(c.id())
	return out
