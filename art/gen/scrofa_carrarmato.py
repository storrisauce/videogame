"""Scrofa Carrarmato (Porcile, rara) — taglia L (48x48): una scrofa enorme che "ha mangiato un trattore": al posto delle
zampe ha i cingoli, sulla schiena le spunta il tubo di scappamento che sbuffa fumo, sul fianco una piastra imbullonata.
"Ha mangiato un trattore. Il trattore era d'accordo." Guarda a sinistra.
Idle: respiro (corpo giu' di 1 px nei fotogrammi 1-2), lo sbuffo di fumo sale, battito di ciglia al 3."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

PIG = ("rosa_1", "rosa_3", "rosa_4", "rosa_4")
SNOUT = ("rosa_1", "rosa_3", "rosa_3", "rosa_3")
TRACK = ("notte", "ferro_1", "ferro_2", "ferro_4")
L = RAMPS["lamiera"]                      # ferro_1, ferro_2, ferro_4, ferro_5
PIPE = ("notte", "ferro_1", "ferro_2", "ferro_4")
SMOKE = ("ferro_4", "ferro_4", "ferro_5", "ferro_5")


def frame(i):
    s = Sprite(48, 48)
    b = 1 if i in (1, 2) else 0                      # respiro
    s.shadow(24.5, 42.6, 18.5, 2.6)
    # cingoli (due, quello dietro si vede appena)
    s.ellipse(10.5, 37.5, 4.5, 4.5, TRACK)
    s.ellipse(37.5, 37.5, 4.5, 4.5, TRACK)
    s.rect(10, 33, 28, 9, TRACK)
    # corpo
    body = s.ellipse(26.5, 26 + b, 15.5, 10.5, PIG)
    # piastra imbullonata sul fianco
    s.rect(24, 25 + b, 13, 7, L)
    # tubo di scappamento
    s.rect(31, 9 + b, 4, 9, PIPE)
    s.rect(30, 8 + b, 6, 2, PIPE)
    # testa
    head = s.ellipse(15, 25 + b, 9, 8, PIG)
    head |= s.polygon([(6, 14 + b), (13, 17 + b), (8.5, 21.5 + b)], PIG, shade=False)      # orecchie
    head |= s.polygon([(24, 14 + b), (17, 17 + b), (21.5, 21.5 + b)], PIG, shade=False)
    s.seam(head, "rosa_3")
    s.rect(4, 26 + b, 8, 6, SNOUT, shade=False)                                            # muso
    s.outline()
    # interno orecchie
    for (x, y) in ((8, 16), (9, 17), (10, 18), (9, 18), (22, 16), (21, 17), (20, 18), (21, 18)):
        s.px(x, y + b, "rosa_3")
    # muso
    for x in range(4, 12):
        s.px(x, 26 + b, "rosa_4")                                                          # bordo alto illuminato
    for (x, y) in ((6, 28), (6, 29), (9, 28), (9, 29)):
        s.px(x, y + b, "rosa_1")                                                           # narici
    # occhi 1x2, battito al 3
    for x in (10, 18):
        if i == 3:
            s.px(x, 25 + b, "rosa_1")
        else:
            s.px(x, 23 + b, "inchiostro"); s.px(x, 24 + b, "inchiostro")
    # bulloni della piastra e riflesso
    for (x, y) in ((26, 27), (34, 27), (26, 30), (34, 30)):
        s.px(x, y + b, "ferro_1")
    # ruote dei cingoli
    for cx in (10, 17, 24, 31, 37):                 # ruote
        for (dx, dy, c) in ((0, -1, "ferro_4"), (1, -1, "ferro_4"), (-1, 0, "ferro_4"), (0, 0, "ferro_4"), (1, 0, "ferro_4"),
                            (2, 0, "ferro_2"), (0, 1, "ferro_2"), (1, 1, "ferro_2"), (-1, 1, "ferro_4")):
            s.px(cx + dx, 38 + dy, c)
    for x in range(9, 40, 3):                       # tacche del battistrada sotto
        s.px(x, 41, "notte")
    # fumo: uno sbuffo che sale
    puff = Sprite(48, 48)
    py = [5.5, 4.5, 3.5, 2.5][i] + b
    puff.ellipse(33.5 + i * 0.5, py, [2.6, 2.9, 3.1, 2.8][i], [2.0, 2.2, 2.3, 2.0][i], SMOKE)
    if i >= 2:
        puff.ellipse(37.5 + i * 0.4, py - 3.5, 1.6, 1.4, SMOKE)
    puff.outline()
    for y in range(48):
        for x in range(48):
            if puff.c[y][x] and s.c[y][x] is None:
                s.c[y][x] = puff.c[y][x]
    # macchia radio sul dorso
    s.px(37, 21 + b, "radio_1"); s.px(38, 21 + b, "radio_2"); s.px(38, 22 + b, "radio_1")
    return s


if __name__ == "__main__":
    Sprite.save("scrofa_carrarmato", "game/assets/cards/scrofa_carrarmato.png", [frame(i) for i in range(4)],
                comment="Porcile, taglia L")
