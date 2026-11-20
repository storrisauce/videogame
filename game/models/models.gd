class_name Models
extends RefCounted
## Costruisce il modello 3D di una carta o di un sopravvissuto per id. Ogni gruppo ha il suo file di ricette
## (models/recipes_<gruppo>.gd) con `static func build(id: String) -> Node3D` che ritorna null se l'id non è suo.
## Se nessuna ricetta lo conosce, ritorna null e il gioco usa la vecchia figura pixel art.

const GROUPS := [
	preload("res://models/recipes_porcile.gd"),
	preload("res://models/recipes_pollaio.gd"),
	preload("res://models/recipes_stagno.gd"),
	preload("res://models/recipes_patate.gd"),
	preload("res://models/recipes_discarica.gd"),
	preload("res://models/recipes_cratere.gd"),
	preload("res://models/recipes_eroi.gd"),
]


static func build(id: String) -> Node3D:
	for g in GROUPS:
		var n: Node3D = g.build(id)
		if n:
			return n
	return null


## Altezza del modello in unità (per mettere ATK e vita sopra la testa). Funziona anche fuori dall'albero.
static func height(n: Node3D) -> float:
	var top := 0.0
	for mi: MeshInstance3D in n.find_children("*", "MeshInstance3D", true, false):
		var t := Transform3D()
		var node: Node = mi
		while node != null and node != n:
			t = (node as Node3D).transform * t
			node = node.get_parent()
		top = maxf(top, (t * mi.get_aabb()).end.y)
	return top
