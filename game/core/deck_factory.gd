class_name DeckFactory
extends RefCounted
## Mazzo di partenza: 2 bande (2 recinti ciascuna), le loro carte ×3, più le carte del Cratere ×1.

const BANDS := ["porcile", "pollaio", "stagno", "patate", "discarica"]


static func build(db: CardDB, pair: Array) -> Array:
	var out := []
	for id: String in db.cards:
		var c: Dictionary = db.cards[id]
		if c["band"] in pair:
			for i in 3:
				out.append(id)
		elif c["band"] == "cratere":
			out.append(id)
	return out


static func zones(pair: Array) -> Array:
	return [pair[0], pair[0], pair[1], pair[1]]


static func random_pair(rng: RandomNumberGenerator) -> Array:
	var a: String = BANDS[rng.randi_range(0, BANDS.size() - 1)]
	var b := a
	while b == a:
		b = BANDS[rng.randi_range(0, BANDS.size() - 1)]
	return [a, b]
