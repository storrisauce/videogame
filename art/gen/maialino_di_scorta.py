"""Maialino di Scorta (Porcile, comune) — taglia S piccola: un maialino con il cartellino 'scorta' all'orecchio.
"Lo teniamo per le emergenze. Lui non lo sa." Guarda a sinistra, come gli animali del riferimento."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite, RAMPS

P = RAMPS["maiale_b"]


def frame(i):
    s = Sprite(32, 32)
    bob = 1 if i == 1 else 0
    s.shadow(16.5, 26.8, 8.5, 2.2)
    s.ellipse(17.5, 21.5, 7.2, 5.2, P)                 # corpo
    s.rect(12, 24, 2, 2, P, shade=False)               # zampe
    s.rect(20, 24, 2, 2, P, shade=False)
    head = s.ellipse(12.5, 17.5 + bob, 5.2, 4.6, P)    # testa grande (cucciolo)
    s.polygon([(9, 12.5 + bob), (12, 13.5 + bob), (10, 15 + bob)], P, shade=False)   # orecchie
    s.polygon([(14, 12.5 + bob), (17, 13 + bob), (15.5, 15 + bob)], P, shade=False)
    s.outline()
    # muso
    s.rect(8, 18 + bob, 4, 3, ("rosa_1", "rosa_2", "rosa_3", "rosa_3"), shade=False)
    s.px(9, 19 + bob, "rosa_1"); s.px(11, 19 + bob, "rosa_1")
    # occhi (1x2 come nel riferimento), battito al fotogramma 3
    if i == 3:
        s.px(10, 17 + bob, "rosa_1"); s.px(13, 17 + bob, "rosa_1")
    else:
        s.px(10, 16 + bob, "inchiostro"); s.px(10, 17 + bob, "inchiostro")
        s.px(13, 16 + bob, "inchiostro"); s.px(13, 17 + bob, "inchiostro")
    # cartellino della scorta appeso all'orecchio destro
    s.px(17, 14 + bob, "legno_3"); s.px(18, 15 + bob, "legno_3")
    s.rect(18, 16 + bob, 4, 3, ("legno_3", "legno_8", "legno_9", "legno_9"), shade=False)
    s.px(19, 17 + bob, "rosso_2"); s.px(20, 17 + bob, "rosso_2")
    # coda a ricciolo e macchia radioattiva
    s.px(25, 19, "rosa_1"); s.px(25, 18, "rosa_1"); s.px(24, 17, "rosa_1")
    s.px(21, 21, "radio_1"); s.px(22, 21, "radio_2"); s.px(22, 22, "radio_1")
    return s


if __name__ == "__main__":
    Sprite.save("maialino_di_scorta", "game/assets/cards/maialino_di_scorta.png", [frame(i) for i in range(4)],
                comment="Porcile, taglia S piccola")
