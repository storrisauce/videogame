"""Pontile dei Predoni (Stagno, struttura) — taglia L 48x48: un pontile di assi su una pozza, con la sbarra del
pedaggio a strisce e la bandiera verde dei predoni col coltello. "Si paga il pedaggio. In dita."
Idle: la bandiera sventola e l'acqua increspa intorno ai pali."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

ACQUA = ("acqua_1", "acqua_3", "acqua_4", "acqua_4")
ASSE = ("legno_1", "legno_5", "legno_7", "legno_7")
PALO = ("legno_1", "legno_3", "legno_3", "legno_5")
BANDIERA = ("verde_1", "verde_1", "verde_3", "verde_3")


def frame(i):
    s = Sprite(48, 48)
    w = i % 2
    s.shadow(26, 42, 20, 2.6)
    # pozza dello stagno: il pontile ci entra da sinistra
    s.ellipse(27, 31, 19, 11, ACQUA, dark=0.6)
    # pali che escono dall'acqua sotto il piano
    for x in (13, 23, 33):
        s.rect(x, 31, 3, 4, PALO, shade=False)
    # palo della bandiera in fondo al pontile
    s.rect(36, 6, 2, 18, PALO, shade=False)
    # bandiera dei predoni a coda di rondine che sventola
    s.polygon([(36, 7), (36, 15), (28, 15 + w), (30.5, 11.5), (27.5, 8 + w)], BANDIERA, shade=False)
    # piano del pontile: assi viste dall'alto e bordo davanti
    s.rect(3, 23, 37, 7, ASSE, shade=False)
    s.rect(3, 30, 37, 2, ("legno_1", "legno_3", "legno_3", "legno_3"), shade=False)
    # sbarra del pedaggio con il suo paletto all'ingresso
    s.rect(14, 16, 3, 9, PALO, shade=False)
    s.rect(3, 17, 11, 2, ("legno_1", "bianco", "bianco", "bianco"), shade=False)
    s.outline()
    # fughe fra le assi (ogni asse 4 px)
    for x in (7, 11, 15, 19, 23, 27, 31, 35):
        for y in range(23, 30):
            if s.get(x, y) == "legno_7":
                s.px(x, y, "legno_5")
    for x in range(3, 40):
        s.px(x, 29, "legno_5")
    s.px(39, 23, "legno_1"); s.px(39, 24, "legno_1")   # ultima asse un po' più corta
    # strisce rosse della sbarra
    for x in range(3, 14):
        if (x // 3) % 2 == 1:
            s.px(x, 17, "rosso_2"); s.px(x, 18, "rosso_2")
    s.px(14, 16, "legno_5"); s.px(36, 6, "legno_5")
    # coltello bianco sulla bandiera
    fy = 11 + w
    s.pixels([(31, fy + 1), (32, fy), (33, fy)], "bianco")
    s.px(34, fy, "legno_3")
    # increspature intorno ai pali (si allargano di 1 px)
    for x in (13, 23, 33):
        s.px(x - 1 - w, 35, "acqua_6"); s.px(x + 3 + w, 35, "acqua_6")
    for x, y in ((40, 28), (20, 39), (34, 39), (42, 34), (24, 21), (33, 20)):
        dx = 1 if i >= 2 else 0
        s.px(x + dx, y, "acqua_6"); s.px(x + 1 + dx, y, "acqua_6")
    # bagliore radioattivo nell'acqua
    s.px(28, 38, "radio_1"); s.px(29, 38, "radio_1"); s.px(28, 37 + w, "radio_1")
    return s


if __name__ == "__main__":
    Sprite.save("pontile_dei_predoni", "game/assets/cards/pontile_dei_predoni.png", [frame(i) for i in range(4)],
                comment="Stagno, struttura, taglia L")
