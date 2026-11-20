"""Il Trattore Senziente (sopravvissuto) — veicolo, taglia L (48x48, corpo circa 38x30), di tre quarti verso sinistra.
Trattorino rosso arrugginito con la faccia sul muso (fari = occhi, griglia = bocca coi denti), ruota grande dietro,
marmitta che sbuffa e la fascia tricolore da sindaco sul cofano: "Ordinanza del sindaco".
Contorno selettivo: lamiera rossa -> rosso_1, gomme -> notte. Idle: borbotta (sobbalzo di 1 px) e sbuffa fumo."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

ROSSO = ("rosso_1", "rosso_1", "rosso_2", "rosso_3")
GOMMA = ("notte", "notte", "ferro_1", "ferro_2")
FUMO = ("ferro_2", "ferro_2", "bianco", "bianco")


def wheel(s, cx, cy, r, rim, hub):
    s.ellipse(cx, cy, r, r + 0.4, GOMMA, light=0.6, dark=0.45)
    s.ellipse(cx, cy, rim, rim + 0.3, ("ruggine_1", "giallo_1", "giallo_1", "giallo_2"), light=0.4, dark=0.5)
    s.ellipse(cx, cy, hub, hub, ("notte", "ferro_1", "ferro_1", "ferro_1"), shade=False)


def frame(i):
    s = Sprite(48, 48)
    rum = 1 if i in (1, 3) else 0          # borbottio del motore: la carrozzeria sobbalza
    s.shadow(24.5, 43, 18.5, 2.6)
    # parafango (resta visibile solo l'arco sopra la ruota)
    fender = s.ellipse(34, 25.5 + rum, 9.5, 5, ROSSO, light=0.3)
    # sedile e volante
    s.rect(31, 14 + rum, 6, 3, ("notte", "ferro_1", "ferro_1", "ferro_2"))     # schienale
    s.rect(30, 17 + rum, 7, 4, ("notte", "ferro_1", "ferro_2", "ferro_2"))     # seduta
    s.line(27, 16 + rum, 27, 20 + rum, "ferro_1", outline="notte")
    s.line(25, 15 + rum, 29, 15 + rum, "notte", outline="notte")
    # ruota grande posteriore
    wheel(s, 34.5, 33.5, 8.5, 4.6, 1.5)
    # marmitta
    s.rect(21, 12 + rum, 2, 9, ("notte", "ferro_1", "ferro_1", "ferro_2"))
    s.rect(20, 11 + rum, 4, 2, ("notte", "ferro_1", "ferro_2", "ferro_2"), shade=False)
    # cofano paffuto
    hood = s.ellipse(19, 27 + rum, 12.5, 7.2, ROSSO, light=0.25, dark=0.6)
    # muso con la faccia
    face = s.ellipse(9.5, 28 + rum, 6, 6.8, ("rosso_1", "rosso_1", "rosso_2", "rosso_3"), light=0.75, dark=0.6)
    # ruota anteriore
    wheel(s, 17.5, 37.5, 5, 2.4, 0.9)
    s.outline()
    s.seam(face, "rosso_1")
    y0 = 28 + rum
    # fari = occhi rotondi (giallo con riflesso bianco e pupilla)
    for ex in (5, 10):
        for dx in range(3):
            for dy in range(3):
                s.px(ex + dx, y0 - 4 + dy, "giallo_2")
        s.px(ex, y0 - 4, "bianco")
        if i == 2:   # battito: palpebra di lamiera
            for dx in range(3):
                s.px(ex + dx, y0 - 4, "rosso_1"); s.px(ex + dx, y0 - 3, "rosso_1")
        else:
            s.px(ex + 1, y0 - 3, "inchiostro"); s.px(ex + 1, y0 - 2, "inchiostro")
    # griglia = bocca con i denti
    for x in range(5, 13):
        s.px(x, y0 + 1, "inchiostro"); s.px(x, y0 + 3, "inchiostro")
        s.px(x, y0 + 2, "bianco" if x % 2 else "ferro_2")
    s.px(4, y0 + 2, "inchiostro"); s.px(13, y0 + 2, "inchiostro")
    # fascia tricolore da sindaco, in diagonale sul cofano
    for k, col in enumerate(("verde_3", "bianco", "rosso_2")):
        for t in range(0, 12):
            x, y = 17 + t + k, 20 + rum + t
            if (x, y) in hood and (x, y) not in face and s.get(x, y) not in (None, "rosso_1") or (x, y) in hood and t < 2:
                s.px(x, y, col)
    # riflesso sulla lamiera e macchie di ruggine (a chiazze, non pixel sparsi)
    for pts, col in ((((25, 29), (26, 29), (27, 29), (25, 30), (26, 30), (27, 30), (28, 30), (26, 31), (27, 31)), "ruggine_1"),
                     (((36, 21), (37, 21), (38, 21), (37, 22), (38, 22)), "ruggine_1"),
                     ):
        for x, y in pts:
            if s.get(x, y + rum) not in (None, "rosso_1"):
                s.px(x, y + rum, col)
    # sbuffi di fumo dalla marmitta (salgono e si allargano)
    off = (0, 1, 2, 3)[i]
    s.ellipse(22 - off * 0.4, 8.5 - off, 2.0 + off * 0.3, 1.7 + off * 0.2, FUMO)
    if i >= 2:
        s.ellipse(19.5 - (i - 2), 4 - (i - 2), 1.4, 1.2, FUMO, shade=False)
    return s


if __name__ == "__main__":
    Sprite.save("hero_trattore", "game/assets/heroes/trattore.png", [frame(i) for i in range(4)],
                comment="Sopravvissuto, veicolo L")
