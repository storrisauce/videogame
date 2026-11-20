"""Silos Instabile (Pollaio, struttura rara) — taglia L (48x48, corpo ~18x36): un silos di lamiera che pende,
tetto rosso a cupola, toppa arrugginita, crepa che perde luce radioattiva, cartello giallo di pericolo e una
lampada d'allarme in cima. "Vietato fumare. Vietato respirare forte."
Le strutture non respirano: l'idle è la lampada che lampeggia e uno sbuffo che esce dalla crepa (4 fotogrammi)."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

ROOF = ("rosso_1", "rosso_1", "rosso_2", "rosso_3")
X0, X1 = 17, 30          # pareti del silos (colonne, estremi inclusi)
TOP, BOT = 12, 42        # righe del cilindro


def wall_color(x):
    """Ombreggiatura del cilindro: luce a sinistra, ombra a destra."""
    if x == X0 or x == X1:
        return "ferro_1"
    if x <= X0 + 2:
        return "ferro_5"
    if x >= X1 - 3:
        return "ferro_2"
    return "ferro_4"


def lean(y):
    """Il silos pende verso destra: più si sale, più si sposta (a scalini regolari)."""
    return (BOT - y) // 8


def frame(i):
    s = Sprite(48, 48)
    s.shadow(24.5, 43.6, 12.0, 2.6)
    # cupola rossa: mezza ellisse sopra il cilindro, gronda scura che sporge di 1 px
    d = lean(TOP)
    dome = s.ellipse(24.0 + d, TOP + 1.0, 8.0, 7.0, ROOF, shade=False)
    for x, y in dome:
        if y > TOP:
            s.c[y][x] = None; s.part[y][x] = None
    # cilindro di lamiera con anelli di rinforzo
    for y in range(TOP + 1, BOT + 1):
        d = lean(y)
        for x in range(X0, X1 + 1):
            col = wall_color(x)
            if (y - TOP) % 6 == 5 and X0 < x < X1:
                col = "ferro_2" if x < X1 - 3 else "ferro_1"
            s.px(x + d, y, col, "ferro_1")
    for x in range(X0 + 1, X1):                              # fondo appoggiato a terra
        s.px(x, BOT + 1, "ferro_1")
    # lampada d'allarme in cima (il vetro lampeggia)
    d = lean(TOP)
    lx, ly = 23 + d, TOP - 9
    on = i in (0, 1)
    for x in (lx - 1, lx, lx + 1, lx + 2):
        s.px(x, ly + 2, "ferro_2", "ferro_1")
    s.px(lx, ly, "rosso_2" if on else "rosso_1", "rosso_1"); s.px(lx + 1, ly, "rosso_2" if on else "rosso_1", "rosso_1")
    s.px(lx, ly + 1, "rosso_2" if on else "rosso_1", "rosso_1"); s.px(lx + 1, ly + 1, "rosso_2" if on else "rosso_1", "rosso_1")
    s.outline()
    for x in range(X0 - 1 + d, X1 + 2 + d):                  # gronda
        s.px(x, TOP + 1, "rosso_1")
    for x, y in [(19, TOP - 2), (19, TOP - 3), (20, TOP - 4), (21, TOP - 4), (22, TOP - 5)]:   # riflesso sulla cupola
        s.px(x + d, y, "rosso_3")
    for x in range(X1 - 2, X1 + 2):                           # lato in ombra della cupola
        for y in range(TOP - 3, TOP + 1):
            if s.get(x + d, y) == "rosso_2":
                s.px(x + d, y, "rosso_1")
    if on:
        s.px(lx, ly, "giallo_2")
        if i == 0:                                            # bagliore
            s.px(lx - 2, ly, "rosso_2"); s.px(lx + 3, ly, "rosso_2")
            s.px(lx, ly - 2, "rosso_2"); s.px(lx + 1, ly - 2, "rosso_2")
    # toppa arrugginita rivettata (in basso a sinistra)
    for y in range(33, 38):
        dd = lean(y)
        for x in range(19, 24):
            s.px(x + dd, y, "ruggine_2")
    for x, y in [(19, 33), (23, 33), (19, 37), (23, 37)]:
        s.px(x + lean(y), y, "ferro_1")
    # cartello giallo di pericolo con il punto esclamativo
    sx, sy = 20, 18
    dd = lean(sy + 3)
    tri = [(3, 0), (2, 1), (3, 1), (4, 1), (1, 2), (2, 2), (3, 2), (4, 2), (5, 2),
           (1, 3), (2, 3), (3, 3), (4, 3), (5, 3), (0, 4), (1, 4), (2, 4), (3, 4), (4, 4), (5, 4), (6, 4)]
    for x, y in tri:
        s.px(sx + x + dd, sy + y, "giallo_2")
    for x in range(-1, 8):
        s.px(sx + x + dd, sy + 5, "inchiostro")
    for x, y in [(3, -1), (2, 0), (4, 0), (1, 1), (5, 1), (0, 2), (6, 2), (0, 3), (6, 3), (-1, 4), (7, 4)]:
        s.px(sx + x + dd, sy + y, "inchiostro")
    s.px(sx + 3 + dd, sy + 1, "inchiostro"); s.px(sx + 3 + dd, sy + 2, "inchiostro"); s.px(sx + 3 + dd, sy + 4, "inchiostro")
    # crepa che perde luce radioattiva (a destra)
    crack = [(27, 26), (26, 27), (27, 28), (28, 29), (27, 30), (26, 31), (27, 32), (28, 33)]
    for k, (x, y) in enumerate(crack):
        s.px(x + lean(y), y, "inchiostro")
        if k in (1, 2, 4, 5):
            s.px(x + 1 + lean(y), y, "radio_1")
    s.px(28 + lean(28), 28, "radio_2" if i % 2 == 0 else "radio_1")
    s.px(27 + lean(31), 31, "radio_2" if i % 2 == 1 else "radio_1")
    # sbuffo verde che esce dalla crepa e sale
    puff = [
        [(33, 28)],
        [(34, 27), (35, 27), (34, 26)],
        [(35, 25), (36, 25), (36, 24), (35, 24)],
        [(37, 22)],
    ][i]
    for x, y in puff:
        s.px(x, y, "radio_1")
    return s


if __name__ == "__main__":
    Sprite.save("silos_instabile", "game/assets/cards/silos_instabile.png", [frame(i) for i in range(4)],
                comment="Pollaio, struttura, taglia L")
