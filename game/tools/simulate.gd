extends SceneTree
## Partite IA contro IA per tarare i numeri.
## godot --headless --path game --script res://tools/simulate.gd -- [partite] [seme] [prob_botta]
## Mazzo di prova: 2 bande (2 recinti ciascuna), le loro carte ×3, più le carte del Cratere ×1.

const BANDS := ["porcile", "pollaio", "stagno", "patate", "discarica"]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var games := int(args[0]) if args.size() > 0 else 100
	var seed_value := int(args[1]) if args.size() > 1 else 1
	var crit := float(args[2]) if args.size() > 2 else 0.0
	var db := CardDB.load_default()
	if args.size() > 3:
		_apply_overrides(db, args[3])
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var hero_ids: Array = db.heroes.keys()

	var band_games := {}
	var band_wins := {}
	var hero_games := {}
	var hero_wins := {}
	var first_wins := 0
	var total_turns := 0
	var unfinished := 0
	var t0 := Time.get_ticks_msec()

	for g in games:
		var picks := []
		var decks := []
		var zones := []
		var heroes := []
		for p in 2:
			var pair := _two_bands(rng)
			picks.append(pair)
			decks.append(_deck(db, pair))
			zones.append([pair[0], pair[0], pair[1], pair[1]])
			heroes.append(hero_ids[rng.randi_range(0, hero_ids.size() - 1)])
		var m := Match.new(db)
		m.setup(rng.randi(), decks, zones, heroes)
		m.allow_replace = [false, false]
		for p in 2:
			m.players[p].empty_deck_rule = "reshuffle"
		var r := GameRunner.play(m, [crit, crit])
		total_turns += int(r["turns"])
		if r["winner"] < 0:
			unfinished += 1
			continue
		var w: int = r["winner"]
		if w == m.first_player:
			first_wins += 1
		for p in 2:
			for b: String in picks[p]:
				band_games[b] = int(band_games.get(b, 0)) + 1
				if p == w:
					band_wins[b] = int(band_wins.get(b, 0)) + 1
			hero_games[heroes[p]] = int(hero_games.get(heroes[p], 0)) + 1
			if p == w:
				hero_wins[heroes[p]] = int(hero_wins.get(heroes[p], 0)) + 1

	var finished := games - unfinished
	print("Partite: %d (non finite: %d) in %.1f s" % [games, unfinished, (Time.get_ticks_msec() - t0) / 1000.0])
	print("Turni medi (somma dei due giocatori): %.1f" % (float(total_turns) / games))
	print("Vittorie di chi inizia: %.0f%%" % (100.0 * first_wins / maxi(finished, 1)))
	print("Bande (vittorie %):")
	for b in BANDS:
		print("  %-10s %5.1f%%  su %d" % [b, 100.0 * int(band_wins.get(b, 0)) / maxi(int(band_games.get(b, 0)), 1), int(band_games.get(b, 0))])
	print("Sopravvissuti (vittorie %):")
	for h in hero_ids:
		print("  %-12s %5.1f%%  su %d" % [h, 100.0 * int(hero_wins.get(h, 0)) / maxi(int(hero_games.get(h, 0)), 1), int(hero_games.get(h, 0))])
	quit(0)


## Prove di taratura senza toccare i JSON. Formato: "chiave=valore;chiave=valore".
## Chiavi: regola (caos_iniziale), hero.<id>.<campo> (hero.nonna.v1), card.<id>.<campo> (card.ratto_accumulatore.atk)
## o card.<id>.ability.<campo> (card.capra_baratto.ability.v1).
func _apply_overrides(db: CardDB, spec: String) -> void:
	for pair in spec.split(";", false):
		var kv := pair.split("=")
		var path := kv[0].strip_edges().split(".")
		var value: Variant = float(kv[1]) if kv[1].is_valid_float() else kv[1]
		var target: Dictionary
		if path[0] == "hero":
			target = db.heroes[path[1]]
			path = path.slice(2)
		elif path[0] == "card":
			target = db.cards[path[1]]
			path = path.slice(2)
		else:
			target = db.rules
		for i in path.size() - 1:
			target = target[path[i]]
		target[path[-1]] = value
	print("Varianti: %s" % spec)


func _two_bands(rng: RandomNumberGenerator) -> Array:
	var a: String = BANDS[rng.randi_range(0, BANDS.size() - 1)]
	var b: String = a
	while b == a:
		b = BANDS[rng.randi_range(0, BANDS.size() - 1)]
	return [a, b]


func _deck(db: CardDB, pair: Array) -> Array:
	var out := []
	for id: String in db.cards:
		var c: Dictionary = db.cards[id]
		if c["band"] in pair:
			for i in 3:
				out.append(id)
		elif c["band"] == "cratere":
			out.append(id)
	return out
