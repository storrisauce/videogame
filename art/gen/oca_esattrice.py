"""Oca Esattrice (Stagno, epica) — taglia M: un'oca grigia e bianca con il berretto da esattore e il registro
delle tasse stretto sotto l'ala. "Le tasse si pagano anche dopo la fine del mondo."
Guarda a sinistra, come gli animali del riferimento."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

P = RAMPS["oca"]                                       # ferro_2, ferro_4, ferro_6, bianco
BERRETTO = ("verde_1", "verde_1", "verde_3", "verde_3")
REGISTRO = ("ruggine_1", "legno_3", "legno_3", "legno_3")


def frame(i):
    s = Sprite(32, 32)
    bob = 1 if i == 1 else 0
    s.shadow(17.5, 27.6, 10, 2.2)
    # zampe arancio
    for x0 in (13, 19):
        s.px(x0 + 1, 26, "arancio_3", "ruggine_1"); s.px(x0 + 2, 26, "arancio_3", "ruggine_1")
        s.px(x0, 27, "arancio_3", "ruggine_1"); s.px(x0 + 1, 27, "arancio_3", "ruggine_1")
    s.polygon([(23, 19), (28, 15.5), (27.5, 21.5)], P)  # coda
    s.ellipse(18, 21, 8.2, 5, P)                   # corpo
    s.ellipse(12.3, 14.5 + bob * 0.5, 2.3, 5, P, shade=False)   # collo lungo
    s.ellipse(11, 8.8 + bob, 4, 3.5, P)                # testa
    for y, x0, x1 in ((9, 6, 8), (10, 4, 8), (11, 5, 8)):   # becco
        for x in range(x0, x1):
            s.px(x, y + bob, "arancio_3", "ruggine_1")
    # berretto da esattore con visiera
    s.ellipse(11.5, 5.2 + bob, 3.8, 2, BERRETTO)
    s.rect(6, 6 + bob, 5, 1, ("inchiostro",) * 4, shade=False)
    # registro delle tasse aperto davanti al petto
    s.rect(6, 19, 9, 6, REGISTRO, shade=False)
    s.outline()
    s.px(10, 4 + bob, "verde_3"); s.px(11, 4 + bob, "verde_3")
    s.px(13, 5 + bob, "bianco")                        # stemma
    for y in (19, 20, 21, 22, 23):                     # due pagine con le righe dei conti
        for x in range(7, 14):
            s.px(x, y, "legno_9")
        s.px(10, y, "legno_3")                         # piega del libro
    for y, xs in ((20, (8, 9, 11, 12)), (22, (8, 9, 11, 12))):
        for x in xs:
            s.px(x, y, "legno_3")
    # ala che stringe il registro
    s.ellipse(19.5, 20, 4.6, 2.8, ("ferro_2", "ferro_4", "ferro_6", "ferro_6"), dark=0.3)
    s.px(15, 20, "ferro_4"); s.px(15, 21, "ferro_4")
    # occhio severo, battito al fotogramma 3
    if i == 3:
        s.px(9, 9 + bob, "ferro_4")
    else:
        s.px(9, 8 + bob, "inchiostro"); s.px(9, 9 + bob, "inchiostro")
    if i == 2:
        s.px(12, 22, "legno_9")                           # scrive una cifra
    # macchia radioattiva sul fianco
    s.px(24, 20, "radio_1"); s.px(24, 21, "radio_1")
    return s


if __name__ == "__main__":
    Sprite.save("oca_esattrice", "game/assets/cards/oca_esattrice.png", [frame(i) for i in range(4)],
                comment="Stagno, taglia M")
