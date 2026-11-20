"""Pulcino Mitragliere (Pollaio, comune) — taglia XS dentro un fotogramma 32x32 (corpo ~11x11, più piccolo di gallina e gallo): un pulcino giallo
con la cartucciera a tracolla e una mitraglietta più grande della sua testa. "Pio. Ratatatà. Pio."
Guarda a sinistra. Idle: saltello (1), raffica con lampo alla bocca dell'arma (2), battito di ciglia (3)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

C = {
    "a": "arancio_1", "d": "arancio_4", "b": "giallo_2", "c": "bianco", "p": "arancio_2", "k": "inchiostro",
    "n": "notte", "F": "ferro_1", "m": "ferro_3",
}

# piumino: a = contorno arancio_1, d = ombra arancio_4, b = base giallo_2, c = luce bianco
CHICK = [
    "....a......",
    "...aaaa....",
    "..abbbba...",
    ".abccbbba..",
    ".abcbkbba..",
    "ppbbbkbbda.",
    ".aabbbbddaa",
    ".abbbbbbbba",
    ".abbbbbbbca",
    ".adbbbbbbda",
    "..adddddda.",
    "...aaaaaa..",
]
# mitraglietta: canna verso sinistra, caricatore sotto
GUN = [
    "nnnnnnnn.",
    "mFmFmFFFn",
    "nnnnnFFFn",
    ".....nn..",
]
# cartucciera a tracolla: cinghia (legno_3) dalla spalla al fianco, bossoli (arancio_4) sul lato in ombra
STRAP = [(21, 20), (20, 21), (19, 22), (18, 23)]
SHELLS = [(22, 20), (21, 21), (20, 22), (19, 23)]


def stamp(s, grid, ox, oy):
    for y, row in enumerate(grid):
        for x, ch in enumerate(row):
            if ch != ".":
                s.px(ox + x, oy + y, C[ch])


def frame(i):
    s = Sprite(32, 32)
    hop = -1 if i == 1 else 0
    s.shadow(18.0, 26.3, 5.5, 1.8 if i != 1 else 1.5)
    s.px(17, 26, "arancio_2"); s.px(20, 26, "arancio_2")             # zampette
    cx, cy = 13, 14 + hop
    stamp(s, CHICK, cx, cy)
    if i == 3:                                     # battito di ciglia: l'occhio diventa una riga
        s.px(cx + 5, cy + 4, "giallo_2")
    for k, (x, y) in enumerate(STRAP):
        s.px(x, y + hop, "legno_3")
        if k % 2 == 0:
            s.px(SHELLS[k][0], SHELLS[k][1] + hop, "arancio_4")
    # arma stretta al petto, canna verso sinistra
    gx, gy = 9, 22 + hop
    stamp(s, GUN, gx, gy)
    s.px(gx + 9, gy + 1, "giallo_2"); s.px(gx + 9, gy + 2, "arancio_4")   # aletta che regge l'arma
    if i == 2:                                     # raffica: lampo alla bocca e bossolo che vola
        s.px(gx - 1, gy + 1, "giallo_2"); s.px(gx - 2, gy + 1, "bianco"); s.px(gx - 2, gy, "giallo_2")
        s.px(gx - 2, gy + 2, "giallo_2"); s.px(gx - 3, gy + 1, "giallo_2")
        s.px(gx + 6, gy - 2, "giallo_1")
    return s


if __name__ == "__main__":
    Sprite.save("pulcino_mitragliere", "game/assets/cards/pulcino_mitragliere.png", [frame(i) for i in range(4)],
                comment="Pollaio, taglia XS in fotogramma 32x32")
