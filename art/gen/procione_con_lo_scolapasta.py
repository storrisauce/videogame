"""Procione con lo Scolapasta (Discarica, comune) — taglia S: un procione grigio con uno scolapasta smaltato
(arrugginito) in testa a fare da elmo, manico che sporge di lato. "Ha trovato un elmo. E una lasagna vecchissima."
Guarda a sinistra, come gli animali del riferimento."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

P = RAMPS["procione"]                                   # notte, ferro_1, ferro_2, ferro_4
MUSO = ("notte", "ferro_4", "ferro_5", "bianco")
SCOLA = ("legno_2", "ruggine_1", "ruggine_2", "ruggine_4")


def frame(i):
    s = Sprite(32, 32)
    b = 1 if i in (1, 2) else 0                         # testa ed elmo si abbassano di 1 px
    t = 1 if i in (2, 3) else 0                         # la punta della coda ondeggia
    s.shadow(17, 26.8, 9.5, 2.2)
    # coda ad anelli, dietro al corpo, che sale in diagonale
    tail = s.ellipse(23.5, 19.5, 3.4, 3.6, P) | s.ellipse(26, 15.5 - t * 0.5, 2.6, 3.2, P)
    body = s.ellipse(17.5, 21, 6.6, 4.7, P)             # corpo
    s.rect(12, 24, 2, 3, P, shade=False)                # zampe
    s.rect(20, 24, 2, 3, P, shade=False)
    # scolapasta capovolto: piede ad anello in cima, cupola, bordo, due manici
    for y, x0, x1 in ((10, 10, 13), (11, 8, 15), (12, 7, 16), (13, 7, 16), (14, 6, 17)):
        s.rect(x0, y + b, x1 - x0 + 1, 1, SCOLA, shade=False)
    head = s.ellipse(11.5, 18.8 + b, 5.6, 4.2, P)       # testa (copre il fondo della cupola)
    head |= s.polygon([(4.5, 20 + b), (9, 18.5 + b), (9.5, 22 + b)], MUSO, shade=False)   # muso a punta
    s.rect(5, 15 + b, 14, 1, SCOLA, shade=False)        # bordo
    s.rect(3, 14 + b, 2, 2, SCOLA, shade=False)         # manici
    s.rect(19, 14 + b, 2, 2, SCOLA, shade=False)
    s.outline()
    s.seam(head)                                        # stacca la testa dal corpo
    for y in range(11, 15):                             # luce a sinistra, ombra a destra
        row = [x for x in range(32) if s.get(x, y + b) == "ruggine_2"]
        s.px(row[0], y + b, "ruggine_4"); s.px(row[-1], y + b, "ruggine_1")
    for x in range(8, 16):
        s.px(x, 11 + b, "ruggine_4")
    s.px(15, 11 + b, "ruggine_1")
    for x in range(5, 19):
        s.px(x, 15 + b, "ruggine_4")
    s.px(18, 15 + b, "ruggine_2")
    for x, y in ((3, 14), (19, 14)):
        s.px(x, y + b, "ruggine_4"); s.px(x + 1, y + b, "ruggine_2")
        s.px(x, y + 1 + b, "ruggine_2"); s.px(x + 1, y + 1 + b, "ruggine_1")
    for x, y in ((9, 13), (11, 13), (13, 13), (15, 13), (10, 11), (12, 11)):   # buchi
        s.px(x, y + b, "legno_2")
    # anelli della coda (strisce diagonali, solo sulla coda)
    for (x, y) in tail:
        if (x, y) not in body and s.get(x, y) in P[1:]:
            s.px(x, y, "ferro_1" if ((x - y) // 2) % 2 == 0 else ("ferro_4" if x + y < 41 else "ferro_2"))
    # mascherina scura con occhi lucidi
    for x in range(7, 15):
        if x != 11:
            s.px(x, 17 + b, "notte")
    for x in (8, 9, 10, 12, 13, 14):
        s.px(x, 18 + b, "notte")
    if i != 3:
        s.px(9, 17 + b, "bianco"); s.px(13, 17 + b, "bianco")
    for x in (8, 9, 10, 11, 12, 13):                    # guance chiare
        s.px(x, 19 + b, "ferro_5")
    s.px(11, 18 + b, "ferro_5")
    s.px(5, 20 + b, "inchiostro"); s.px(4, 20 + b, "inchiostro")   # naso
    return s


if __name__ == "__main__":
    Sprite.save("procione_con_lo_scolapasta", "game/assets/cards/procione_con_lo_scolapasta.png",
                [frame(i) for i in range(4)], comment="Discarica, taglia S")
