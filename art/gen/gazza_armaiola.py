"""Gazza Armaiola (Discarica, rara) — taglia S: una gazza bianca e nera con la coda lunga dai riflessi blu, un
coltello rubato nel becco e una bandoliera di lame arrugginite sul petto. "Ruba coltelli e li regala agli amici."
Guarda a sinistra, come gli animali del riferimento."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

NERO = ("notte", "notte", "ferro_1", "ferro_2")          # piume nere: base ferro_1, luce ferro_2
BIANCO = ("notte", "ferro_5", "bianco", "bianco")
CODA = ("notte", "ferro_1", "ferro_1", "acqua_2")         # riflessi blu-verdi della coda
ZAMPE = ("notte", "notte", "ferro_1", "ferro_1")


def frame(i):
    s = Sprite(32, 32)
    b = 1 if i in (1, 2) else 0                          # testa giù di 1 px
    t = 1 if i in (2, 3) else 0                          # coda che si alza
    s.shadow(16.5, 27, 7.5, 2.2)
    s.rect(14, 23, 1, 3, ZAMPE, shade=False)            # zampe sottili
    s.rect(17, 23, 1, 3, ZAMPE, shade=False)
    s.rect(13, 25, 2, 1, ZAMPE, shade=False); s.rect(16, 25, 2, 1, ZAMPE, shade=False)
    tail = s.polygon([(19, 17.5), (27, 10 - t), (29.5, 12 - t), (21.5, 21)], CODA)
    body = s.ellipse(16.5, 19.5, 5.6, 4.6, NERO)
    head = s.ellipse(11.5, 14.2 + b, 3.5, 3.6, NERO, light=0.7)
    s.polygon([(8.5, 13 + b), (5, 14.8 + b), (8.5, 15.8 + b)], ("notte", "notte", "ferro_1", "ferro_1"), shade=False)  # becco
    s.outline()
    for (x, y) in head:                                  # stacca la testa solo dove tocca il corpo
        if (x + 1, y) in body or (x, y + 1) in body:
            if (x + 1, y) not in head or (x, y + 1) not in head:
                s.px(x, y, "notte")
    for x in (9, 13):                                    # arrotonda la cima della testa
        s.c[10 + b][x] = None
        s.px(x, 11 + b, "notte")
    # pancia bianca e macchia bianca dell'ala
    for (x, y) in body:
        if y >= 20 and x <= 17 and s.get(x, y) in NERO[1:]:
            s.px(x, y, "bianco" if y < 22 else "ferro_5")
    for x, y in ((17, 17), (18, 17), (19, 17), (18, 18), (19, 18), (20, 18)):
        s.px(x, y, "bianco")
    s.px(20, 17, "ferro_5"); s.px(21, 18, "ferro_5")
    # bandoliera arrugginita con due lame
    for x, y in ((12, 17), (13, 18), (14, 19), (15, 19), (16, 20), (17, 21), (18, 22)):
        s.px(x, y, "ruggine_2")
    for x, y in ((14, 18), (16, 19)):
        s.px(x, y, "ferro_5")
    # riflesso blu lungo la coda (una riga sotto il bordo alto)
    for (x, y) in tail:
        if (x, y) not in body and s.get(x, y) == "ferro_1" and s.get(x, y - 1) == "notte" and x > 20:
            s.px(x, y + 1, "acqua_2") if s.get(x, y + 1) == "ferro_1" else None
    # occhio lucido
    if i == 3:
        s.px(10, 13 + b, "notte")
    else:
        s.px(10, 13 + b, "bianco")
    # coltello rubato nel becco: manico di legno, lama lucida
    for x in (7, 8, 9):
        s.px(x, 16 + b, "legno_3")
    for x in (2, 3, 4, 5, 6):
        s.px(x, 16 + b, "ferro_5")
    s.px(3, 16 + b, "bianco"); s.px(4, 16 + b, "bianco")
    for x in range(1, 7):
        s.px(x, 17 + b, "notte")
    s.px(1, 16 + b, "notte"); s.px(2, 15 + b, "notte")
    for x in range(3, 6):
        s.px(x, 15 + b, "notte")
    return s


if __name__ == "__main__":
    Sprite.save("gazza_armaiola", "game/assets/cards/gazza_armaiola.png",
                [frame(i) for i in range(4)], comment="Discarica, taglia S")
