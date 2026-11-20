"""Baracca di Copertoni (Discarica, struttura comune) — taglia L (48x48): una baracca con i muri fatti di copertoni
impilati, un tetto di lamiera ondulata tenuto giù da un copertone, una porta di assi e un tubo da stufa che fuma.
"Non brucia. Fuma soltanto, da undici anni." L'idle è il fumo che sale dal tubo (4 fotogrammi)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

GOMMA = ("notte", "notte", "ferro_1", "ferro_2")
LAMIERA = ("notte", "ferro_2", "ferro_3", "ferro_4")
ASSI = ("legno_1", "legno_1", "legno_3", "legno_5")
TUBO = ("legno_1", "ruggine_1", "ruggine_2", "ruggine_4")


def gomma(s, cx, cy, r=3.9):
    """Copertone in piedi visto di fronte: anello di gomma (luce in alto a sinistra) e buco scuro al centro."""
    for y in range(48):
        for x in range(48):
            dx, dy = x + 0.5 - cx, y + 0.5 - cy
            d = (dx * dx + dy * dy) ** 0.5
            if d <= r:
                if d <= r * 0.42:
                    col = "notte"
                elif dx + dy < -r * 0.6:
                    col = "ferro_3" if d > r * 0.75 and dx + dy < -r * 1.1 else "ferro_2"
                else:
                    col = "ferro_1"
                s.px(x, y, col, "notte")


def frame(i):
    s = Sprite(48, 48)
    s.shadow(24, 44.5, 21, 2.6)
    # muro di copertoni in piedi, sfalsati come mattoni (dal fondo al davanti)
    for cy, xs in ((25.5, (8, 16, 24, 32, 40)), (32.5, (6, 14, 34, 42)), (39.5, (8, 16, 32, 40))):
        for cx in xs:
            gomma(s, cx, cy)
    # porta di assi in mezzo
    s.rect(20, 30, 8, 14, ASSI, shade=False)
    # tetto di lamiera ondulata (si vede da sopra, di 3/4)
    s.polygon([(8, 12), (40, 12), (45.5, 22), (2.5, 22)], LAMIERA, shade=False)
    # tubo della stufa, dietro a destra
    s.rect(34, 10, 3, 6, TUBO, shade=False)
    s.rect(33, 9, 5, 2, TUBO, shade=False)
    s.outline()
    # ---- dettagli
    # ondine della lamiera: strisce chiare e scure, gronda scura
    for y in range(13, 22):
        for x in range(2, 46):
            if s.get(x, y) == "ferro_3" and x % 3 == 0:
                s.px(x, y, "ferro_4")
            elif s.get(x, y) == "ferro_3" and x % 3 == 2 and y > 14:
                s.px(x, y, "ferro_2")
    for x in range(3, 46):
        if s.get(x, 21) in LAMIERA[1:]:
            s.px(x, 21, "ferro_2" if x % 3 else "ferro_1")
    # toppe di ruggine sul tetto
    for x, y in ((29, 17), (30, 17), (31, 17), (30, 18), (31, 18), (32, 18), (30, 19), (40, 18), (41, 18), (6, 19), (7, 19)):
        s.px(x, y, "ruggine_2")
    for x, y in ((31, 18), (41, 19), (7, 20)):
        s.px(x, y, "ruggine_1")
    # copertone sdraiato sul tetto, per tenerlo giù: fianco di gomma (luce in alto a sinistra), nel buco la lamiera
    cx, cy = 16.5, 15.8
    for y in range(11, 21):
        for x in range(8, 26):
            u, v = (x + 0.5 - cx) / 6.4, (y + 0.5 - cy) / 3.0
            hu, hv = (x + 0.5 - cx) / 3.2, (y + 0.5 - cy + 0.3) / 1.3
            d, h = u * u + v * v, hu * hu + hv * hv
            if d <= 1 and h > 1:
                col = "ferro_1" if v < 0.1 else "notte"
                if v < -0.45 and u < 0.1:
                    col = "ferro_2"
                if h <= 1.6 and v > -0.4:                # bordo interno del buco in ombra
                    col = "notte"
                s.px(x, y, col)
            elif 1 < d <= 1.5 and v > -1.7:
                s.px(x, y, "notte")
    for x in range(11, 23):                              # fianco del copertone, sotto
        s.px(x, 19, "ferro_1" if x % 3 else "notte")
        if s.get(x, 18) == "notte" and x % 3:
            s.px(x, 18, "ferro_1")
    s.px(10, 18, "notte"); s.px(23, 18, "notte")
    # porta: assi verticali, maniglia
    for y in range(30, 44):
        s.px(23, y, "legno_1")
        s.px(20, y, "legno_5")
    for x in range(20, 28):
        s.px(x, 30, "legno_5")
    s.px(26, 37, "ferro_4"); s.px(26, 38, "ferro_2")
    # tubo: luce a sinistra
    for y in range(11, 16):
        s.px(34, y, "ruggine_4"); s.px(36, y, "ruggine_1")
    for x in range(33, 38):
        s.px(x, 9, "ruggine_4")
    s.px(34, 10, "legno_1"); s.px(35, 10, "legno_1"); s.px(36, 10, "legno_1")
    # fumo: tre sbuffi che salgono verso sinistra e si allargano; in 4 fotogrammi ognuno prende il posto del
    # successivo, così il ciclo non salta
    for k in range(3):
        t = k + i / 4
        cx, cy, r = 35.5 - 3.2 * t, 7.4 - 3.6 * t, 1.6 + 0.5 * t
        for py in range(48):
            for px_ in range(48):
                if ((px_ + 0.5 - cx) / r) ** 2 + ((py + 0.5 - cy) / r) ** 2 <= 1 and s.get(px_, py) is None:
                    s.px(px_, py, "ferro_4" if t > 2.5 or ((px_ + 0.5 - cx) + (py + 0.5 - cy) > r * 0.55) else "ferro_5")
    return s


if __name__ == "__main__":
    Sprite.save("baracca_di_copertoni", "game/assets/cards/baracca_di_copertoni.png",
                [frame(i) for i in range(4)], comment="Discarica, struttura, taglia L")
