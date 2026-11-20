class_name Match
extends RefCounted
## Stato e regole di una partita. Nessun nodo: si usa da terminale, dai test e dall'IA.
## Regole: docs/features/partita/design.md. Ogni azione passa da apply() e si può clonare la partita.

signal event(kind: String, data: Dictionary)

var db: CardDB
var rng := RandomNumberGenerator.new()
var players: Array[PlayerState] = []
var first_player := 0
var current := 0
var turn_number := 0
var round_caos := 0
var winner := -1
var allow_replace := [true, true]   ## l'IA del genere non sostituisce mai le creature


func _init(card_db: CardDB = null) -> void:
	db = card_db


# --- Preparazione -----------------------------------------------------------

## deck_ids: Array di id (o di [id, livello]); zones: 4 bande, una per recinto.
func setup(seed_value: int, decks: Array, zones: Array, heroes: Array, hero_levels: Array = [1, 1]) -> void:
	rng.seed = seed_value
	players.clear()
	for p in 2:
		var ps := PlayerState.new()
		ps.hero = db.heroes[heroes[p]]
		ps.hero_level = hero_levels[p]
		ps.max_hp = db.rule_i("hero_hp_base") + db.rule_i("hero_hp_per_level") * ps.hero_level
		ps.hp = ps.max_hp
		for entry in decks[p]:
			var id: String = entry if entry is String else entry[0]
			var lvl: int = 1 if entry is String else int(entry[1])
			ps.deck.append(CardInst.new(db.card(id), lvl, p))
		for z: String in zones[p]:
			ps.lanes.append(Lane.new(z))
		players.append(ps)


func start() -> void:
	first_player = rng.randi_range(0, 1)
	round_caos = db.rule_i("caos_iniziale")
	for p in 2:
		_shuffle(players[p].deck)
		players[p].caos = round_caos
		for i in db.rule_i("starting_hand"):
			draw(p)
	current = first_player
	turn_number = 1
	begin_turn(current)


func clone() -> Match:
	var m := Match.new(db)
	m.rng.seed = rng.seed
	m.rng.state = rng.state
	for p in players:
		m.players.append(p.clone())
	m.first_player = first_player
	m.current = current
	m.turn_number = turn_number
	m.round_caos = round_caos
	m.winner = winner
	m.allow_replace = allow_replace.duplicate()
	m.resurrected = resurrected.duplicate()
	return m


# --- Turno ------------------------------------------------------------------

func begin_turn(p: int) -> void:
	var ps := players[p]
	for lane in ps.lanes:
		for c: CardInst in [lane.creature, lane.structure]:
			if c:
				c.scossa = false
				c.protected = false
				c.helpless = false
				c.cant_attack = false
				c.fresh = false
	# Effetti di inizio turno delle strutture, dal recinto 1 al 4.
	for i in ps.lanes.size():
		var s := ps.lanes[i].structure
		if s and s.family() == "StartTurnHealCreature" and ps.lanes[i].creature:
			heal(ps.lanes[i].creature, s.val())
	if ps.deck.is_empty():
		_empty_deck(p)
	else:
		draw(p)
	emit_signal("event", "turn_start", {"player": p, "turn": turn_number})


func can_attack_this_turn(p: int) -> bool:
	return not (p == first_player and players[p].turns_taken == 0)


## crits: un bool per recinto (Botta Atomica sì/no), deciso dal mirino del giocatore umano.
func combat(p: int, crits: Array = []) -> void:
	if winner >= 0 or not can_attack_this_turn(p):
		return
	for i in players[p].lanes.size():
		if winner >= 0:
			return
		attack_lane(p, i, crits[i] if i < crits.size() else false)


## La creatura del recinto i attacca. Non controlla il primo turno (lo fa combat()).
## Restituisce "creatura", "pazienza" o "" se non c'è stato attacco.
func attack_lane(p: int, i: int, crit: bool) -> String:
	if winner >= 0:
		return ""
	var o := 1 - p
	var att := players[p].lanes[i].creature
	if att == null or att.cant_attack:
		return ""
	var atk := atk_of(att)
	if atk <= 0:
		return ""
	var target := players[o].lanes[i].creature
	if target and not target.helpless:
		if target.protected:
			return ""
		var dmg := int(atk + atk * db.advantage(att.band(), target.band()))
		dmg = maxi(dmg, 0)
		if crit:
			dmg = int(dmg * float(db.rule("molt_botta")))
		emit_signal("event", "attack", {"player": p, "lane": i, "damage": dmg, "crit": crit, "card": att.id(), "target": target.id()})
		take_damage(target, dmg)
		return "creatura"
	var dmg := atk - players[p].atk_penalty
	if crit:
		dmg = int(dmg * float(db.rule("molt_botta")))
	emit_signal("event", "attack_hero", {"player": p, "lane": i, "damage": dmg, "crit": crit, "card": att.id()})
	damage_hero(o, dmg)
	return "pazienza"


