"""Germano di Vedetta (Stagno, comune) — taglia S: un germano reale appollaiato su un palo di legno che scruta
l'orizzonte con un binocolo. "Fischia se arriva qualcuno. Anche se non arriva nessuno."
Guarda a sinistra, come gli animali del riferimento."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

TESTA = ("verde_1", "verde_1", "verde_3", "verde_4")
PETTO = ("ruggine_1", "legno_3", "legno_3", "legno_3")
CORPO = ("ferro_2", "ferro_5", "ferro_5", "bianco")
PALO = ("ruggine_1", "legno_3", "legno_5", "legno_5")


def frame(i):
    s = Sprite(32, 32)
    bob = 1 if i == 1 else 0
    up = 1 if i == 3 else 0                            # alza il binocolo: "arriva qualcuno?"
    s.shadow(16.5, 27, 6.5, 1.8)
    # palo di vedetta piantato nel terreno
    s.rect(14, 19, 5, 8, PALO)
    s.ellipse(16.5, 19.5, 3.2, 1.6, ("ruggine_1", "legno_5", "legno_5", "legno_5"), shade=False)
    # coda appuntita con il ricciolo scuro
    s.polygon([(21, 13.5), (25.5, 12), (24.5, 16.5)], CORPO)
    s.ellipse(17.5, 15.5, 6.8, 3.6, CORPO)             # corpo grigio
    s.ellipse(12.6, 15 + bob * 0.5, 3, 2.8, PETTO, shade=False)   # petto castano
    s.ellipse(12.5, 9 + bob, 4.3, 4, TESTA)            # testa verde
    for y, x0 in ((11, 6), (12, 5)):                   # becco giallo
        for x in range(x0, 9):
            s.px(x, y + bob, "giallo_1", "ruggine_1")
    # binocolo davanti all'occhio
    y0 = 6 + bob - up
    TUBO = ("inchiostro", "ferro_2", "ferro_2", "ferro_5")
    s.rect(6, y0, 4, 2, TUBO, shade=False)              # tubo dietro
    s.rect(5, y0 + 2, 4, 2, TUBO, shade=False)          # tubo davanti (vista di 3/4)
    s.outline()
    s.px(7, y0, "ferro_5"); s.px(8, y0, "ferro_5"); s.px(6, y0 + 2, "ferro_5"); s.px(7, y0 + 2, "ferro_5")
    s.px(6, y0 + 1, "inchiostro")                        # stacco fra i tubi
    s.px(4, y0 + 2, "inchiostro"); s.px(4, y0 + 3, "inchiostro"); s.px(5, y0, "inchiostro"); s.px(5, y0 + 1, "inchiostro")
    if i == 2:
        s.px(5, y0 + 2, "bianco"); s.px(6, y0, "bianco")   # riflesso delle lenti
    # zampe arancio sul palo
    s.px(15, 19, "giallo_1"); s.px(18, 19, "giallo_1")
    # collarino bianco del germano
    for x in range(9, 16):
        if s.get(x, 13 + bob) not in (None, "verde_1", "ruggine_1"):
            s.px(x, 13 + bob, "bianco")
    s.pixels([(17, 17), (18, 17), (19, 17), (20, 16), (21, 16)], "ferro_2")   # piega dell'ala sul fianco
    s.px(25, 11, "verde_1"); s.px(24, 11, "verde_1")  # ricciolo della coda
    # venature del palo
    s.px(15, 22, "ruggine_1"); s.px(15, 23, "ruggine_1"); s.px(17, 25, "ruggine_1")
    # macchia radioattiva sul fianco
    s.px(19, 14, "radio_1"); s.px(20, 14, "radio_1")
    return s


if __name__ == "__main__":
    Sprite.save("germano_di_vedetta", "game/assets/cards/germano_di_vedetta.png", [frame(i) for i in range(4)],
                comment="Stagno, taglia S")
