class_name PlayerState
extends RefCounted
## Tutto ciò che appartiene a un giocatore durante la partita.

var hero: Dictionary
var hero_level: int = 1
var hp: int = 0
var max_hp: int = 0
var deck: Array[CardInst] = []
var hand: Array[CardInst] = []
var discard: Array[CardInst] = []   ## il Letamaio
var lanes: Array[Lane] = []
var caos: int = 0
var bonus_next: int = 0              ## Caos bonus (o malus) per il prossimo turno
var cooldown: int = 0
var discounts: Dictionary = {}       ## banda -> sconto sulle creature, solo per questo turno
var atk_penalty: int = 0
var turns_taken: int = 0
var empty_deck_rule := "bleed"       ## "bleed" (umano) o "reshuffle" (IA), come nel genere
var is_human := false


func clone() -> PlayerState:
	var p := PlayerState.new()
	p.hero = hero
	p.hero_level = hero_level
	p.hp = hp
	p.max_hp = max_hp
	for c in deck:
		p.deck.append(c.clone())
	for c in hand:
		p.hand.append(c.clone())
	for c in discard:
		p.discard.append(c.clone())
	for l in lanes:
		p.lanes.append(l.clone())
	p.caos = caos
	p.bonus_next = bonus_next
	p.cooldown = cooldown
	p.discounts = discounts.duplicate()
	p.atk_penalty = atk_penalty
	p.turns_taken = turns_taken
	p.empty_deck_rule = empty_deck_rule
	p.is_human = is_human
	return p
