"""Patata Depressa (Patate, comune) — taglia S: una patata afflosciata nella sua zolla, sopracciglia tristi,
bocca all'ingiù, una lacrima e la sua nuvoletta personale che le piove in testa.
"Sta male lei, così stanno bene gli altri." Guarda a sinistra, come gli animali del riferimento."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

P = RAMPS["patata"]                                      # legno_3, legno_5, legno_7, legno_8
ZOLLA = ("legno_1", "legno_1", "legno_3", "legno_5")     # terra scura della banda Patate
NUVOLA = ("ferro_2", "ferro_2", "ferro_4", "ferro_4")    # nuvoletta grigia, tutta sua


def blob(s, cx, cy, rx, ry, ramp, hi=0.78, lo=0.38, lx=-0.45, ly=-0.75):
    """Ellisse con luce "sferica" dall'alto a sinistra: macchia chiara in alto a sinistra, mezzaluna scura in basso a destra."""
    o, d, b, l = ramp
    pts = set()
    lz = (1 - lx * lx - ly * ly) ** 0.5
    for y in range(s.h):
        for x in range(s.w):
            u, v = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
            r2 = u * u + v * v
            if r2 > 1:
                continue
            k = u * lx + v * ly + (1 - r2) ** 0.5 * lz
            s.c[y][x] = l if k > hi else (b if k > lo else d)
            s.part[y][x] = o
            pts.add((x, y))
    return pts


def tidy(s):
    """Toglie i pixel isolati che sporgono (meno di 2 vicini pieni): niente "peli" sui contorni tondi."""
    for _ in range(2):
        kill = []
        for y in range(s.h):
            for x in range(s.w):
                if s.c[y][x] is None:
                    continue
                n = sum(1 for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)) if s.get(x + dx, y + dy) is not None)
                if n <= 1:
                    kill.append((x, y))
        for x, y in kill:
            s.c[y][x] = None
            s.part[y][x] = None


def frame(i):
    s = Sprite(32, 32)
    sag = 1 if i in (1, 2) else 0                        # sospiro: si affloscia di 1 px
    s.shadow(16, 27.4, 10.5, 2.2)
    # patata: corpo largo e afflosciato, un bitorzolo dietro a destra
    blob(s, 21, 19 + sag, 4.2, 4.4, P)
    blob(s, 15, 18.5 + sag * 0.5, 9, 6.6 - sag * 0.5, P)
    # zolla davanti: un mucchietto di terra
    soil = blob(s, 16, 25.3, 10.2, 2.4, ZOLLA, hi=0.75, lo=0.2)
    s.seam(soil, "legno_3")
    # la nuvoletta personale (sale e scende di 1 px, al contrario della patata)
    cy = 6 - (i in (1, 2))
    blob(s, 12.5, cy + 0.8, 2.8, 2.1, NUVOLA)
    blob(s, 16, cy, 3.4, 2.8, NUVOLA)
    blob(s, 19.5, cy + 1, 2.6, 1.9, NUVOLA)
    tidy(s)
    s.outline()
    # zollette sulla terra e macchie della buccia
    s.px(11, 25, "legno_5"); s.px(20, 24, "legno_5"); s.px(22, 26, "legno_1")
    s.px(19, 14 + sag, "legno_5"); s.px(18, 21 + sag, "legno_5")
    # faccia (a sinistra): sopracciglia tristi, occhi 1x2, bocca all'ingiù
    ey = 17 + sag
    s.px(9, ey - 1, "legno_1"); s.px(10, ey - 2, "legno_1")          # sopracciglio sinistro (alto verso il centro)
    s.px(13, ey - 2, "legno_1"); s.px(14, ey - 1, "legno_1")         # sopracciglio destro
    if i == 3:
        s.px(9, ey + 1, "legno_1"); s.px(13, ey + 1, "legno_1")      # occhi chiusi (battito)
    else:
        for x in (9, 13):
            s.px(x, ey, "inchiostro"); s.px(x, ey + 1, "inchiostro")
    my = ey + 4
    s.px(10, my, "legno_1"); s.px(11, my - 1, "legno_1"); s.px(12, my - 1, "legno_1"); s.px(13, my, "legno_1")
    # lacrima che scende sulla guancia
    ty = [ey + 2, ey + 3, ey + 4, ey + 2][i]
    s.px(8, ty, "acqua_5")
    # pioggia: tre gocce che cadono a turno sulla testa
    for k, x in enumerate((12, 15, 19)):
        y = cy + 4 + (i + k * 2) % 4 * 1.5
        if y < 12 + sag:
            s.px(x, int(y), "acqua_5")
    # tocco nucleare: macchia radio sul bitorzolo
    s.px(22, 18 + sag, "radio_1"); s.px(23, 18 + sag, "radio_2"); s.px(22, 19 + sag, "radio_1")
    return s


if __name__ == "__main__":
    Sprite.save("patata_depressa", "game/assets/cards/patata_depressa.png", [frame(i) for i in range(4)],
                comment="Patate, taglia S")
