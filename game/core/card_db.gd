class_name CardDB
extends RefCounted
## Dati statici: carte, sopravvissuti e numeri delle regole, letti da JSON.

var cards: Dictionary = {}
var heroes: Dictionary = {}
var rules: Dictionary = {}


static func load_default() -> CardDB:
	var db := CardDB.new()
	db.load_files("res://data/cards.json", "res://data/rules.json")
	return db


func load_files(cards_path: String, rules_path: String) -> void:
	var c: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(cards_path))
	for card: Dictionary in c["cards"]:
		cards[card["id"]] = card
	for h: Dictionary in c["heroes"]:
		heroes[h["id"]] = h
	rules = JSON.parse_string(FileAccess.get_file_as_string(rules_path))


func card(id: String) -> Dictionary:
	if not cards.has(id):
		push_error("Carta sconosciuta: %s" % id)
		return {}
	return cards[id]


func rule(key: String) -> Variant:
	return rules[key]


func rule_i(key: String) -> int:
	return int(rules[key])


## Vantaggio della banda a contro la banda d: +adv contro la seguente nel ciclo, -adv contro la precedente.
func advantage(a: String, d: String) -> float:
	var cycle: Array = rules["advantage_cycle"]
	var ia := cycle.find(a)
	var id := cycle.find(d)
	if ia < 0 or id < 0 or ia == id:
		return 0.0
	var n := cycle.size()
	var adv := float(rules["advantage"])
	if (ia + 1) % n == id:
		return adv
	if (id + 1) % n == ia:
		return -adv
	return 0.0
