"""Il Veterinario Terrorizzato (sopravvissuto) — Persona, la più alta (corpo 13x22 con contorno).
Lungo e magro, camice bianco, stetoscopio, occhi sbarrati con le pupille piccole, goccia di sudore,
siringa enorme di siero verde che gli trema in mano: "Stai fermo, ti prego". Contorno pieno inchiostro."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

L = {
    "h": "prugna", "H": "legno_0",                           # capelli scuri arruffati
    "S": "pelle_4", "s": "pelle_2",
    "k": "inchiostro", "W": "bianco",
    "C": "bianco", "c": "ferro_5", "e": "ferro_4",          # camice
    "t": "ferro_2",                                          # stetoscopio, pantaloni
    "g": "radio_1", "a": "acqua_5",                          # siero, sudore
}

HEAD = [  # 11 di larghezza, guarda a sinistra
    "..h..h.h...",
    ".hhhhhhhhh.",
    "hhhhhhhhhHH",
    "hSSSSShhhHH",
    "SSSSSSSShHH",
    "SWWSWWSSShH",
    "SkWSkWSSSsH",
    "SSSSSSSSSs.",
    ".SSkkSSSs..",
    "..SSSSSs...",
]
BLINK = {5: "SSSSSSSSShH", 6: "SkkSkkSSSsH"}

BODY = [
    "..cCtCCtc..",
    "..CCtCCtCc.",
    "..CCCtttCc.",
    "..CCCCtCCc.",
    "..CCCCCCCcS",
    "..CCCcCCCc.",
    "..CCCcCCCe.",
    "..eCCcCCee.",
    "...tt.tt...",
    "...t...t...",
]


def stamp(s, rows, ox, oy):
    for j, r in enumerate(rows):
        for i, ch in enumerate(r):
            if ch != ".":
                s.px(ox + i, oy + j, L[ch], outline="inchiostro")


def frame(i):
    s = Sprite(32, 32)
    s.shadow(15.5, 28.2, 7.5, 2.2)
    ox, oy = 11, 8
    bob = 1 if i in (1, 2) else 0
    stamp(s, BODY, ox, oy + 10)
    head = [BLINK.get(j, r) if i == 3 else r for j, r in enumerate(HEAD)]
    stamp(s, head, ox, oy + bob)
    # siringa gigante alzata, ago in su; trema di 1 px a fotogrammi alterni
    sx = ox - 5 + (1 if i % 2 else 0)
    sy = oy + 9                                     # cima del cilindro
    P = lambda x, y, c: s.px(x, y, c, outline="inchiostro")
    for y in range(sy - 3, sy):
        P(sx + 1, y, "ferro_4")                                            # ago
    for y in range(sy, sy + 6):
        P(sx, y, "bianco"); P(sx + 1, y, "radio_1" if y > sy + 1 else "bianco"); P(sx + 2, y, "ferro_5")
    P(sx + 1, sy + 2, "radio_2" if i in (0, 1) else "radio_1")
    for x in range(sx - 1, sx + 4):
        P(x, sy + 6, "ferro_5")                                            # alette
    P(sx + 1, sy + 7, "ferro_4"); P(sx + 1, sy + 8, "ferro_4")              # stantuffo
    for x in range(sx, sx + 3):
        P(x, sy + 9, "ferro_5")
    P(sx + 3, sy + 4, "pelle_4"); P(sx + 3, sy + 5, "pelle_4")              # mano
    for x in range(sx + 4, ox + 3):
        P(x, sy + 5, "bianco"); P(x, sy + 6, "ferro_5")                       # manica
    s.outline("inchiostro")
    # goccia di sudore che scivola sulla tempia
    dy = (0, 1, 2, 0)[i]
    s.px(ox + 11, oy + 3 + dy + bob, "acqua_5"); s.px(ox + 11, oy + 4 + dy + bob, "acqua_5")
    s.px(ox + 4, oy + 19 + 1, "legno_0"); s.px(ox + 8, oy + 19 + 1, "legno_0")   # scarpe
    return s


if __name__ == "__main__":
    Sprite.save("hero_veterinario", "game/assets/heroes/veterinario.png", [frame(i) for i in range(4)],
                comment="Sopravvissuto, Persona 13x22 (la più alta)")
