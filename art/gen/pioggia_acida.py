"""Pioggia Acida (Cratere, evento raro) — illustrazione 32x32: una nuvoletta viola che fa piovere gocce radioattive
su una pozza che sfrigola e su un ombrello ormai bucherellato. "Prendete l'ombrello. Anzi, no."
Idle (evento): le gocce cadono (3 px per fotogramma, ciclo di 12 righe), la pozza fa una bollicina."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

CLOUD = ("viola_1", "viola_2", "viola_3", "viola_3")
UMB = ("acqua_1", "acqua_1", "acqua_3", "acqua_5")
POOL = ("verde_1", "verde_2", "verde_2", "radio_1")


def frame(i):
    s = Sprite(32, 32)
    s.shadow(16, 28.3, 13, 1.8)                     # ombra a terra
    # pozza acida a terra
    s.ellipse(10, 27.2, 6.5, 2.0, POOL, light=0.1, dark=5)
    # ombrello aperto piantato a terra, a destra: cupola con bordo a festoni
    dome = s.ellipse(24.5, 21.5, 6.2, 4.6, UMB, light=0.3, dark=5)
    for (x, y) in list(dome):
        if y > 21 or (y == 21 and (x - 18) % 3 == 0):
            s.c[y][x] = None; s.part[y][x] = None
    # nuvola: tre sbuffi tondi
    s.ellipse(11.5, 8.5, 5.0, 4.0, CLOUD)
    s.ellipse(18.5, 7.0, 6.0, 4.8, CLOUD)
    s.ellipse(23.5, 9.5, 4.2, 3.2, CLOUD)
    s.rect(9, 9, 18, 4, CLOUD)
    s.outline()
    # pancia della nuvola piu' scura
    for x in range(32):
        for y in range(10, 14):
            if s.get(x, y) == "viola_3" and s.get(x, y + 1) == "viola_1":
                s.px(x, y, "viola_2")
    # occhi arrabbiati della nuvola
    for x in (15, 21):
        s.px(x, 9, "inchiostro"); s.px(x, 10, "inchiostro")
    s.px(14, 8, "viola_1"); s.px(22, 8, "viola_1")
    # buchi nell'ombrello (con l'orlo bruciato) e asta col manico a uncino
    for (x, y) in ((22, 19), (26, 20)):
        s.c[y][x] = None
        s.px(x + 1, y, "acqua_1")
    s.px(24, 16, "acqua_1")
    for y in range(22, 28):
        s.px(24, y, "inchiostro")
    s.px(23, 28, "inchiostro"); s.px(22, 27, "inchiostro")
    # gocce che cadono (testa radio_2, coda radio_1), ciclo di 12 righe
    for (x, y0) in ((8, 14), (12, 18), (17, 15), (22, 13), (26, 12), (14, 23)):
        y = 14 + (y0 - 14 + i * 3) % 12
        for (yy, col) in ((y, "radio_1"), (y + 1, "radio_2")):
            if s.get(x, yy) is None and yy < 26:
                s.px(x, yy, col)
    # bollicina nella pozza e schizzo
    bx = [7, 8, 12, 11][i]
    s.px(bx, 26, "radio_2")
    if i in (1, 3):
        s.px(5, 25, "radio_1"); s.px(14, 25, "radio_1")
    return s


if __name__ == "__main__":
    Sprite.save("pioggia_acida", "game/assets/cards/pioggia_acida.png", [frame(i) for i in range(4)],
                comment="Cratere, evento, 32x32")
