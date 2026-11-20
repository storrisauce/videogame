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
			Kit.prepare_outlines(n)
			return n
	return null


## Ingombro del modello (in unità del kit, rotazione della radice compresa). Funziona anche fuori dall'albero.
static func bounds(n: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for mi: MeshInstance3D in n.find_children("*", "MeshInstance3D", true, false):
		var t := Transform3D()
		var node: Node = mi
		while node != null and node != n:
			t = (node as Node3D).transform * t
			node = node.get_parent()
		t = Transform3D(n.transform.basis, Vector3.ZERO) * t
		var b := t * mi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box


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
