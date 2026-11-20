class_name GameRunner
extends RefCounted
## Gioca una partita intera IA contro IA, senza grafica. Usato da test e simulazioni.

## crit_chance: probabilità di Botta Atomica per giocatore (simula la mano di un umano; 0 = IA pura).
static func play(m: Match, crit_chance: Array = [0.0, 0.0], max_actions_per_turn: int = 30) -> Dictionary:
	m.start()
	var max_turns := m.db.rule_i("max_turns")
	while m.winner < 0 and m.turn_number <= max_turns:
		var p := m.current
		for i in max_actions_per_turn:
			var a := GreedyAI.choose(m, p)
			if a.is_empty() or not m.apply(p, a):
				break
			if m.winner >= 0:
				break
		if m.winner >= 0:
			break
		var crits: Array = []
		for i in m.players[p].lanes.size():
			crits.append(m.rng.randf() < float(crit_chance[p]))
		m.combat(p, crits)
		if m.winner >= 0:
			break
		m.end_turn(p)
	return {"winner": m.winner, "turns": m.turn_number, "hp": [m.players[0].hp, m.players[1].hp]}
