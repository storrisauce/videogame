"""Rapa Rancorosa (Patate, comune) — taglia S: una rapa tonda (viola sopra, bianca sotto) piantata nella zolla,
sopracciglia aggrottate, bocca storta e una nuvoletta di fumo dalle orecchie... cioè dalle foglie.
"Non ha un cervello, ma non dimentica." Guarda a sinistra, come gli animali del riferimento."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

R = RAMPS["rapa"]                                        # viola_1, viola_2, viola_3, viola_4
BIANCA = ("viola_1", "legno_8", "legno_9", "legno_9")    # la parte bassa della rapa, color panna
ZOLLA = ("legno_1", "legno_1", "legno_3", "legno_3")     # terra scura della banda Patate
FOGLIA = ("verde_1", "verde_1", "verde_3", "verde_4")


def blob(s, cx, cy, rx, ry, ramp, hi=0.78, lo=0.38, lx=-0.45, ly=-0.75, low=None, split=None):
    """Ellisse con luce "sferica" dall'alto a sinistra. Con `low` e `split(x)`, sotto la riga split(x) usa la rampa `low`."""
    pts = set()
    lz = (1 - lx * lx - ly * ly) ** 0.5
    for y in range(s.h):
        for x in range(s.w):
            u, v = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
            r2 = u * u + v * v
            if r2 > 1:
                continue
            o, d, b, l = low if (low and y >= split(x)) else ramp
            k = u * lx + v * ly + (1 - r2) ** 0.5 * lz
            s.c[y][x] = l if k > hi else (b if k > lo else d)
            s.part[y][x] = o
            pts.add((x, y))
    return pts


def tidy(s):
    """Toglie i pixel isolati che sporgono (meno di 2 vicini pieni): niente "peli" sui contorni tondi."""
    for _ in range(2):
        kill = []
        for y in range(s.h):
            for x in range(s.w):
                if s.c[y][x] is None:
                    continue
                n = sum(1 for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)) if s.get(x + dx, y + dy) is not None)
                if n <= 1:
                    kill.append((x, y))
        for x, y in kill:
            s.c[y][x] = None
            s.part[y][x] = None


def frame(i):
    s = Sprite(32, 32)
    b = 1 if i in (1, 2) else 0                          # sbuffa: si abbassa di 1 px
    s.shadow(16, 27.4, 9.5, 2.2)
    # foglie: due larghe e una piccola, un po' rigide (tremano di rabbia nel fotogramma 2)
    w = 1 if i == 2 else 0
    s.polygon([(15, 10 + b), (17, 10 + b), (13.5 - w, 2 + b), (10.5 - w, 4 + b)], FOGLIA, shade=False)
    s.polygon([(16, 10 + b), (18, 10 + b), (22.5 + w, 4 + b), (20, 2 + b)], FOGLIA, shade=False)
    s.polygon([(16, 10 + b), (17, 10 + b), (17.5, 6 + b), (16, 6 + b)], FOGLIA, shade=False)
    # radice a fittone che entra nella terra
    s.polygon([(14.5, 20), (18.5, 20), (16.5, 27)], BIANCA, shade=False)
    # bulbo: viola sopra, panna sotto (il confine fa un'onda)
    blob(s, 16.5, 15.8 + b * 0.5, 7.4, 6.4 - b * 0.5, R, low=BIANCA, split=lambda x: 19 + b - round(((x + 0.5 - 16.5) / 7.4) ** 2 * 2.5))
    soil = blob(s, 16.5, 25.8, 7, 2.3, ZOLLA, hi=0.75, lo=0.05)
    s.seam(soil, "legno_3")
    tidy(s)
    s.outline()
    # luce sulle foglie e nervature
    s.px(12 - w, 5 + b, "verde_4"); s.px(13 - w, 6 + b, "verde_4"); s.px(20 + w, 5 + b, "verde_4")
    # faccia arrabbiata (a sinistra): sopracciglia a V, occhi 1x2, bocca storta all'ingiù
    ey = 13 + b
    s.px(10, ey - 2, "inchiostro"); s.px(11, ey - 2, "inchiostro"); s.px(12, ey - 1, "inchiostro")
    s.px(15, ey - 1, "inchiostro"); s.px(16, ey - 2, "inchiostro"); s.px(17, ey - 2, "inchiostro")
    if i == 3:
        s.px(11, ey + 1, "inchiostro"); s.px(16, ey + 1, "inchiostro")    # occhi socchiusi
    else:
        for x in (11, 16):
            s.px(x, ey, "inchiostro"); s.px(x, ey + 1, "inchiostro")
    my = ey + 3
    s.px(11, my + 1, "inchiostro"); s.px(12, my, "inchiostro"); s.px(13, my, "inchiostro")
    s.px(14, my, "inchiostro"); s.px(15, my + 1, "inchiostro")
    return s


if __name__ == "__main__":
    Sprite.save("rapa_rancorosa", "game/assets/cards/rapa_rancorosa.png", [frame(i) for i in range(4)],
                comment="Patate, taglia S")
