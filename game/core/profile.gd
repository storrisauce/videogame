class_name Profile
extends RefCounted
## Profilo del giocatore salvato sul telefono (user://). In M4 si sincronizzerà con Supabase.

const PATH := "user://profilo.json"

var fagioli := 0          ## scatolette di fagioli (moneta)
var tonno := 3            ## scatolette di tonno (valgono doppio; servono per rialzarsi)
var mirino_automatico := false
var meno_movimento := false   ## accessibilità: niente scosse dello schermo né salti delle figure
var musica := true
var effetti := true
var vibrazione := true
var vittorie := 0
var sconfitte := 0
var hero := "nonna"
var bands := ["porcile", "pollaio"]


static func load_or_new() -> Profile:
	var p := Profile.new()
	if FileAccess.file_exists(PATH):
		var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if d is Dictionary:
			p.fagioli = int(d.get("fagioli", 0))
			p.tonno = int(d.get("tonno", 3))
			p.mirino_automatico = bool(d.get("mirino_automatico", false))
			p.meno_movimento = bool(d.get("meno_movimento", false))
			p.musica = bool(d.get("musica", true))
			p.effetti = bool(d.get("effetti", true))
			p.vibrazione = bool(d.get("vibrazione", true))
			p.vittorie = int(d.get("vittorie", 0))
			p.sconfitte = int(d.get("sconfitte", 0))
			p.hero = String(d.get("hero", "nonna"))
			p.bands = Array(d.get("bands", ["porcile", "pollaio"]))
	return p


func save() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		push_error("Impossibile salvare il profilo")
		return
	f.store_string(JSON.stringify({
		"fagioli": fagioli, "tonno": tonno, "mirino_automatico": mirino_automatico, "meno_movimento": meno_movimento,
		"musica": musica, "effetti": effetti, "vibrazione": vibrazione,
		"vittorie": vittorie, "sconfitte": sconfitte, "hero": hero, "bands": bands,
	}, "\t"))
