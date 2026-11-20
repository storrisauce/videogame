"""Hai Preso Tu l'Apriscatole? (Discarica, evento comune) — illustrazione 32x32: una scatoletta ancora chiusa, con le
tacche dei giorni di attesa graffiate sull'etichetta, una forchetta piegata (tentativo fallito) appoggiata accanto e
una nuvoletta col punto di domanda. "Giorno 112. Nessuno l'ha preso."
Idle: la nuvoletta sale e scende, un luccichio scorre sul coperchio."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

LATTA = ("notte", "ferro_3", "ferro_4", "ferro_5")
NUVOLA = ("notte", "ferro_6", "bianco", "bianco")
DOMANDA = [
    ".##.",
    "#..#",
    "..#.",
    ".#..",
    "....",
    ".#..",
]


def frame(i):
    s = Sprite(32, 32)
    s.shadow(15.5, 27, 12, 2.2)
    # scatoletta in piedi: corpo, fondo e coperchio di 3/4
    s.rect(5, 16, 13, 10, LATTA, shade=False)
    s.ellipse(11.5, 26, 6.5, 1.6, LATTA, shade=False)
    s.ellipse(11.5, 15.5, 6.5, 2.4, LATTA, shade=False)
    # forchetta piegata buttata a terra a destra: manico dritto, rebbi storti all'insù
    for x in range(21, 26):
        s.px(x, 26, "ferro_5", "notte")
    s.px(26, 25, "ferro_5", "notte"); s.px(27, 24, "ferro_5", "notte")
    for x, y in ((27, 23), (27, 22), (29, 23), (30, 22), (28, 24), (28, 25)):
        s.px(x, y, "ferro_5", "notte")
    # nuvoletta del pensiero con due pallini che la collegano
    by = (0, -1, -1, 0)[i]
    s.ellipse(25, 6.5 + by, 5.2, 4.6, NUVOLA, shade=False)
    s.ellipse(20.5, 13 + by, 1.2, 1.2, NUVOLA, shade=False)
    s.outline()
    for r, row in enumerate(DOMANDA):
        for c, ch in enumerate(row):
            if ch == "#":
                s.px(23 + c, 4 + r + by, "notte")
    for x in range(20, 31):                              # ombra sotto la nuvola
        if s.get(x, 10 + by) == "bianco":
            s.px(x, 10 + by, "ferro_6")
    # luce a sinistra, ombra a destra sul corpo
    for y in range(16, 27):
        for x in range(5, 18):
            if s.get(x, y) in LATTA[1:]:
                s.px(x, y, "ferro_5" if x <= 6 else "ferro_3" if x >= 15 else "ferro_4")
    # coperchio: bordo chiaro, scanalatura, centro
    for y in range(13, 19):
        for x in range(5, 18):
            u, v = (x + 0.5 - 11.5) / 6.5, (y + 0.5 - 15.5) / 2.4
            d = u * u + v * v
            if d <= 1:
                s.px(x, y, "ferro_5" if d > 0.55 else "ferro_3" if d > 0.3 else "ferro_4")
    glint = ((8, 14), (9, 14)) if i != 2 else ((13, 14), (14, 14))
    for x, y in glint:
        s.px(x, y, "bianco")
    # etichetta: strisce rosse e carta chiara con le tacche dei giorni
    for x in range(5, 18):
        s.px(x, 19, "rosso_2"); s.px(x, 24, "rosso_2")
        for y in range(20, 24):
            s.px(x, y, "legno_9" if x < 15 else "legno_8")
    s.px(17, 19, "rosso_1"); s.px(17, 24, "rosso_1")
    for x in (7, 9, 11, 13, 16):                         # ||||  ||  (e la barra sulla prima cinquina)
        for y in range(20, 24):
            s.px(x, y, "legno_4")
    for x, y in ((6, 23), (8, 22), (10, 22), (12, 21), (14, 20)):
        s.px(x, y, "legno_3")
    return s


if __name__ == "__main__":
    Sprite.save("hai_preso_tu_l_apriscatole", "game/assets/cards/hai_preso_tu_l_apriscatole.png",
                [frame(i) for i in range(4)], comment="Discarica, evento, illustrazione 32x32")
