"""Tacchino Furioso (Pollaio, rara) — taglia M (corpo ~24x22 in 32x32): un tacchino con la coda a ventaglio
spalancata, le sopracciglia aggrottate e due sbuffi di vapore dalla testa; una forchetta è rimasta piantata nella
coda. "Ha saltato il pranzo delle feste. Non lo perdona." Guarda a sinistra.
Idle: la testa si abbassa di 1 px (1), il ventaglio si gonfia (2), gli sbuffi di vapore salgono e svaniscono."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

BODY = ("legno_1", "legno_1", "legno_3", "legno_4")
FAN_TIP = ("legno_3", "legno_9", "legno_9", "legno_9")
FAN_BAND = ("legno_3", "legno_3", "legno_3", "legno_3")
FAN_IN = ("legno_3", "legno_7", "legno_7", "legno_7")
FAN_CORE = ("legno_3", "legno_5", "legno_5", "legno_5")
HEAD = ("rosso_1", "rosso_1", "rosso_2", "rosso_4")    # faccia rossa di rabbia
FAN_BOTTOM = 21                                          # sotto questa riga il ventaglio è nascosto dal corpo


def frame(i):
    s = Sprite(32, 32)
    bob = 1 if i == 1 else 0
    puff = 0.5 if i == 2 else 0.0
    s.shadow(17.0, 26.6, 10.0, 2.3)
    # ventaglio della coda (dietro a tutto): punte chiare, fascia scura, piume, centro
    s.ellipse(20.0, 15.0, 11.2 + puff, 9.6 + puff, FAN_TIP, shade=False)
    s.ellipse(20.0, 15.3, 9.8 + puff, 8.3 + puff, FAN_BAND, shade=False)
    s.ellipse(20.0, 15.6, 8.6 + puff, 7.2 + puff, FAN_IN, shade=False)
    s.ellipse(20.0, 16.4, 5.4, 4.6, FAN_CORE, shade=False)
    for y in range(32):                      # la base del ventaglio si stringe verso il corpo
        for x in range(32):
            if y >= FAN_BOTTOM - max(0, x - 24):
                s.c[y][x] = None; s.part[y][x] = None
    # penne: raggi nel ventaglio
    for (x0, y0, x1, y1) in [(14, 14, 11, 10), (17, 12, 16, 8), (23, 12, 24, 8), (26, 14, 29, 10)]:
        s.line(x0, y0, x1, y1 - (1 if i == 2 else 0), "legno_5")
    # corpo
    body = s.ellipse(17.5, 21.0, 7.8, 5.4, BODY)
    s.px(14, 26, "arancio_4"); s.px(20, 26, "arancio_4")              # zampe
    # collo e testa
    s.ellipse(11.0, 17.5 + bob, 2.2, 3.4, BODY)
    s.ellipse(9.0, 13.5 + bob, 2.7, 2.8, HEAD)
    s.outline()
    s.seam(body, "legno_1")
    # ala: piume più chiare sul fianco
    for x in range(16, 22):
        s.px(x, 19, "legno_4")
    for x in range(17, 22):
        s.px(x, 21, "legno_1")
    # forchetta piantata nella coda
    fy = 1
    for y in range(fy + 3, 9):
        s.px(25, y, "inchiostro")
    for x in range(23, 28):
        s.px(x, fy + 2, "inchiostro")
    for x in (23, 25, 27):
        s.px(x, fy, "inchiostro"); s.px(x, fy + 1, "inchiostro")
    # becco, bargiglio che pende sul becco, caruncola sotto il mento
    s.px(5, 13 + bob, "arancio_4"); s.px(6, 13 + bob, "arancio_4")
    s.px(6, 14 + bob, "rosso_2"); s.px(6, 15 + bob, "rosso_1")
    s.px(9, 16 + bob, "rosso_2"); s.px(9, 17 + bob, "rosso_1")
    # occhio arrabbiato: bianco con pupilla verso il becco, sopracciglio che scende verso il becco
    s.px(8, 13 + bob, "inchiostro"); s.px(9, 13 + bob, "bianco")
    s.px(7, 12 + bob, "inchiostro"); s.px(8, 12 + bob, "inchiostro"); s.px(9, 11 + bob, "inchiostro"); s.px(10, 11 + bob, "inchiostro")
    if i == 3:                                   # strizza l'occhio dalla rabbia
        s.px(9, 13 + bob, "inchiostro")
    # vapore della rabbia: due sbuffi che salgono e svaniscono
    steam = [
        [(11, 9), (12, 9), (12, 8), (11, 8)],
        [(12, 8), (13, 8), (12, 7), (13, 7), (6, 9)],
        [(13, 6), (14, 6), (13, 5), (5, 8), (6, 8), (5, 7)],
        [(14, 4), (5, 6)],
    ][i]
    for x, y in steam:
        s.px(x, y + bob, "bianco")
    return s


if __name__ == "__main__":
    Sprite.save("tacchino_furioso", "game/assets/cards/tacchino_furioso.png", [frame(i) for i in range(4)],
                comment="Pollaio, taglia M")
