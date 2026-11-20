"""Gallo Sentinella (Pollaio, comune) — taglia S (corpo ~17x16 in 32x32, un filo più grande della gallina): un gallo dritto e impettito con l'elmetto
militare, la cresta che spunta da sopra e la coda a falce verde scuro. "Canta all'alba. E a mezzanotte. E quando
vede un'ombra." Guarda a sinistra. Idle: respiro (corpo giù di 1 px nel fotogramma 1), canto a becco aperto (2),
battito di ciglia (3)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

C = {
    "O": "legno_3", "D": "pelle_1", "B": "pelle_2", "L": "pelle_3",
    "r": "rosso_1", "R": "rosso_2", "Y": "arancio_4", "k": "inchiostro",
    "g": "verde_1", "H": "salvia", "h": "verde_5",
    "G": "verde_0", "T": "verde_1", "t": "salvia",   # coda a falce, più scura dell'elmetto
}

ROOSTER = [
    "...r.r...........",
    "..rRrRr.....GGG..",
    "..gHhhHg...GTTTG.",
    ".gHhHHHHg.GTttTTG",
    "gggggggggGTtTTTTG",
    ".OLkLLBBOGTtTTGTG",
    "YYYkLLBBOGTTTG.GG",
    "YYRLLBBBOGTTTG...",
    ".RRLLBBBBGTTG....",
    ".rRLBBBBBBGTGO...",
    "..OLBDDDDDDBBO...",
    "..OLDLLLLLLDBO...",
    "..OBBDLLLLLDBO...",
    "...OBBDDDDDBO....",
    "....OODBBBDOO....",
    "......OOOOO......",
]


def frame(i):
    s = Sprite(32, 32)
    ox, oy = 8, 10
    breath = 1 if i == 1 else 0
    s.shadow(16.0, 26.4, 8.0, 2.2)
    s.px(ox + 7, oy + 16, "arancio_4"); s.px(ox + 10, oy + 16, "arancio_4")    # zampe
    for y, row in enumerate(ROOSTER):
        for x, ch in enumerate(row):
            if ch == ".":
                continue
            dy = breath if y < 10 else 0          # nel respiro si abbassa la parte alta
            s.px(ox + x, oy + y + dy, C[ch])
    if i == 2:                                     # canto: becco aperto
        s.px(ox + 0, oy + 6, "arancio_4"); s.px(ox + 1, oy + 6, "inchiostro"); s.px(ox + 2, oy + 6, "arancio_4")
        s.px(ox - 1, oy + 5, "arancio_4"); s.px(ox - 1, oy + 7, "arancio_4")
        s.px(ox - 3, oy + 3, "pelle_3"); s.px(ox - 4, oy + 2, "pelle_3")       # righine del verso
        s.px(ox - 3, oy + 8, "pelle_3"); s.px(ox - 4, oy + 9, "pelle_3")
        s.px(ox - 4, oy + 5, "pelle_3"); s.px(ox - 5, oy + 5, "pelle_3")
    if i == 3:                                     # battito di ciglia
        s.px(ox + 3, oy + 5, "pelle_3")
    return s


if __name__ == "__main__":
    Sprite.save("gallo_sentinella", "game/assets/cards/gallo_sentinella.png", [frame(i) for i in range(4)],
                comment="Pollaio, taglia S")
