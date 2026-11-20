"""Lo Speaker della Radio (sopravvissuto) — Persona standard (corpo 12x18 con contorno).
Cuffie enormi, baffoni, camicia arancione chiassosa, microfono d'altri tempi davanti alla bocca spalancata
e onde sonore che escono: "Notizia dell'ultima ora". Disegnato a griglia; contorno pieno inchiostro."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

L = {
    "g": "ferro_2",                                          # archetto delle cuffie
    "R": "rosso_2",                                          # padiglioni
    "H": "legno_1", "m": "legno_1",                          # capelli e baffi
    "S": "pelle_4", "s": "pelle_2",
    "k": "inchiostro",
    "O": "arancio_3", "o": "arancio_1", "t": "rosso_2",     # camicia e cravatta
    "n": "notte",                                            # pantaloni
}

HEAD = [  # 11 di larghezza, guarda a sinistra
    "...gggggg..",
    "..gHHHHHHg.",
    ".HHHHHHHHHg",
    ".HSSSSSSHRR",
    "RSSSSSSSHRR",
    "RSkSSSkSSRR",
    "RSkSSSkSSRg",
    "SSSSSSSSSs.",
    "mmmmmmmSSs.",
    ".SkkkSSSs..",
]
BLINK = {5: "RSSSSSSSSRR", 6: "RkkSSkkSSRg"}
SHOUT = {9: ".kkkkSSSs.."}

BODY = [
    "..OOtOOOo..",
    "..OOtOOOoS.",
    "..OOOOOOo..",
    "..nnnnnnn..",
    "..nn...nn..",
]


def stamp(s, rows, ox, oy):
    for j, r in enumerate(rows):
        for i, ch in enumerate(r):
            if ch != ".":
                s.px(ox + i, oy + j, L[ch], outline="inchiostro")


def frame(i):
    s = Sprite(32, 32)
    s.shadow(15.5, 28.2, 7.5, 2.2)
    ox, oy = 12, 12
    bob = 1 if i in (1, 2) else 0
    stamp(s, BODY, ox, oy + 10)
    head = list(HEAD)
    if i == 3:
        head = [BLINK.get(j, r) for j, r in enumerate(head)]
    if i in (0, 1):
        head = [SHOUT.get(j, r) for j, r in enumerate(head)]
    stamp(s, head, ox, oy + bob)
    P = lambda x, y, c: s.px(x, y, c, outline="inchiostro")
    # microfono a capsula davanti alla bocca, manico fino alla mano
    mx, my = ox - 5, oy + 6 + bob
    CAPS = ["Wff", "fff", "ggg", ".g."]          # capsula a griglia, d'altri tempi
    for dy, row in enumerate(CAPS):
        for dx, ch in enumerate(row):
            if ch != ".":
                P(mx + dx, my + dy, {"W": "bianco", "f": "ferro_4", "g": "ferro_2"}[ch])
    P(mx + 2, my + 4, "ferro_2"); P(mx + 3, my + 5, "ferro_2")
    P(mx + 4, my + 5, "pelle_4"); P(mx + 4, my + 6, "pelle_4")             # mano
    for x in range(mx + 5, ox + 3):
        P(x, my + 5, "arancio_3")                                           # manica
    s.outline("inchiostro")
    # onde sonore (bianco), si allargano a fotogrammi alterni
    wx = mx - 3 - (1 if i % 2 else 0)
    if i != 3:
        for y in range(my - 1, my + 4):
            s.px(wx if my <= y <= my + 2 else wx + 1, y, "bianco")
        if i % 2:
            for y in range(my - 2, my + 5):
                s.px(wx - 2 if my - 1 <= y <= my + 3 else wx - 1, y, "bianco")
    s.px(ox + 3, oy + 15, "legno_1"); s.px(ox + 8, oy + 15, "legno_1")     # scarpe
    return s


if __name__ == "__main__":
    Sprite.save("hero_speaker", "game/assets/heroes/speaker.png", [frame(i) for i in range(4)],
                comment="Sopravvissuto, Persona 12x18")
