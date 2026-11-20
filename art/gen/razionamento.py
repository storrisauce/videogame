"""Razionamento (Stagno, evento) — illustrazione 32x32: una scatoletta aperta con il timbro rosso del razionamento
e dentro una sola fava; accanto, mezza fava "per la capra". "Una fava a testa. Mezza per la capra."
Idle: la fava trema nella scatoletta, il coperchio luccica."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

LATTA = RAMPS["lamiera"]                               # ferro_1, ferro_2, ferro_4, ferro_5
ETICHETTA = ("ferro_1", "acqua_3", "acqua_4", "acqua_4")
FAVA = ("verde_1", "verde_3", "verde_4", "verde_5")


def frame(i):
    s = Sprite(32, 32)
    hop = 1 if i == 1 else 0
    s.shadow(16.5, 26.6, 10, 2.2)
    # coperchio strappato, piegato all'indietro e appoggiato al bordo
    s.ellipse(17.5, 8.4, 5.2, 2.6, LATTA)
    # corpo cilindrico (luce a sinistra, ombra a destra)
    s.ellipse(15.5, 24, 6, 2, LATTA, shade=False)
    s.rect(9.5, 13, 12, 11, LATTA, shade=False)
    s.ellipse(15.5, 12.5, 6, 2.5, LATTA, shade=False)  # bocca
    s.ellipse(25, 25, 2, 1.5, FAVA)                    # mezza fava per terra
    s.outline()
    for y in range(13, 26):
        for x in range(9, 22):
            c = s.get(x, y)
            if c == "ferro_4":
                if x <= 10:
                    s.px(x, y, "ferro_5")
                elif x >= 19:
                    s.px(x, y, "ferro_2")
    # bocca: bordo chiaro, dentro buio
    for x in range(11, 21):
        s.px(x, 11, "ferro_5") if s.get(x, 11) == "ferro_4" else None
    for y in (12, 13):
        for x in range(11, 21):
            if s.get(x, y) in ("ferro_4", "ferro_5", "ferro_2"):
                s.px(x, y, "ferro_1")
    for x in range(11, 21):
        s.px(x, 14, "ferro_5")                         # labbro davanti
    s.px(10, 12, "ferro_5"); s.px(10, 13, "ferro_5"); s.px(21, 12, "ferro_2"); s.px(21, 13, "ferro_2")
    # l'unica fava che spunta dalla latta
    s.ellipse(15.5, 12.4 - hop, 2.3, 1.5, FAVA)
    s.px(14, 12 - hop, "verde_5")
    # etichetta azzurra con il timbro rosso storto
    for y in range(16, 22):
        for x in range(10, 22):
            if s.get(x, y) in ("ferro_2", "ferro_4", "ferro_5"):
                s.px(x, y, "acqua_3" if x >= 19 else "acqua_4")
    seal = [(14, 16), (15, 16), (16, 16), (13, 17), (17, 17), (13, 18), (17, 18), (13, 19), (17, 19),
            (14, 20), (15, 20), (16, 20), (15, 17), (15, 18), (15, 19), (14, 17)]
    s.pixels(seal, "rosso_2")                          # timbro tondo del razionamento: "1" a testa
    # costolatura sotto l'etichetta
    for x in range(11, 21):
        s.px(x, 23, "ferro_2")
    # coperchio: riflesso che passa
    s.px(14, 7, "ferro_5"); s.px(15, 7, "ferro_5")
    if i == 2:
        s.px(16, 7, "bianco"); s.px(17, 7, "bianco")
    s.px(26, 24, "verde_5"); s.px(26, 25, "verde_5")   # taglio della mezza fava
    if i == 3:
        s.px(16, 12, "radio_1")                        # la fava brilla un attimo
    return s


if __name__ == "__main__":
    Sprite.save("razionamento", "game/assets/cards/razionamento.png", [frame(i) for i in range(4)],
                comment="Stagno, evento, illustrazione 32x32")
