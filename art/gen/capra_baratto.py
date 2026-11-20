"""Capra Baratto (Discarica, rara) — taglia M: una capra color sabbia che si porta in groppa una sedia di legno
legata con lo spago, pronta a scambiarla. "Ti do questa sedia per mezza scatoletta."
Guarda a sinistra, come gli animali del riferimento."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

C = RAMPS["capra"]                                      # legno_3, legno_7, legno_8, legno_9


# sedia vista di 3/4, disegnata pixel per pixel: 1 = legno_1 (contorno), 3/4/5 = legno_3/4/5, . = vuoto
SEDIA_PX = [
    "11111111",
    "15555551",
    "13333331",
    "151..141",
    "15444441",
    "13333331",
    "151..141",
    "151..141",
]
SEDUTA_PX = [
    "1111111111111",
    "1555555555551",
    "1444444444441",
    "1111111111111",
    "141......141.",
    "141......141.",
    "111......111.",
]
TONI = {"1": "legno_1", "3": "legno_3", "4": "legno_4", "5": "legno_5"}


def stampa(s, x0, y0, rows):
    for dy, row in enumerate(rows):
        for dx, ch in enumerate(row):
            if ch in TONI:
                s.px(x0 + dx, y0 + dy, TONI[ch])


def frame(i):
    s = Sprite(32, 32)
    b = 1 if i in (1, 2) else 0                         # la testa si abbassa
    s.shadow(18, 27, 11, 2.2)
    for x in (13, 23):                                  # zampe dietro
        s.rect(x, 22, 2, 5, C, shade=False)
    body = s.ellipse(18.5, 19.5, 8.0, 4.2, C)
    for x in (11, 21):                                  # zampe davanti
        s.rect(x, 22, 2, 5, C, shade=False)
    s.rect(26, 15, 2, 2, C, shade=False)                # codina
    neck = s.polygon([(6.5, 13 + b), (10.5, 12 + b), (14, 18), (10, 20)], C)
    head = s.ellipse(8, 13 + b, 3.2, 2.9, C)
    head |= s.ellipse(5.2, 15.4 + b, 2.4, 1.9, C, shade=False)   # muso
    s.polygon([(10, 12.2 + b), (14, 13.2 + b), (10.5, 14.5 + b)], C, shade=False)   # orecchio
    # corna a uncino che girano all'indietro, oltre la sagoma della testa (chiaro sopra, scuro sotto)
    for x, y in ((8, 9), (9, 8), (10, 7), (11, 7), (12, 8), (13, 9), (14, 10)):
        s.px(x, y + b, "ferro_4", "legno_1")
    for x, y in ((9, 9), (10, 8), (11, 8), (12, 9), (13, 10), (14, 11)):
        s.px(x, y + b, "ferro_2", "legno_1")
    s.outline()
    s.seam(head | neck)
    # barbetta, occhio, narice
    for x, y, c in ((5, 18, "legno_8"), (6, 18, "legno_8"), (4, 18, "legno_3"), (7, 18, "legno_3"),
                    (5, 19, "legno_3"), (6, 19, "legno_3"), (7, 17, "legno_3")):   # barbetta
        s.px(x, y + b, c)
    if i == 3:
        s.px(7, 13 + b, "legno_3")
    else:
        s.px(7, 12 + b, "inchiostro"); s.px(7, 13 + b, "inchiostro")
    s.px(3, 15 + b, "legno_3")
    for x in (11, 12, 13, 14, 21, 22, 23, 24):          # zoccoli scuri
        s.px(x, 26, "legno_3")
    s.px(17, 20, "radio_1"); s.px(18, 20, "radio_2"); s.px(18, 21, "radio_1")   # macchia radioattiva
    # la sedia legata in groppa
    stampa(s, 19, 3, SEDIA_PX)
    stampa(s, 14, 11, SEDUTA_PX)
    return s


if __name__ == "__main__":
    Sprite.save("capra_baratto", "game/assets/cards/capra_baratto.png",
                [frame(i) for i in range(4)], comment="Discarica, taglia M")
