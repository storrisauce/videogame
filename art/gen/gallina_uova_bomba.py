"""Gallina Uova-Bomba (Pollaio, rara) — taglia S (corpo ~16x14 in 32x32, come la gallina del riferimento): una gallina accanto al suo uovo
con la miccia accesa. "Non chiederle la frittata." Guarda a sinistra come gli animali del riferimento.
Idle: la testa si abbassa di 1 px (fotogramma 1), battito di ciglia (3), la scintilla della miccia sfarfalla."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

C = {
    "O": "legno_3", "D": "pelle_1", "B": "pelle_2", "L": "pelle_3",
    "r": "rosso_1", "R": "rosso_2", "Y": "arancio_4", "k": "inchiostro",
    "w": "bianco", "g": "ferro_5", "s": "giallo_2",
}

# la gallina intera; la testa (righe 0-8, colonne 0-7) si abbassa di 1 px nel fotogramma 1
HEN = [
    "..rr............",
    ".rRRr...........",
    ".rRRRr.......OO.",
    ".OLLLBO.....ODLO",
    "OLkLLBBO...ODLLO",
    "YYkLLBBO..ODLLBO",
    "YYRLLBBBOODLLBBO",
    ".RRLBBBBBDDDDBBO",
    ".rRLBBDDDDLLDBBO",
    "..OBDLLLLLLLDBO.",
    "..OBBDLLLLLDBBO.",
    "...OBBDDDDDBBO..",
    "....OODBBBDOO...",
    "......OOOOO.....",
]
EGG = [
    "..OOO..",
    ".OwwwO.",
    "OwwwwgO",
    "OwwwwgO",
    "OwwwwgO",
    "OwwwggO",
    ".OgggO.",
    "..OOO..",
]


def stamp(s, grid, ox, oy, extra=None):
    for y, row in enumerate(grid):
        for x, ch in enumerate(row):
            if extra and (x, y) in extra:
                ch = extra[(x, y)]
            if ch != ".":
                s.px(ox + x, oy + y, C[ch])


def frame(i):
    s = Sprite(32, 32)
    hx, hy = 5, 12
    s.shadow(13.0, 26.4, 8.0, 2.2)          # ombra della gallina
    s.shadow(26.5, 26.3, 4.0, 1.7)          # ombra dell'uovo
    s.px(hx + 7, hy + 14, "arancio_4"); s.px(hx + 10, hy + 14, "arancio_4")   # zampe
    for y, row in enumerate(HEN):
        for x, ch in enumerate(row):
            if ch == ".":
                continue
            head = y <= 8 and x <= 7
            if head and i == 1:
                continue
            s.px(hx + x, hy + y, C[ch])
    if i == 1:                               # testa abbassata di 1 px
        for y, row in enumerate(HEN[:9]):
            for x, ch in enumerate(row[:8]):
                if ch != ".":
                    s.px(hx + x, hy + y + 1, C[ch])
    if i == 3:                               # battito di ciglia: resta una riga dell'occhio
        s.px(hx + 2, hy + 4, "pelle_3")
    # uovo-bomba: tappo scuro, miccia e scintilla
    stamp(s, EGG, 23, 18)
    s.px(26, 17, "inchiostro"); s.px(25, 17, "inchiostro")
    s.px(26, 16, "inchiostro"); s.px(27, 15, "inchiostro")
    sparks = [
        [(28, 14, "giallo_2"), (27, 14, "arancio_4"), (28, 13, "arancio_4"), (29, 14, "arancio_4")],
        [(28, 14, "giallo_2"), (29, 13, "giallo_2"), (28, 15, "arancio_4")],
        [(28, 14, "giallo_2"), (27, 13, "arancio_4"), (29, 13, "arancio_4"), (28, 12, "giallo_2"), (29, 15, "arancio_4")],
        [(28, 14, "giallo_2"), (28, 13, "arancio_4")],
    ][i]
    for x, y, col in sparks:
        s.px(x, y, col)
    return s


if __name__ == "__main__":
    Sprite.save("gallina_uova_bomba", "game/assets/cards/gallina_uova_bomba.png", [frame(i) for i in range(4)],
                comment="Pollaio, taglia S")
