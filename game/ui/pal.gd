class_name Pal
extends RefCounted
## Colori e nomi provvisori (palette del DNA tematico). Si sostituiranno con l'arte vera.

const BG := Color(0.16, 0.14, 0.08)
const TABLE := Color(0.27, 0.2, 0.11)
const TEXT := Color(0.97, 0.95, 0.85)
const DARK := Color(0.08, 0.06, 0.04)
const GREEN := Color(0.35, 0.95, 0.2)
const RED := Color(0.95, 0.2, 0.12)
const YELLOW := Color(1.0, 0.78, 0.05)
const HILITE := Color(0.4, 1.0, 0.25)

const BAND_COLOR := {
	"porcile": Color(0.86, 0.46, 0.56),
	"pollaio": Color(0.95, 0.75, 0.15),
	"stagno": Color(0.2, 0.62, 0.56),
	"patate": Color(0.58, 0.38, 0.7),
	"discarica": Color(0.72, 0.38, 0.16),
	"cratere": Color(0.36, 0.86, 0.22),
}

const BAND_NAME := {
	"porcile": "Porcile Radioattivo",
	"pollaio": "Pollaio Bombardato",
	"stagno": "Stagno delle Anatre Predone",
	"patate": "Campo delle Patate Urlanti",
	"discarica": "Discarica dei Recuperatori",
	"cratere": "Cratere della Centrale",
}

const TYPE_NAME := {"creature": "Creatura", "structure": "Struttura", "event": "Evento"}


static func band_color(b: String) -> Color:
	return BAND_COLOR.get(b, Color.GRAY)


static func font() -> Font:
	return ThemeDB.fallback_font
