"""Bunker di Lamiera (Porcile, struttura comune) — taglia L (48x48): una baracca a mezza botte di lamiera ondulata,
rattoppata con una toppa arrugginita imbullonata; dalla porta buia sbircia un maiale.
"Entrare e' facile. Uscire dipende dal maiale."
Idle (struttura, niente respiro): il maiale nella porta sbatte le palpebre e arriccia il naso, lo sfiatatoio fuma."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS, _in_ellipse

L = RAMPS["lamiera"]                         # ferro_1, ferro_2, ferro_4, ferro_5
RUST = ("ruggine_1", "ruggine_1", "ruggine_2", "ruggine_2")
DARK = ("notte", "notte", "notte", "notte")
PIG = ("rosa_1", "rosa_3", "rosa_4", "rosa_4")
PIPE = ("notte", "ferro_1", "ferro_2", "ferro_4")
SMOKE = ("ferro_4", "ferro_4", "ferro_5", "ferro_5")


def frame(i):
    s = Sprite(48, 48)
    s.shadow(24, 42.4, 19.5, 2.6)
    # sfiatatoio storto sul tetto
    s.rect(31, 12, 3, 8, PIPE)
    s.rect(30, 11, 5, 2, PIPE)
    # la mezza botte: ellisse tagliata a terra
    hut = s.ellipse(24, 42, 18, 26, L, light=0.75, dark=2)
    for (x, y) in list(hut):
        if y > 41:
            s.c[y][x] = None; s.part[y][x] = None
    # porta ad arco
    door = s.ellipse(24, 42, 6, 9.5, DARK, shade=False)
    for (x, y) in list(door):
        if y > 41:
            s.c[y][x] = None; s.part[y][x] = None
    s.outline()
    # ondulazione: righe verticali chiare/scure che seguono la botte
    for x in range(7, 42):
        if (x - 24) % 4 == 0 or (x - 24) % 4 == 2:
            for y in range(48):
                if s.get(x, y) in ("ferro_4", "ferro_5") and s.part[y][x] == "ferro_1":
                    s.px(x, y, "ferro_2" if (x - 24) % 4 == 2 else s.get(x, y))
    # lato in ombra a destra
    for (x, y) in hut:
        if y <= 41 and s.get(x, y) in ("ferro_4", "ferro_5") and not _in_ellipse(x, y, 22, 42, 15, 24):
            s.px(x, y, "ferro_2")
    # cornice della porta
    for (x, y) in door:
        if y <= 41 and any((x + dx, y + dy) not in door for dx, dy in ((1, 0), (-1, 0), (0, -1))):
            s.px(x, y, "ferro_1")
    # toppa arrugginita imbullonata
    patch = Sprite(48, 48)
    patch.rect(10, 24, 7, 6, RUST)
    patch.outline()
    for y in range(48):
        for x in range(48):
            if patch.c[y][x] and s.c[y][x] is not None:
                s.c[y][x] = patch.c[y][x]
    for (x, y) in ((10, 24), (16, 24), (10, 29), (16, 29)):
        s.px(x, y, "ferro_1")
    # bulloni sulla lamiera
    for (x, y) in ((30, 30), (36, 32), (13, 35), (20, 22), (28, 20)):
        s.px(x, y, "ferro_1")
    # il maiale che sbircia dalla porta
    sn = 1 if i == 2 else 0                       # naso arricciato (sale di 1 px)
    s.rect(21, 36 - sn, 6, 3, PIG, shade=False)
    for x in (21, 26):
        s.px(x, 36 - sn, "notte"); s.px(x, 38 - sn, "notte")
    s.px(22, 37 - sn, "rosa_1"); s.px(25, 37 - sn, "rosa_1")
    for x in range(22, 26):
        s.px(x, 39 - sn, "rosa_1")
    for x in (22, 25):                             # occhi che brillano nel buio (chiusi al fotogramma 3)
        s.px(x, 34, "bianco" if i != 3 else "ferro_1")
    # fumo dallo sfiatatoio
    puff = Sprite(48, 48)
    py = [8.5, 7.5, 6.5, 5.5][i]
    puff.ellipse(32.5 + i * 0.4, py, [1.8, 2.2, 2.4, 2.0][i], [1.5, 1.8, 1.9, 1.6][i], SMOKE)
    puff.outline()
    for y in range(48):
        for x in range(48):
            if puff.c[y][x] and s.c[y][x] is None:
                s.c[y][x] = puff.c[y][x]
    # una goccia radio che cola dalla toppa
    s.px(13, 31, "radio_1"); s.px(13, 32, "radio_1")
    return s


if __name__ == "__main__":
    Sprite.save("bunker_di_lamiera", "game/assets/cards/bunker_di_lamiera.png", [frame(i) for i in range(4)],
                comment="Porcile, struttura, taglia L")
