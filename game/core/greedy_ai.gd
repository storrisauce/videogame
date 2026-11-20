class_name GreedyAI
extends RefCounted
## IA del genere (analisi §11): prova ogni mossa, valuta il tavolo e sceglie la migliore.
## Gioca solo in recinti vuoti (non sostituisce) e passa quando nessuna mossa è almeno pari.


static func lane_score(m: Match, p: int, i: int) -> int:
	var mine := m.players[p].lanes[i].creature
	var enemy := m.players[1 - p].lanes[i].creature
	if mine:
		if enemy:
			return m.atk_of(mine) + maxi(0, m.health_of(mine) - m.atk_of(enemy))
		return m.atk_of(mine) + m.health_of(mine)
	if enemy:
		return -m.atk_of(enemy)
	return 0


## Pazienza "al sicuro": tolta l'ATK delle creature nemiche che non hanno nessuno davanti.
static func health_score(m: Match, p: int) -> int:
	var threat := 0
	for i in m.players[p].lanes.size():
		var enemy := m.players[1 - p].lanes[i].creature
		if enemy and m.players[p].lanes[i].creature == null:
			threat += m.atk_of(enemy)
	var hp := m.players[p].hp
	return hp if threat <= 0 else maxi(0, hp - threat)


static func side_score(m: Match, p: int) -> int:
	var s := 0
	for i in m.players[p].lanes.size():
		s += lane_score(m, p, i)
	s += health_score(m, p)
	s += m.players[p].caos * 1
	s += m.players[p].hand.size() * 3
	return s


static func board_score(m: Match, p: int) -> int:
	if m.winner == p:
		return 100000
	if m.winner == 1 - p:
		return -100000
	return side_score(m, p) - side_score(m, 1 - p)


## Restituisce la mossa migliore, o {} per passare.
static func choose(m: Match, p: int) -> Dictionary:
	var base := board_score(m, p)
	var best: Dictionary = {}
	var best_score := base
	for a: Dictionary in m.legal_actions(p):
		var sim := m.clone()
		if not sim.apply(p, a):
			continue
		var s := board_score(sim, p)
		if s >= best_score and (best.is_empty() or s > best_score):
			best = a
			best_score = s
	return best
