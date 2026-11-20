extends RefCounted
## Ricette dei modelli 3D: gruppo "cratere". Usa il kit (models/kit.gd) e le sue convenzioni di taglia e stile.


static func build(id: String) -> Node3D:
	match id:
		_:
			return null
