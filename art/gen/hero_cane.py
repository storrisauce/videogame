"""Il Cane da Pastore che Ha Visto Troppo (sopravvissuto) — animale, taglia S (circa 19x17), seduto, guarda a sinistra.
Pelo fulvo e bianco da cane pastore, un orecchio piegato, peli grigi in testa, occhi sbarrati con le occhiaie:
lo sguardo fisso nel vuoto di chi ha visto troppo. Contorno selettivo legno_1 (tono più scuro del pelo)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

L = {
    "L": "legno_7", "B": "legno_5", "b": "legno_3",         # pelo fulvo (luce, base, ombra)
    "W": "bianco", "w": "ferro_5",                           # pelo bianco
    "g": "ferro_5",                                          # peli grigi
    "k": "inchiostro", "o": "legno_1",                       # occhi, naso, linee interne
}

DOG = [
    ".....L.......b......",
    "....LBL.....bBb.....",
    "....LBBBgBgBBBbbb...",
    "...LBBBBBBBBBBb.bb..",
    "...BBWWBBWWBBBb.....",
    "...BBWkBBWkBBBb.....",
    "..LBBbbBBbbBBb......",
    "LLBBBWWWBBBBBb......",
    "kBWWWWWWWBBBb..BBb..",
    ".wWWWWWWWWBb.BBBBBb.",
    "..WWWWWWWWWBBBBBBBbb",
    "...WWWWWWWBBBBBBBBbb",
    "...wWWWWWBBBBBBBBbbB",
    "....WWWWwBBBBBBBbbBL",
    "....WWoWWBBBBBBbbb..",
    "....WWoWWbBBBBbbb...",
    "....wwowwbbbbbbb....",
]


def frame(i):
    s = Sprite(32, 32)
    s.shadow(16.5, 28.2, 10, 2.4)
    ox, oy = 5, 11
    bob = 1 if i in (1, 2) else 0
    for j, r in enumerate(DOG):
        dy = bob if j <= 8 else 0           # solo la testa si abbassa
        for x, ch in enumerate(r):
            if ch != ".":
                s.px(ox + x, oy + j + dy, L[ch], outline="legno_1")
    s.outline()
    if i == 3:   # battito di ciglia (lento: anche lui è stanco)
        for ex in (5, 9):
            for yy in (4, 5):
                s.px(ox + ex, oy + yy + bob, "legno_5"); s.px(ox + ex + 1, oy + yy + bob, "legno_5")
            s.px(ox + ex, oy + 5 + bob, "legno_1"); s.px(ox + ex + 1, oy + 5 + bob, "legno_1")
    # coda che scodinzola piano (fotogrammi 1-2)
    if i in (1, 2):
        s.px(ox + 19, oy + 13, None); s.px(ox + 20, oy + 12, "legno_7", outline="legno_1")
    return s


if __name__ == "__main__":
    Sprite.save("hero_cane", "game/assets/heroes/cane.png", [frame(i) for i in range(4)],
                comment="Sopravvissuto, animale S 19x17")