## Il mirino compare per questo attacco? (no se non attacca o se il bersaglio è protetto)
func attack_needs_dial(p: int, i: int) -> bool:
	var att := players[p].lanes[i].creature
	if att == null or att.cant_attack or atk_of(att) <= 0:
		return false
	var target := players[1 - p].lanes[i].creature
	return not (target and not target.helpless and target.protected)


func lane_undefended(p: int, i: int) -> bool:
	var target := players[1 - p].lanes[i].creature
	return target == null or target.helpless


func end_turn(p: int) -> void:
	var ps := players[p]
	if p == first_player:
		round_caos = mini(round_caos + 1, db.rule_i("caos_max"))
	ps.caos = maxi(round_caos + ps.bonus_next, 0)
	ps.bonus_next = 0
	ps.discounts.clear()
	ps.atk_penalty = 0
	if ps.cooldown > 0:
		ps.cooldown -= 1
	ps.turns_taken += 1
	current = 1 - p
	turn_number += 1
	begin_turn(current)


func _empty_deck(p: int) -> void:
	var ps := players[p]
	if ps.empty_deck_rule == "reshuffle":
		while not ps.hand.is_empty():
			ps.discard.append(ps.hand.pop_back())
		for c in ps.discard:
			ps.deck.append(c.fresh_copy())
		ps.discard.clear()
		_shuffle(ps.deck)
		for i in db.rule_i("starting_hand"):
			draw(p)
	else:
		damage_hero(p, ps.hero_level)
	emit_signal("event", "empty_deck", {"player": p, "rule": ps.empty_deck_rule})


# --- Carte: pescare, giocare, scuotere -------------------------------------

func draw(p: int) -> bool:
	var ps := players[p]
	if ps.deck.is_empty():
		return false
	var c: CardInst = ps.deck.pop_back()
	if ps.hand.size() < db.rule_i("max_hand"):
		ps.hand.append(c)
	else:
		ps.discard.append(c)   # mano piena: la pescata va persa
	return true


func cost_of(p: int, c: CardInst) -> int:
	var cost := c.cost()
	if c.type() == "creature":
		cost -= int(players[p].discounts.get(c.band(), 0))
	return maxi(cost, 0)


func has_zone(p: int, band: String) -> bool:
	if band == "cratere":
		return true
	for l in players[p].lanes:
		if l.zone == band:
			return true
	return false


## Può giocare la carta c nel recinto lane (-1 per gli eventi)?
func can_play(p: int, c: CardInst, lane: int) -> bool:
	if winner >= 0 or cost_of(p, c) > players[p].caos:
		return false
	if c.type() == "event":
		return has_zone(p, c.band()) and Abilities.can_resolve(self, p, c, -1)
	if lane < 0 or lane >= players[p].lanes.size():
		return false
	var l := players[p].lanes[lane]
	if l.disabled:
		return false
	if c.band() != "cratere" and c.band() != l.zone:
		return false
	var occupied := l.creature if c.type() == "creature" else l.structure
	if occupied and not allow_replace[p]:
		return false
	return true


func play_card(p: int, hand_index: int, lane: int, target: Variant = null) -> bool:
	var ps := players[p]
	if hand_index < 0 or hand_index >= ps.hand.size():
		return false
	var c := ps.hand[hand_index]
	if not can_play(p, c, lane):
		return false
	if c.type() == "event" and not Abilities.target_ok(self, p, c, -1, target):
		return false
	ps.caos -= cost_of(p, c)
	ps.hand.remove_at(hand_index)
	if c.type() == "event":
		Abilities.resolve(self, p, c, -1, target)
		ps.discard.append(c.fresh_copy())
	else:
		var l := ps.lanes[lane]
		if c.type() == "creature":
			if l.creature:
				ps.discard.append(l.creature.fresh_copy())
			c.fresh = true
			l.creature = c
		else:
			if l.structure:
				ps.discard.append(l.structure.fresh_copy())
			l.structure = c
	emit_signal("event", "play", {"player": p, "card": c.id(), "lane": lane})
	return true


func can_scuoti(p: int, lane: int) -> bool:
	if winner >= 0 or lane < 0 or lane >= players[p].lanes.size():
		return false
	var c := players[p].lanes[lane].creature
	if c == null or c.family() == "" or c.scossa:
		return false
	if c.scuoti_cost() > players[p].caos:
		return false
	return Abilities.can_resolve(self, p, c, lane)


func scuoti(p: int, lane: int, target: Variant = null) -> bool:
	if not can_scuoti(p, lane):
		return false
	var c := players[p].lanes[lane].creature
	if not Abilities.target_ok(self, p, c, lane, target):
		return false
	players[p].caos -= c.scuoti_cost()
	c.scossa = true
	Abilities.resolve(self, p, c, lane, target)
	emit_signal("event", "scuoti", {"player": p, "lane": lane, "card": c.id()})
	return true


