class_name Abilities
extends RefCounted
## Famiglie di abilità (nomi come in docs/catalogo-abilita-card-wars.md).
## Ogni carta nel JSON dice solo "famiglia + valori"; qui sta cosa fa ogni famiglia.
## Bersagli: null = nessun bersaglio; {"p": giocatore, "lane": recinto}; {"band": banda}.


static func _opposite(m: Match, p: int, lane: int) -> CardInst:
	if lane < 0:
		return null
	return m.players[1 - p].lanes[lane].creature


static func _adjacent(m: Match, p: int, lane: int) -> Array[CardInst]:
	var out: Array[CardInst] = []
	for i in [lane - 1, lane + 1]:
		if i >= 0 and i < m.players[p].lanes.size() and m.players[p].lanes[i].creature:
			out.append(m.players[p].lanes[i].creature)
	return out


static func _creatures(m: Match, p: int) -> Array[CardInst]:
	var out: Array[CardInst] = []
	for l in m.players[p].lanes:
		if l.creature:
			out.append(l.creature)
	return out


static func _enemy_targets(m: Match, p: int) -> Array:
	var out: Array = []
	for i in m.players[1 - p].lanes.size():
		if m.players[1 - p].lanes[i].creature:
			out.append({"p": 1 - p, "lane": i})
	return out


static func _target_card(m: Match, t: Variant) -> CardInst:
	if t is Dictionary and t.has("lane"):
		return m.players[t["p"]].lanes[t["lane"]].creature
	return null


# --- Carte (creature con Scuotere ed eventi) -------------------------------

static func targets(m: Match, p: int, c: CardInst, lane: int) -> Array:
	var me := m.players[p]
	match c.family():
		"SwapATKDEFOpponent":
			return _enemy_targets(m, p)
		"LowerATKOpponent", "ReturnOppnentToHand", "DamageOpponent":
			return [null] if _opposite(m, p, lane) else []
		"AdjacentDEFBonus", "AdjacentATKBonus":
			return [null] if not _adjacent(m, p, lane).is_empty() else []
		"HealAdjacent":
			for a in _adjacent(m, p, lane):
				if a.damage > 0:
					return [null]
			return []
		"HealSelf":
			return [null] if c.damage > 0 else []
		"DamageAll":
			return [null] if not _creatures(m, 1 - p).is_empty() else []
		"DamageEveryone":
			return [null] if not (_creatures(m, 0).is_empty() and _creatures(m, 1).is_empty()) else []
		"DrawCards", "DrawCardsSpell":
			return [null] if not me.deck.is_empty() else []
		"SacrificeForMP":
			return [null] if lane >= 0 and me.lanes[lane].structure else []
		"DEFBonus", "ATKBonus", "LandscapeDEFBonus", "DamageHero", "ReduceActionPoints":
			return [null]
	push_error("Famiglia senza regole di bersaglio: %s" % c.family())
	return []


static func can_resolve(m: Match, p: int, c: CardInst, lane: int) -> bool:
	return not targets(m, p, c, lane).is_empty()


static func target_ok(m: Match, p: int, c: CardInst, lane: int, target: Variant) -> bool:
	return targets(m, p, c, lane).has(target)


static func resolve(m: Match, p: int, c: CardInst, lane: int, target: Variant) -> void:
	var v := c.val("v1")
	var me := m.players[p]
	match c.family():
		"DEFBonus":
			c.def_mod += v
		"ATKBonus":
			c.atk_mod += v
		"AdjacentDEFBonus":
			for a in _adjacent(m, p, lane):
				a.def_mod += v
		"AdjacentATKBonus":
			for a in _adjacent(m, p, lane):
				a.atk_mod += v
		"HealSelf":
			m.heal(c, v)
		"HealAdjacent":
			for a in _adjacent(m, p, lane):
				m.heal(a, v)
		"LandscapeDEFBonus":
			var n := 0
			for l in me.lanes:
				if l.zone == c.band():
					n += 1
			c.def_mod += v * n
		"DamageHero":
			m.damage_hero(1 - p, v)
		"DamageOpponent":
			m.take_damage(_opposite(m, p, lane), v)
		"LowerATKOpponent":
			_opposite(m, p, lane).atk_mod -= v
		"ReturnOppnentToHand":
			var o := _opposite(m, p, lane)
			var op := m.players[1 - p]
			op.lanes[lane].creature = null
			if op.hand.size() < m.db.rule_i("max_hand"):
				op.hand.append(o.fresh_copy())
			else:
				op.discard.append(o.fresh_copy())
		"DamageAll":
			for e in _creatures(m, 1 - p):
				m.take_damage(e, v)
		"DamageEveryone":
			for e in _creatures(m, 1 - p) + _creatures(m, p):
				m.take_damage(e, v)
		"SwapATKDEFOpponent":
			var t := _target_card(m, target)
			var a := m.atk_of(t)
			var d := m.def_of(t)
			t.atk_mod += d - a
			t.def_mod += a - d
			if m.health_of(t) <= 0:
				m.kill(t)
		"DrawCards", "DrawCardsSpell":
			for i in v:
				m.draw(p)
		"SacrificeForMP":
			me.discard.append(me.lanes[lane].structure.fresh_copy())
			me.lanes[lane].structure = null
			me.caos += v
		"ReduceActionPoints":
			m.players[1 - p].bonus_next -= v


# --- Abilità dei sopravvissuti ---------------------------------------------

static func hero_targets(m: Match, p: int) -> Array:
	var h := m.players[p].hero
	match String(h["family"]):
		"AttackCreature":
			return _enemy_targets(m, p)
		"GainActionPointsLeader":
			return [null]
		"DEFBonusAllCreaturesLeader":
			return [null] if not _creatures(m, p).is_empty() else []
		"HealAllCreaturesLeader":
			for c in _creatures(m, p):
				if c.damage > 0:
					return [null]
			return []
		"ReduceFactionCreatureCostLeader":
			var out: Array = []
			for l in m.players[p].lanes:
				var t := {"band": l.zone}
				if not out.has(t):
					out.append(t)
			return out
		"DrawCardsLeader":
			return [null] if not m.players[p].deck.is_empty() else []
	push_error("Abilità di sopravvissuto sconosciuta: %s" % h["family"])
	return []


static func can_resolve_hero(m: Match, p: int) -> bool:
	return not hero_targets(m, p).is_empty()


static func hero_target_ok(m: Match, p: int, target: Variant) -> bool:
	return hero_targets(m, p).has(target)


static func resolve_hero(m: Match, p: int, target: Variant) -> void:
	var h := m.players[p].hero
	var v := int(h["v1"])
	match String(h["family"]):
		"AttackCreature":
			m.take_damage(_target_card(m, target), v)
		"GainActionPointsLeader":
			m.players[p].caos += v
		"DEFBonusAllCreaturesLeader":
			for c in _creatures(m, p):
				c.def_mod += v
		"HealAllCreaturesLeader":
			for c in _creatures(m, p):
				m.heal(c, v)
		"ReduceFactionCreatureCostLeader":
			var b: String = target["band"]
			m.players[p].discounts[b] = int(m.players[p].discounts.get(b, 0)) + v
		"DrawCardsLeader":
			for i in v:
				m.draw(p)
