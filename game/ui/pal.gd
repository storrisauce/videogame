class_name Pal
extends RefCounted
## Colori dell'interfaccia (dalla palette del gioco, docs/art/design-system.md) e nomi delle bande.

const BG := Color("#262b44")        # notte
const TABLE := Color("#5a3737")     # legno_1
const TEXT := Color("#ffffff")      # bianco
const DARK := Color("#181425")      # inchiostro
const GREEN := Color("#a3e048")     # radio_1
const RED := Color("#e43b44")       # rosso_2
const YELLOW := Color("#fee761")    # giallo_2
const HILITE := Color("#d4f25e")    # radio_2

const BAND_COLOR := {
	"porcile": Color("#e17276"),    # rosa_3
	"pollaio": Color("#feae34"),    # arancio_4
	"stagno": Color("#32b8e8"),     # acqua_5
	"patate": Color("#90bf5d"),     # verde_5
	"discarica": Color("#8b9bb4"),  # ferro_4
	"cratere": Color("#b76baa"),    # viola_4
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
