"""Cigno col Remo (Stagno, rara) — taglia M, il più grande degli uccelli dello Stagno: un cigno bianco dal collo
a S che galleggia composto e tiene un remo alzato sulla spalla come una mazza. "Elegante. Finché non prende il remo."
Guarda a sinistra, come gli animali del riferimento."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

P = RAMPS["oca"]                                       # ferro_2, ferro_4, ferro_6, bianco
ALA = ("ferro_2", "ferro_4", "ferro_6", "bianco")
REMO = ("ruggine_1", "legno_3", "legno_5", "legno_7")


def blob_path(s, pts, r, ramp, steps=4):
    """Collo: una fila di cerchietti lungo una spezzata (forma tonda e continua)."""
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        for k in range(steps + 1):
            t = k / steps
            s.ellipse(x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, r, r, ramp, shade=False)


def frame(i):
    s = Sprite(32, 32)
    bob = 1 if i == 1 else 0
    lift = 1 if i == 2 else 0                          # il remo si solleva: minaccia
    s.shadow(18, 26.8, 11.5, 2.2)
    s.polygon([(25, 19), (30.5, 15), (29.5, 21)], P)    # coda
    s.ellipse(19, 20.8, 10, 4.6, P)                    # corpo che galleggia
    s.ellipse(21, 16.8, 6.5, 3.6, ALA)                 # ali sollevate a conchiglia
    # collo a S, lungo e sottile
    blob_path(s, [(12.5, 19), (13.2, 15.5), (12.4, 12.5 + bob * 0.5), (10.6, 9.8 + bob)], 1.7, P)
    s.ellipse(8.6, 7.6 + bob, 3.2, 2.5, P)             # testa
    for y, x0 in ((7, 4), (8, 3), (9, 4)):             # becco arancio
        for x in range(x0, 7):
            s.px(x, y + bob, "arancio_3", "ruggine_1")
    # remo: manico nell'ala, pala stretta in alto a destra
    d = -lift
    s.line(15, 21 + d, 22, 10 + d, "legno_5", "ruggine_1")
    s.line(16, 21 + d, 23, 10 + d, "legno_3", "ruggine_1")
    s.polygon([(21.6, 9.4 + d), (25.3, 2.6 + d), (27.9, 3.2 + d), (24.6, 10.4 + d)], REMO)
    s.ellipse(15.8, 19.6, 2, 1.6, ALA, shade=False)    # punta d'ala che stringe il manico
    s.outline()
    s.px(7, 7 + bob, "inchiostro"); s.px(7, 8 + bob, "inchiostro")   # nodo nero alla base del becco
    if i == 3:
        s.px(9, 7 + bob, "ferro_4")                    # battito di ciglia
    else:
        s.px(9, 6 + bob, "inchiostro"); s.px(9, 7 + bob, "inchiostro")
    s.pixels([(14, 20), (15, 20), (16, 21), (17, 21)], "ferro_4")   # dita di piume sul manico
    # linea dell'acqua (come la papera del riferimento)
    for x in range(10, 29):
        if s.get(x, 25) is not None:
            s.px(x, 25, "acqua_6")
    # macchia radioattiva sull'ala
    s.px(25, 15, "radio_1"); s.px(26, 15, "radio_1"); s.px(26, 16, "radio_1")
    return s


if __name__ == "__main__":
    Sprite.save("cigno_col_remo", "game/assets/cards/cigno_col_remo.png", [frame(i) for i in range(4)],
                comment="Stagno, taglia M (il più grande degli uccelli)")
