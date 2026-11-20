"""Carota Urlatrice (Patate, rara) — taglia S alta: una carota piantata nella sua zolla che urla a bocca spalancata,
occhi sbarrati, ciuffo dritto per lo spavento e lineette dell'urlo. "Più ne pianti, più urlano."
Guarda a sinistra, come gli animali del riferimento."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

C = RAMPS["carota"]                                      # ruggine_1, arancio_1, arancio_2, arancio_3
ZOLLA = ("legno_1", "legno_1", "legno_3", "legno_3")     # terra scura della banda Patate
CIUFFO = ("verde_1", "verde_1", "verde_3", "verde_4")


def blob(s, cx, cy, rx, ry, ramp, hi=0.78, lo=0.38, lx=-0.45, ly=-0.75):
    """Ellisse con luce "sferica" dall'alto a sinistra: macchia chiara in alto a sinistra, mezzaluna scura in basso a destra."""
    o, d, b, l = ramp
    pts = set()
    lz = (1 - lx * lx - ly * ly) ** 0.5
    for y in range(s.h):
        for x in range(s.w):
            u, v = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
            r2 = u * u + v * v
            if r2 > 1:
                continue
            k = u * lx + v * ly + (1 - r2) ** 0.5 * lz
            s.c[y][x] = l if k > hi else (b if k > lo else d)
            s.part[y][x] = o
            pts.add((x, y))
    return pts


def lathe(s, cx, profile, ramp, hi=0.55, lo=-0.45):
    """Corpo "tornito": profile = {riga: mezza larghezza}. Luce a sinistra, ombra a destra, riga per riga."""
    o, d, b, l = ramp
    pts = set()
    for y, hw in profile.items():
        for x in range(s.w):
            u = (x + 0.5 - cx) / hw
            if abs(u) > 1:
                continue
            s.c[y][x] = l if u < -hi else (d if u > -lo else b)
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


# mezza larghezza della carota riga per riga (spalle tonde in alto, punta nella terra)
PROFILE = {8: 3.6, 9: 5.4, 10: 6.4, 11: 6.7, 12: 6.6, 13: 6.3, 14: 5.9, 15: 5.4, 16: 4.9, 17: 4.4, 18: 4.0,
           19: 3.6, 20: 3.2, 21: 2.8, 22: 2.4, 23: 2.0, 24: 1.6}


def frame(i):
    s = Sprite(32, 32)
    jx = [0, 1, 0, 1][i]                                 # trema per l'urlo
    cx = 16 + jx
    s.shadow(16, 27.4, 9.5, 2.2)
    # ciuffo: tre foglie dritte per lo spavento (si agitano)
    w = [0, 1, 0, -1][i]
    s.polygon([(cx - 1, 9), (cx + 1, 9), (cx + 1.5 + w * 0.5, 1), (cx - 1.5 + w * 0.5, 2)], CIUFFO, shade=False)
    s.polygon([(cx - 2, 9), (cx - 0.5, 8), (cx - 5 + w, 2), (cx - 7 + w, 3.5)], CIUFFO, shade=False)
    s.polygon([(cx + 0.5, 8), (cx + 2, 9), (cx + 7 - w, 4), (cx + 5.5 - w, 2.5)], CIUFFO, shade=False)
    body = lathe(s, cx + 0.5, PROFILE, C)
    # zolla
    soil = blob(s, 16, 25.4, 8, 2.6, ZOLLA, hi=0.75, lo=0.05)
    s.seam(soil, "legno_3")
    tidy(s)
    s.outline()
    # luce sulle foglie (lato sinistro)
    for fx, fy in ((cx - 1, 3), (cx - 1, 5), (cx - 5 + w, 4), (cx + 5 - w, 4)):
        if s.get(fx, fy) == "verde_3":
            s.px(fx, fy, "verde_4")
    # anelli della carota (solchi corti sul lato in ombra)
    for ry, rx in ((14, cx + 3), (17, cx + 1), (20, cx - 1)):
        s.px(rx, ry, "arancio_1"); s.px(rx + 1, ry, "arancio_1")
        # occhi sbarrati: bulbo bianco 2x2 con pupilla 1 px, sopracciglia alzate
    for ex in (cx - 5, cx - 1):
        s.px(ex, 10, "bianco"); s.px(ex + 1, 10, "bianco"); s.px(ex, 11, "bianco"); s.px(ex + 1, 11, "bianco")
        s.px(ex, 11 if i != 2 else 10, "inchiostro")
    # bocca spalancata (si allarga e stringe a tempo con l'urlo)
    big = i in (0, 2)
    mx, my = cx - 4, 13
    hgt = 5 if big else 4
    for y in range(my, my + hgt):
        for x in range(mx, mx + 3):
            s.px(x, y, "inchiostro")
    s.px(mx, my, "arancio_2"); s.px(mx + 2, my, "arancio_2")            # angoli tondi
    s.px(mx, my + hgt - 1, "arancio_2"); s.px(mx + 2, my + hgt - 1, "arancio_2")
    s.px(mx + 1, my + hgt - 2, "ruggine_1")                               # lingua
    # lineette dell'urlo davanti alla bocca
    off = 0 if big else 1
    for (x0, y0, x1, y1) in ((7, 11, 8, 12), (5, 15, 7, 15), (7, 18, 8, 17)):
        s.line(x0 - off + jx, y0, x1 - off + jx, y1, "bianco")
    return s


if __name__ == "__main__":
    Sprite.save("carota_urlatrice", "game/assets/cards/carota_urlatrice.png", [frame(i) for i in range(4)],
                comment="Patate, taglia S alta")