func can_use_hero(p: int) -> bool:
	return winner < 0 and players[p].cooldown <= 0 and Abilities.can_resolve_hero(self, p)


func use_hero(p: int, target: Variant = null) -> bool:
	if not can_use_hero(p) or not Abilities.hero_target_ok(self, p, target):
		return false
	Abilities.resolve_hero(self, p, target)
	players[p].cooldown = int(players[p].hero["cooldown"])
	emit_signal("event", "hero", {"player": p})
	return true


# --- Azioni generiche (usate da IA e interfaccia) --------------------------

func legal_actions(p: int) -> Array:
	var out: Array = []
	if winner >= 0:
		return out
	var ps := players[p]
	for h in ps.hand.size():
		var c := ps.hand[h]
		if c.type() == "event":
			if can_play(p, c, -1):
				for t in Abilities.targets(self, p, c, -1):
					out.append({"type": "play", "hand": h, "lane": -1, "target": t})
		else:
			for l in ps.lanes.size():
				if can_play(p, c, l):
					out.append({"type": "play", "hand": h, "lane": l, "target": null})
	for l in ps.lanes.size():
		if can_scuoti(p, l):
			for t in Abilities.targets(self, p, ps.lanes[l].creature, l):
				out.append({"type": "scuoti", "lane": l, "target": t})
	if can_use_hero(p):
		for t in Abilities.hero_targets(self, p):
			out.append({"type": "hero", "target": t})
	return out


func apply(p: int, a: Dictionary) -> bool:
	match a["type"]:
		"play":
			return play_card(p, a["hand"], a["lane"], a["target"])
		"scuoti":
			return scuoti(p, a["lane"], a["target"])
		"hero":
			return use_hero(p, a["target"])
	return false


# --- Rialzarsi (regola 13) -------------------------------------------------

var resurrected := [false, false]


## Chi ha appena perso può rialzarsi una volta per partita (il costo in scatolette lo paga il profilo).
func can_resurrect(p: int) -> bool:
	return winner == 1 - p and not resurrected[p]


func resurrect(p: int) -> bool:
	if not can_resurrect(p):
		return false
	var ps := players[p]
	resurrected[p] = true
	winner = -1
	ps.hp = ps.max_hp
	while not ps.hand.is_empty():
		ps.deck.append(ps.hand.pop_back().fresh_copy())
	for c in ps.discard:
		ps.deck.append(c.fresh_copy())
	ps.discard.clear()
	_shuffle(ps.deck)
	for i in db.rule_i("starting_hand"):
		draw(p)
	emit_signal("event", "resurrect", {"player": p})
	return true


# --- Statistiche, danni, cure ----------------------------------------------

func lane_of(c: CardInst) -> int:
	var ps := players[c.owner]
	for i in ps.lanes.size():
		if ps.lanes[i].creature == c or ps.lanes[i].structure == c:
			return i
	return -1


func _aura(c: CardInst, family: String) -> int:
	var i := lane_of(c)
	if i < 0:
		return 0
	var s := players[c.owner].lanes[i].structure
	if s and s.family() == family:
		return s.val()
	return 0


func atk_of(c: CardInst) -> int:
	return maxi(c.base_atk() + c.atk_mod + _aura(c, "ATKBonusBuilding"), 0)


func def_of(c: CardInst) -> int:
	return c.base_def() + c.def_mod + _aura(c, "DEFBonusBuilding")


func health_of(c: CardInst) -> int:
	return maxi(def_of(c) - c.damage, 0)


func take_damage(c: CardInst, amount: int) -> void:
	var dmg := maxi(int((amount - c.dmg_reduction) * c.dmg_factor), 0)
	c.damage += dmg
	if health_of(c) <= 0:
		kill(c)


func heal(c: CardInst, amount: int) -> void:
	c.damage = maxi(c.damage - amount, 0)


func kill(c: CardInst) -> void:
	var p := c.owner
	var i := lane_of(c)
	if i < 0:
		return
	var l := players[p].lanes[i]
	if l.creature != c:
		return
	l.creature = null
	players[p].discard.append(c.fresh_copy())
	emit_signal("event", "death", {"player": p, "lane": i, "card": c.id()})
	if l.structure and l.structure.family() == "DamageHeroOnDeath":
		damage_hero(1 - p, l.structure.val())


func damage_hero(p: int, amount: int) -> void:
	if amount <= 0 or winner >= 0:
		return
	var ps := players[p]
	ps.hp = mini(ps.hp - amount, ps.max_hp)
	if ps.hp <= 0:
		winner = 1 - p
		emit_signal("event", "win", {"player": winner})


func heal_hero(p: int, amount: int) -> void:
	players[p].hp = mini(players[p].hp + amount, players[p].max_hp)


func _shuffle(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = arr[i]
		arr[i] = arr[j]
		arr[j] = t
