class_name Lane
extends RefCounted
## Un recinto: una zona, una creatura davanti e una struttura dietro.

var zone: String = ""
var creature: CardInst = null
var structure: CardInst = null
var disabled := false


func _init(z: String = "") -> void:
	zone = z


func clone() -> Lane:
	var l := Lane.new(zone)
	l.creature = creature.clone() if creature else null
	l.structure = structure.clone() if structure else null
	l.disabled = disabled
	return l
