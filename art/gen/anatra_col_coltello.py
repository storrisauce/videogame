"""Anatra col Coltello (Stagno, comune) — taglia S: un'anatra bianca da cortile, bandana verde da predona,
che galleggia su una pozza e punta in avanti un coltello da cucina. "Qua. Dammi le scatolette. Qua."
Guarda a sinistra, come gli animali del riferimento."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

P = RAMPS["oca"]                                       # piume bianche, contorno ferro_2
BECCO = ("ruggine_1", "arancio_3", "arancio_3", "arancio_3")
BANDANA = ("verde_1", "verde_3", "verde_3", "verde_3")
LAMA = ("ferro_2", "ferro_4", "ferro_4", "ferro_4")
MANICO = ("ruggine_1", "ruggine_1", "ruggine_1", "ruggine_1")


def frame(i):
    s = Sprite(32, 32)
    bob = 1 if i == 1 else 0
    s.shadow(17, 26.6, 10, 2.2)
    s.polygon([(21, 21), (27.5, 15.5), (27, 21.5)], P)  # coda all'insu'
    s.ellipse(18.5, 21.5, 8, 4.8, P)                   # corpo che galleggia
    s.ellipse(13.5, 18 + bob * 0.5, 3.2, 3.2, P, shade=False)   # collo
    s.ellipse(12, 13.5 + bob, 4.5, 4.3, P)             # testa
    for y, x0 in ((14, 6), (15, 5), (16, 6)):           # becco tondo a spatola
        for x in range(x0, 9):
            s.px(x, y + bob, "arancio_3", "ruggine_1")
    # bandana da predona: fascia sulla fronte e nodo dietro la testa
    s.rect(8, 10 + bob, 9, 2, BANDANA, shade=False)
    ky = 10 + bob + (1 if i == 2 else 0)
    s.px(17, ky, "verde_3", "verde_1"); s.px(18, ky + 1, "verde_3", "verde_1")
    # coltello da cucina: lama larga puntata in avanti, manico stretto nell'ala
    s.polygon([(1.5, 19.0), (9, 18.0), (9, 21.0), (3, 21.0)], LAMA, shade=False)
    s.rect(9, 19, 3, 2, MANICO, shade=False)
    s.outline()
    for x in range(3, 9):                              # filo della lama, luccica al fotogramma 2
        s.px(x, 18 if x > 4 else 19, "bianco")
    if i == 2:
        s.px(6, 19, "bianco"); s.px(7, 19, "bianco")
    # ala piegata che stringe il manico
    s.ellipse(17.5, 20.6, 5.4, 2.6, ("ferro_2", "ferro_4", "ferro_6", "ferro_6"), dark=0.3)
    s.px(12, 20, "ferro_4"); s.px(12, 21, "ferro_4")
    s.px(17, 16, "ferro_4"); s.px(18, 16, "ferro_4")    # attacco del collo
    # occhio cattivo (1x2) con sopracciglio, battito al fotogramma 3
    if i == 3:
        s.px(10, 14 + bob, "ferro_4")
    else:
        s.px(10, 13 + bob, "inchiostro"); s.px(10, 14 + bob, "inchiostro")
    s.px(11, 12 + bob, "verde_1")
    # linea dell'acqua (come la papera del riferimento)
    for x in range(12, 27):
        if s.get(x, 25) is not None:
            s.px(x, 25, "acqua_6")
    # macchia radioattiva sul fianco
    s.px(23, 18, "radio_1"); s.px(24, 18, "radio_2"); s.px(24, 19, "radio_1")
    return s


if __name__ == "__main__":
    Sprite.save("anatra_col_coltello", "game/assets/cards/anatra_col_coltello.png", [frame(i) for i in range(4)],
                comment="Stagno, taglia S")
