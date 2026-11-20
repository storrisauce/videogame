"""Fienile Fumante (Patate, struttura comune) — 48x48: un fienilino di assi color ruggine con tetto a due falde
spezzate, portone con la croce bianca e dal fienile esce un fumo grigio che brilla un po' di verde.
"Il fumo fa bene. Dice il fienile." Idle: 4 fotogrammi di sbuffi che salgono (ciclo continuo)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

MURO = ("legno_1", "ruggine_1", "ruggine_2", "ruggine_4")    # assi dipinte, ormai color ruggine
TETTO = ("legno_1", "legno_3", "legno_4", "legno_4")
FUMO = ("ferro_4", "ferro_4", "ferro_6", "ferro_6")


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


# sagoma del frontone (tetto "a mansarda" da fienile)
L, R, BOT, EAVE, KNEE, TOP = 11, 37, 42, 28, 22, 15


def frame(i):
    s = Sprite(48, 48)
    s.shadow(24, 42.5, 18, 2.8)
    cx = (L + R) / 2
    # tetto: la falda vista dall'alto (dietro) e il bordo spesso del frontone
    s.polygon([(L - 2.5, EAVE + 1), (L - 0.5, KNEE - 1), (cx, TOP - 3), (R + 0.5, KNEE - 1), (R + 2.5, EAVE + 1)], TETTO, shade=False)
    # muro del frontone
    wall = s.polygon([(L, BOT), (L, EAVE), (L + 3, KNEE + 1), (cx, TOP + 1.5), (R - 3, KNEE + 1), (R, EAVE), (R, BOT)],
                     MURO, shade=False)
    s.outline()
    # assi verticali del muro, luce a sinistra e ombra sotto la gronda
    for x in range(L, R):
        for y in range(TOP, BOT):
            if (x, y) in wall:
                if (x - L) % 4 == 3:
                    s.px(x, y, "ruggine_1")
                elif x <= L + 1:
                    s.px(x, y, "ruggine_4")
    for (x, y) in wall:
        if s.get(x, y - 1) in ("legno_1", "legno_3", "legno_4", None) and y > TOP:
            s.px(x, y, "ruggine_1")
    # assi del tetto: righe chiare e scure alternate lungo la falda
    for y in range(TOP - 3, EAVE + 2):
        for x in range(L - 3, R + 4):
            if s.get(x, y) == "legno_4" and (x, y) not in wall:
                if (x + y) % 4 == 0:
                    s.px(x, y, "legno_3")
    # portone con cornice e croce bianche
    dl, dr, dt = 17, 30, 31
    for x in range(dl, dr + 1):
        for y in range(dt, BOT):
            edge = x in (dl, dr) or y == dt
            diag = (x - dl) * (BOT - 1 - dt) == (y - dt) * (dr - dl) or (dr - x) * (BOT - 1 - dt) == (y - dt) * (dr - dl)
            mid = x == (dl + dr) // 2 or x == (dl + dr) // 2 + 1
            if edge:
                s.px(x, y, "legno_9")
            elif mid:
                s.px(x, y, "ruggine_1")
    for k in range(0, 11):                                 # le X sulle due ante
        for (a, b) in ((dl + 1, (dl + dr) // 2 - 1), ((dl + dr) // 2 + 2, dr - 1)):
            t = k / 10
            y = round(dt + 1 + t * (BOT - 2 - dt))
            s.px(round(a + t * (b - a)), y, "legno_8")
            s.px(round(b - t * (b - a)), y, "legno_8")
    # finestra del fienile: buio, paglia che sporge
    wl, wt = 21, 21
    for x in range(wl, wl + 6):
        for y in range(wt, wt + 5):
            s.px(x, y, "legno_9" if x in (wl, wl + 5) or y in (wt, wt + 4) else "legno_1")
    for x, y in ((wl + 1, wt + 3), (wl + 2, wt + 3), (wl + 3, wt + 2), (wl + 4, wt + 3), (wl + 2, wt + 4), (wl + 4, wt + 4)):
        s.px(x, y, "legno_8")
    # fumo: tre sbuffi che salgono dalla finestra verso sinistra e crescono; a ogni fotogramma avanzano di
    # un quarto di posto, così il quarto fotogramma si ricollega al primo
    def along(u):                                        # u da 0 (finestra) a 3 (in cima)
        return 24 - 3.2 * u, 18 - 5 * u, 1.8 + 0.6 * u
    fx = Sprite(48, 48)
    puffs = []
    for k in range(3):
        u = k + i / 4
        x, y, r = along(u)
        puffs.append((x, y, r))
        blob(fx, x, y, r * 1.15, r, FUMO, hi=0.6, lo=0.1)
    fx.outline()
    for y in range(48):
        for x in range(48):
            if fx.c[y][x] is not None:
                s.px(x, y, fx.c[y][x])
    # il fumo "fa bene": un riflesso verde radio negli sbuffi più grossi
    for x, y, r in puffs[1:]:
        s.px(round(x - r * 0.4), round(y - r * 0.3), "radio_1")
    # ciuffi di germogli di patata alla base (banda Patate)
    for bx in (12, 34):
        s.px(bx, BOT - 1, "verde_3"); s.px(bx + 1, BOT - 2, "verde_3"); s.px(bx + 2, BOT - 1, "verde_3")
    return s


if __name__ == "__main__":
    Sprite.save("fienile_fumante", "game/assets/cards/fienile_fumante.png", [frame(i) for i in range(4)],
                comment="Patate, struttura 48x48")
