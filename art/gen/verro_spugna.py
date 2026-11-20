"""Verro Spugna (Porcile, comune) — taglia S grande: un verro (maschio, zanne e criniera ispida) con il corpo poroso
come una spugna, pieno di buchi, che ha assorbito gocce radioattive. "Assorbe tutto. Soprattutto le radiazioni."
Guarda a sinistra. Disegnato a mano su griglia; idle: respiro (corpo giu' di 1 px), le macchie radio pulsano, battito."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

LEGEND = {
    "o": "rosa_1", "x": "rosa_2", "h": "rosa_3", "c": "rosa_4",
    "w": "bianco", "k": "inchiostro", "r": "radio_1", "R": "radio_2",
}
#        0         1         2         3
#        01234567890123456789012345678901
BASE = """
................................
................................
................................
................................
................................
................................
................................
................................
................................
................................
.............o.o.o.o............
......oo....oooxoxoxoo..........
.....ohho..ohhcxcxcxccoo........
.....ohcoooochcccccccccccoo.....
....occcccccccocccccccccchho....
....occcccccchccccccccccchho....
....occcccccchcccccccccccchho...
....ockcccckchccccccccchhhhho...
...occkcccckchcccccccchhhhhho...
..ohhhhcccccchccccccchhhhhhho...
..ohohohccccchccccccchhhhhhho...
..oohhhhcccchhcccccchhhhhhhhoo..
..w.oooooccchhhhhhhhhhhhhhhho.o.
.....ohhhhhhhhhhhhhhhhhhhhho.o..
......ohhhhhhhhhhhhhhhhhhhoo....
.......ooohhoooooooooohhoo......
.........ohho.......ohho........
..........oo........oo..........
................................
................................
................................
................................
"""
HOLES = [(16, 14), (21, 15), (15, 19), (24, 17), (19, 21), (14, 22), (25, 21)]   # buchi della spugna (2x2)
RADIO = [(19, 17, "r"), (20, 17, "r"), (19, 18, "R"), (20, 18, "r"), (23, 13, "r")]  # gocce assorbite
TUSK = [(2, 21), (2, 22)]
EYES = [(6, 17), (6, 18), (11, 17), (11, 18)]
SPLIT = 22
DROP = (8, 18)        # colonne della griglia tolte per accorciare il corpo (taglia reale)
SHADOW = (15.5, 27.0, 10.5, 2.2)


def grid():
    rows = BASE.strip("\n").split("\n")
    assert len(rows) == 32 and all(len(r) == 32 for r in rows), [len(r) for r in rows]
    return [list(r) for r in rows]


def frame(i):
    g = grid()
    for (x, y) in HOLES:
        for dx in (0, 1):
            top, bot = g[y][x + dx], g[y + 1][x + dx]
            if top in "ch":
                g[y][x + dx] = "x" if top == "c" else "o"
            if bot in "ch":
                g[y + 1][x + dx] = "h" if bot == "c" else "x"
    for (x, y, ch) in RADIO:
        g[y][x] = ch
    for (x, y) in TUSK:
        g[y][x] = "w"
    if i == 3:
        for (x, y) in EYES:
            g[y][x] = "c"
        g[18][6] = "o"; g[18][11] = "o"
    if i in (1, 3):                               # la macchia radio "si assorbe": il centro si spegne
        g[18][19] = "r"
    if i in (1, 2):
        for y in range(SPLIT, 0, -1):
            g[y] = list(g[y - 1])
    pad = len(DROP) // 2                         # toglie qualche colonna per stare nella taglia S/M e ricentra
    g = [["."] * pad + [c for x, c in enumerate(row) if x not in DROP] + ["."] * (len(DROP) - pad) for row in g]
    s = Sprite(32, 32)
    s.shadow(*SHADOW)
    for y, row in enumerate(g):
        for x, ch in enumerate(row):
            if ch != ".":
                s.px(x, y, LEGEND[ch])
    return s


if __name__ == "__main__":
    Sprite.save("verro_spugna", "game/assets/cards/verro_spugna.png", [frame(i) for i in range(4)],
                comment="Porcile, taglia S grande")
