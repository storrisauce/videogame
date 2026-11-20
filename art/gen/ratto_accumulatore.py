"""Ratto Accumulatore (Discarica, comune) — taglia XS in un fotogramma da 32: un ratto marrone seduto davanti al suo
mucchio di tappi di bottiglia, con un tappo stretto tra le zampe. "Ha 400 tappi di bottiglia. Non te ne dà neanche uno."
Guarda a sinistra, come gli animali del riferimento."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

R = RAMPS["terra"]                                      # legno_1, legno_3, legno_4, legno_5
ROSA = ("legno_1", "rosa_3", "rosa_3", "rosa_3")
O = "legno_1"                                           # contorno comune di ratto e tappi
# tappi: (faccia, bordo zigrinato)
TAPPI = {"r": ("rosso_2", "rosso_1"), "f": ("ferro_5", "ferro_3"), "g": ("giallo_2", "arancio_1")}
# mucchio, dal fondo al davanti: (x, y, colore)
MUCCHIO = [(18, 13, "f"), (22, 13, "r"),
           (16, 15, "r"), (20, 15, "g"), (24, 15, "f"),
           (14, 17, "f"), (18, 17, "f"), (22, 17, "r"), (26, 17, "f"),
           (16, 19, "g"), (20, 19, "r"), (24, 19, "f"),
           (14, 21, "r"), (18, 21, "f"), (22, 21, "f"), (26, 21, "r")]


def tappo(s, x, y, k):
    """Tappo visto dall'alto di 3/4: 5x4 con contorno, faccia sopra e bordo zigrinato sotto."""
    face, rim = TAPPI[k]
    for dx in range(1, 4):
        s.px(x + dx, y, O, O); s.px(x + dx, y + 3, O, O)
        s.px(x + dx, y + 1, face, O)
        s.px(x + dx, y + 2, rim if dx != 2 else face if k == "f" else rim, O)
    s.px(x, y + 1, O, O); s.px(x, y + 2, O, O); s.px(x + 4, y + 1, O, O); s.px(x + 4, y + 2, O, O)
    s.px(x + 2, y + 2, rim, O)


def frame(i):
    s = Sprite(32, 32)
    b = 1 if i in (1, 2) else 0
    s.shadow(18, 26.8, 11.5, 2.2)
    for x, y, k in MUCCHIO:
        tappo(s, x, y - (1 if (i == 2 and (x, y) == (22, 13)) else 0), k)
    # il ratto, davanti a sinistra
    t = 0 if i < 2 else 1
    s.rect(13, 25, 6, 1, ROSA, shade=False)             # coda rosa che striscia a terra
    s.px(19, 24 + t, "rosa_3", O); s.px(20, 24, "rosa_3", O)
    body = s.ellipse(11, 21.5, 4.3, 4.2, R)
    s.rect(8, 25, 2, 1, R, shade=False); s.rect(12, 25, 2, 1, R, shade=False)   # zampe
    head = s.ellipse(8, 17.8 + b, 3.4, 3.0, R)
    head |= s.polygon([(3, 19.5 + b), (6.5, 17 + b), (7, 20.5 + b)], R, shade=False)  # muso a punta
    s.ellipse(10.5, 15.2 + b, 1.8, 1.8, R, shade=False)  # orecchio
    s.outline()
    s.seam(head)
    s.px(10, 15 + b, "rosa_3"); s.px(11, 15 + b, "rosa_3"); s.px(10, 14 + b, "rosa_3")   # dentro l'orecchio
    s.px(3, 19 + b, "rosa_3"); s.px(2, 19 + b, "rosa_3")  # naso
    if i == 3:
        s.px(7, 18 + b, O)
    else:
        s.px(7, 17 + b, "inchiostro"); s.px(7, 18 + b, "inchiostro")
    s.px(4, 18 + b, "legno_5")                          # luce sul muso
    # il tappo stretto tra le zampe davanti
    tappo(s, 6, 21, "g")
    s.px(6, 22, "legno_4"); s.px(10, 22, "legno_4")     # zampine che lo tengono
    return s


if __name__ == "__main__":
    Sprite.save("ratto_accumulatore", "game/assets/cards/ratto_accumulatore.png",
                [frame(i) for i in range(4)], comment="Discarica, taglia XS (fotogramma 32 per il mucchio)")
