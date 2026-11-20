class_name CardInst
extends RefCounted
## Una copia di una carta: livello, proprietario e stato in partita.

var def: Dictionary
var level: int = 1
var owner: int = 0
var atk_mod: int = 0
var def_mod: int = 0
var damage: int = 0
var scossa := false        ## abilità già usata in questo turno
var protected := false
var helpless := false
var cant_attack := false
var fresh := false
var dmg_reduction := 0
var dmg_factor := 1.0


func _init(d: Dictionary = {}, lvl: int = 1, own: int = 0) -> void:
	def = d
	level = lvl
	owner = own


func clone() -> CardInst:
	var c := CardInst.new(def, level, owner)
	c.atk_mod = atk_mod
	c.def_mod = def_mod
	c.damage = damage
	c.scossa = scossa
	c.protected = protected
	c.helpless = helpless
	c.cant_attack = cant_attack
	c.fresh = fresh
	c.dmg_reduction = dmg_reduction
	c.dmg_factor = dmg_factor
	return c


## Copia "pulita" per mano, mazzo e Letamaio: perde tutto lo stato di campo.
func fresh_copy() -> CardInst:
	return CardInst.new(def, level, owner)


func id() -> String:
	return def.get("id", "")


func type() -> String:
	return def.get("type", "")


func band() -> String:
	return def.get("band", "")


func cost() -> int:
	return int(def.get("cost", 0))


func ability() -> Dictionary:
	return def.get("ability", {})


func family() -> String:
	return ability().get("family", "")


## Valore dell'abilità moltiplicato per il livello (regola del genere).
func val(key: String = "v1") -> int:
	return int(ability().get(key, 0)) * level


func scuoti_cost() -> int:
	return int(ability().get("cost", 0))


func base_atk() -> int:
	return int(def.get("atk", 0)) * level


func base_def() -> int:
	return int(def.get("def", 0)) * level
