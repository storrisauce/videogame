"""Zucca Lievitata (Patate, epica) — taglia L: una zucca enorme e gonfia come un impasto che lievita: gli spicchi
tirano, dalle crepe sbuca la pasta chiara e il picciolo è spinto in cima. Faccia sazia e soddisfatta.
"Ogni giorno è un po' più grande. Nessuno sa cosa mangi." Respira gonfiandosi (idle). Guarda a sinistra."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

Z = RAMPS["zucca"]                                       # ruggine_1, arancio_1, arancio_3, arancio_4
PASTA = ("legno_3", "legno_8", "legno_9", "legno_9")     # impasto che esce dalle crepe
ZOLLA = ("legno_1", "legno_1", "legno_3", "legno_3")     # terra scura della banda Patate
PICCIOLO = ("verde_1", "verde_1", "verde_3", "verde_3")


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


# spicchi (scarto dal centro, mezza larghezza, mezza altezza): prima i lontani, poi i vicini
LOBES = [(-12.5, 6.5, 9.5, 1), (12.5, 6.5, 9.5, 1), (-7, 8.5, 12, 0.5), (7, 8.5, 12, 0.5), (0, 8.5, 12.8, 0)]


def frame(i):
    s = Sprite(48, 48)
    g = (0, 1, 2, 1)[i]                                  # respiro: si gonfia di 1-2 px e torna
    base = 42                                            # la zucca poggia sempre su questa riga
    s.shadow(24, 43.4, 22.5 + g * 0.5, 2.6)
    soil = blob(s, 24, 42.4, 21 + g * 0.5, 2.6, ZOLLA, hi=0.75, lo=0.05)
    lobes = []
    for dx, rx, ry, lift in LOBES:
        ry2 = ry + g * 0.5
        lobes.append(blob(s, 24 + dx * (1 + g * 0.03), base - lift - ry2, rx + g * 0.4, ry2, Z, hi=0.72, lo=0.2))
    for k in range(len(lobes) - 1):                      # ogni spicchio tiene solo i pixel rimasti visibili
        for later in lobes[k + 1:]:
            lobes[k] = lobes[k] - later
    for reg in lobes[2:]:                                # costole: scure in alto, sfumano in basso
        s.seam(reg, "costola")
    for y in range(s.h):
        for x in range(s.w):
            if s.c[y][x] == "costola":
                s.c[y][x] = "ruggine_1" if y < base - 10 else "arancio_1"
    # pasta che esce dalle crepe: un bel cuscino in cima e due sbuffi fra gli spicchi
    top = base - 2 * (12.8 + g * 0.5)
    blob(s, 24, top + 3.2 - g * 0.3, 6.5 + g * 0.3, 3.2 + g * 0.3, PASTA, hi=0.6, lo=0.0)
    blob(s, 28.5, top + 6.5, 2, 2.6 + g * 0.4, PASTA, hi=0.6, lo=0.0)     # una colatina di pasta
    # picciolo spinto in cima dalla pasta
    ty = int(top) - g // 2
    s.polygon([(23, ty + 2), (26, ty + 2), (27.5, ty - 3), (25, ty - 3.5)], PICCIOLO, shade=False)
    tidy(s)
    s.outline()
    # luce sulla pasta e sul picciolo
    s.px(25, ty - 2, "verde_3")
    # faccia sazia (a sinistra): occhi 1x2, guance gonfie, sorrisetto
    ey = int(base - 15 - g * 0.5)
    if i == 3:
        s.px(17, ey + 1, "ruggine_1"); s.px(18, ey + 1, "ruggine_1")
        s.px(21, ey + 1, "ruggine_1"); s.px(22, ey + 1, "ruggine_1")
    else:
        for x in (18, 22):
            s.px(x, ey, "inchiostro"); s.px(x, ey + 1, "inchiostro")
    my = ey + 5
    s.px(18, my - 1, "ruggine_1"); s.px(19, my, "ruggine_1"); s.px(20, my, "ruggine_1")
    s.px(21, my, "ruggine_1"); s.px(22, my - 1, "ruggine_1")
    s.px(17, ey + 3, "arancio_4"); s.px(23, ey + 3, "arancio_4")
    # tocco nucleare: la pasta brilla un po' (nessuno sa cosa mangi)
    s.px(29, int(top) + 8 + g // 2, "radio_1"); s.px(30, int(top) + 3, "radio_1"); s.px(31, int(top) + 3, "radio_2")
    return s


if __name__ == "__main__":
    Sprite.save("zucca_lievitata", "game/assets/cards/zucca_lievitata.png", [frame(i) for i in range(4)],
                comment="Patate, taglia L")
