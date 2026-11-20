"""Mucca Laser (Cratere, leggendaria) — taglia L (48x48): una mucca grande con le macchie viola del Cratere, occhi
radioattivi e un raggio laser che parte dall'occhio e sfrigola. "Fa muuu. Poi scioglie qualcosa."
Guarda a sinistra (testa di fronte, corpo di tre quarti come la mucca del riferimento).
Idle: respiro (corpo giu' di 1 px nei fotogrammi 1-2), il raggio e le scintille tremolano."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS, _in_ellipse

W = RAMPS["bianco"]                               # notte, ferro_4, ferro_5, bianco
SPOT = ("notte", "viola_1", "viola_2", "viola_2")
MUZZLE = ("notte", "pelle_1", "pelle_3", "pelle_3")
HOOF = ("notte", "notte", "notte", "notte")


def frame(i):
    s = Sprite(48, 48)
    b = 1 if i in (1, 2) else 0
    s.shadow(25, 42.5, 17.5, 2.6)
    # zampe
    for x in (15, 21, 31, 37):
        s.rect(x, 36, 3, 5, W, shade=False)
    # corpo
    body = s.ellipse(29.5, 26.5 + b, 13.5, 11, W)
    # macchie viola (solo dentro il corpo)
    for (cx, cy, rx, ry) in ((36, 20, 5.5, 4.5), (27, 31, 4.5, 3.6), (41, 30, 3.5, 4.5), (23, 19, 3, 2.4)):
        pts = [(x, y) for (x, y) in body if _in_ellipse(x, y, cx, cy + b, rx, ry)]
        s._fill(pts, SPOT, cx, cy + b, rx, ry)
    # testa di fronte
    head = s.ellipse(15, 24 + b, 7.5, 7, W)
    head |= s.polygon([(4, 18 + b), (9, 18 + b), (9, 21 + b), (5, 21 + b)], W, shade=False)     # orecchie
    head |= s.polygon([(21, 18 + b), (26, 18 + b), (25, 21 + b), (21, 21 + b)], W, shade=False)
    head |= s.polygon([(9, 15 + b), (11, 15 + b), (11, 18 + b), (9, 18 + b)], W, shade=False)   # corna
    head |= s.polygon([(19, 15 + b), (21, 15 + b), (21, 18 + b), (19, 18 + b)], W, shade=False)
    s.seam(head, "ferro_4")
    s.rect(10, 26 + b, 11, 7, MUZZLE, shade=False)                                            # muso
    s.rect(9, 27 + b, 13, 5, MUZZLE, shade=False)
    s.outline()
    # macchia viola sulla testa
    for (x, y) in ((16, 19), (17, 19), (18, 19), (17, 20), (18, 20), (18, 21)):
        s.px(x, y + b, "viola_2")
    # interno orecchie, muso
    for x in (6, 7):
        s.px(x, 20 + b, "pelle_3")
    for x in (23, 24):
        s.px(x, 20 + b, "pelle_3")
    for x in range(10, 21):
        s.px(x, 32 + b, "pelle_1")
    s.px(9, 31 + b, "pelle_1"); s.px(21, 31 + b, "pelle_1")
    for (x, y) in ((12, 28), (12, 29), (18, 28), (18, 29)):
        s.px(x, y + b, "pelle_1")
    # zoccoli
    for x in (15, 21, 31, 37):
        for dx in range(3):
            s.px(x + dx, 40, "notte")
    # occhi laser (bianco+radio) e raggi verso terra
    eyes = ((11, 23 + b), (19, 23 + b))
    for (ex, ey) in eyes:
        s.px(ex, ey, "radio_2"); s.px(ex + 1, ey, "radio_1"); s.px(ex, ey + 1, "radio_1"); s.px(ex + 1, ey + 1, "radio_1")
    # raggio laser dall'occhio sinistro, dritto verso sinistra (fuori dalla testa); tremola e fa scintille in punta
    ex, ey = eyes[0]
    tip = [1, 0, 1, 0][i]
    for x in range(ex - 1, tip - 1, -1):
        s.px(x, ey, "radio_2")
        s.px(x, ey + 1, "radio_1" if (x + i) % 2 else "radio_2")
    for (x, y) in [((1, ey - 1), (2, ey + 2)), ((0, ey - 1), (1, ey + 3)), ((2, ey - 2), (0, ey + 2)), ((1, ey - 2), (2, ey + 3))][i]:
        s.px(x, y, "radio_1")
    return s


if __name__ == "__main__":
    Sprite.save("mucca_laser", "game/assets/cards/mucca_laser.png", [frame(i) for i in range(4)],
                comment="Cratere, leggendaria, taglia L")
