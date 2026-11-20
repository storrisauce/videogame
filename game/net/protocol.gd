class_name Protocol
extends RefCounted
## Mosse della partita online (D-025). Si mandano solo le mosse; ogni telefono ricalcola la partita.
## Ogni telefono vede sé stesso come giocatore 0: un "p" dentro una mossa è relativo a chi la manda
## (0 = chi manda, 1 = chi riceve), quindi chi riceve lo gira: p → 1 - p.
## Tipi: play {hand, lane, target}, scuoti {lane, target}, hero {target}, attack {lane, crit}, end {sum}.


## Prepara una mossa locale per la rete (JSON: niente oggetti, solo numeri e testi).
static func encode(a: Dictionary) -> Dictionary:
	var out := a.duplicate(true)
	return out


## Mossa ricevuta → mossa locale: numeri interi (il JSON li rende decimali) e bersagli girati.
static func decode(a: Dictionary) -> Dictionary:
	var out := {}
	for k in a:
		var v: Variant = a[k]
		if v is float and k != "sum":
			v = int(v)
		out[k] = v
	var t: Variant = out.get("target")
	if t is Dictionary:
		var nt := {}
		for k in t:
			nt[k] = int(t[k]) if t[k] is float else t[k]
		if nt.has("p"):
			nt["p"] = 1 - int(nt["p"])
		out["target"] = nt
	return out


## Applica una mossa (locale o ricevuta) al Match. Ritorna false se non è valida.
static func apply(m: Match, p: int, a: Dictionary) -> bool:
	match a.get("type", ""):
		"play", "scuoti", "hero":
			var full := a.duplicate()
			if not full.has("target"):
				full["target"] = null
			if a["type"] == "play" and not full.has("lane"):
				full["lane"] = -1
			return m.apply(p, full)
		"attack":
			return m.attack_lane(p, int(a["lane"]), bool(a.get("crit", false))) != "" or true
		"end":
			m.end_turn(p)
			return true
	return false


## Impronta dello stato (per accorgersi se i due telefoni non sono più d'accordo). Giocatori in ordine
## relativo a `me`, così i due telefoni calcolano lo stesso numero.
static func checksum(m: Match, me: int) -> int:
	var parts := []
	for k in 2:
		var ps := m.players[me if k == 0 else 1 - me]
		parts.append([ps.hp, ps.caos, ps.hand.size(), ps.deck.size(), ps.discard.size()])
		for l in ps.lanes:
			parts.append([l.creature.id() if l.creature else "", m.health_of(l.creature) if l.creature else 0,
				l.structure.id() if l.structure else ""])
	return hash(str(parts))
