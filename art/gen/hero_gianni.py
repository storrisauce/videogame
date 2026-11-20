"""Contadino Gianni in Mutande (sopravvissuto) — Persona standard (corpo 12x17 con contorno, cappello compreso).
Cappello di paglia, canottiera, mutandoni a cuori... a pois, gambe nude, faccia confusa e un punto di domanda
che gli galleggia sopra: "Oggi è lunedì?". Disegnato a griglia; contorno pieno inchiostro."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

L = {
    "P": "legno_9", "p": "legno_8", "q": "legno_7",        # paglia
    "r": "rosso_2", "R": "rosso_2", "d": "rosso_1",         # nastro del cappello, mutande
    "S": "pelle_4", "b": "legno_3", "s": "pelle_2", "c": "rosa_3",
    "k": "inchiostro", "W": "bianco", "w": "ferro_5",       # canottiera
}

HEAD = [  # 13 di larghezza (falda del cappello), guarda a sinistra
    "....PPPPp....",
    "...PrrrrrqP..",
    "PPPPpppppppqq",
    ".qq.qqqqqqqq.",
    "..sSSSSkkbb..",
    "..SkSSSSSbb..",
    "..SkSSSkSbb..",
    "..cSSSSSsb...",
    "...SSSkSs....",
]
BLINK = {5: "..SSSSSSSbb..", 6: "..SkSSSkSbb.."}

BODY = [
    "....WWWWw....",
    "...SWWWWwS...",
    "...SWWWWwS...",
    "....RWRRd....",
    "....RRRWd....",
    "....S...S....",
]

QUESTION = [  # punto di domanda che galleggia
    "WWW",
    "..W",
    ".WW",
    ".W.",
    "...",
    ".W.",
]


def stamp(s, rows, ox, oy):
    for j, r in enumerate(rows):
        for i, ch in enumerate(r):
            if ch != ".":
                s.px(ox + i, oy + j, L.get(ch, "bianco"), outline="inchiostro")


def frame(i):
    s = Sprite(32, 32)
    s.shadow(15.5, 28.2, 7.5, 2.2)
    ox, oy = 9, 13
    bob = 1 if i in (1, 2) else 0
    stamp(s, BODY, ox, oy + 9)
    head = [BLINK.get(j, r) if i == 3 else r for j, r in enumerate(HEAD)]
    stamp(s, head, ox, oy + bob)
    qy = 5 + (1 if i in (2, 3) else 0)
    stamp(s, QUESTION, 21, qy)
    s.outline("inchiostro")
    # piedi sulla riga del contorno, come nel riferimento
    s.px(ox + 4, oy + 15, "legno_3"); s.px(ox + 8, oy + 15, "legno_3")
    return s


if __name__ == "__main__":
    Sprite.save("hero_gianni", "game/assets/heroes/gianni.png", [frame(i) for i in range(4)],
                comment="Sopravvissuto, Persona 12x17")
