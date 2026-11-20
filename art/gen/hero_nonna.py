"""La Nonna col Fucile (sopravvissuta) — Persona, la più alta dopo il Veterinario (corpo 13x20 con contorno).
Crocchia grigia, occhiali, grembiule, fucile a due canne da cartone animato puntato a sinistra: "Fuori dal mio orto!".
Disegnata a griglia (pixel per pixel) perché a questa misura ogni pixel conta; contorno pieno inchiostro."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from shapes import Sprite

L = {
    "W": "bianco", "H": "ferro_5", "h": "ferro_4",          # capelli grigi (luce, base, ombra)
    "S": "pelle_4", "s": "pelle_2", "c": "rosa_3",           # pelle e guance
    "k": "inchiostro", "g": "ferro_2",                      # occhi, montatura degli occhiali
    "D": "viola_2", "d": "viola_1",                          # vestito
    "A": "bianco", "a": "ferro_5",                           # grembiule
    "B": "legno_4", "b": "legno_3",                          # calcio del fucile, scarpe
}

HEAD = [  # 11 di larghezza, guarda a sinistra (3/4)
    "......WHh..",
    ".....WHHHh.",
    "..WWHHhhhH.",
    ".WHHHHHHHHh",
    "WHHHHHHHHHh",
    "HSSSSSSHHHh",
    "gggSgggSHHh",
    "SkHSSkHSShh",
    "SkSSSkSSSsh",
    "ScSSScSSSs.",
    ".sSSSSSSs..",
]
BLINK = {7: "SSHSSSHSShh", 8: "SkSSSkSSSsh"}

BODY = [  # sotto la testa
    "..dDAAADd..",
    "..DAAAAAD..",
    ".dDAAAAADd.",
    ".DDAaAAADd.",
    "DDDAAAAaDdd",
    "dDDaaaaaDdd",
    ".b.......b.",
]


def stamp(s, rows, ox, oy):
    for j, r in enumerate(rows):
        for i, ch in enumerate(r):
            if ch != ".":
                s.px(ox + i, oy + j, L[ch], outline="inchiostro")


def frame(i):
    s = Sprite(32, 32)
    s.shadow(15.5, 28.2, 8.5, 2.2)
    ox, oy = 12, 10
    bob = 1 if i in (1, 2) else 0
    stamp(s, BODY, ox, oy + 11)
    head = [BLINK.get(j, r) if i == 3 else r for j, r in enumerate(HEAD)]
    stamp(s, head, ox, oy + bob)
    # fucile a due canne tenuto al fianco, canne verso sinistra; calcio che sporge a destra
    gy = oy + 13
    P = lambda x, y, c: s.px(x, y, c, outline="inchiostro")
    for x in range(ox - 7, ox + 5):
        P(x, gy, "ferro_4")
    for x in range(ox - 7, ox + 3):
        P(x, gy + 1, "ferro_2")
    for x in range(ox + 3, ox + 9):
        P(x, gy + 1, "legno_4")
    for x in range(ox + 5, ox + 8):
        P(x, gy, "legno_4")
    for x in range(ox + 7, ox + 11):
        P(x, gy + 2, "legno_3")
    P(ox + 9, gy + 1, "legno_4"); P(ox + 10, gy + 3, "legno_3"); P(ox + 9, gy + 3, "legno_3")
    P(ox, gy + 2, "pelle_4"); P(ox - 1, gy + 2, "pelle_4")   # mano sotto le canne
    P(ox + 5, gy + 2, "pelle_4"); P(ox + 6, gy + 2, "pelle_4")  # mano sul grilletto
    s.outline("inchiostro")
    s.px(ox - 7, gy, "inchiostro")      # bocca delle canne
    s.px(ox - 7, gy + 1, "inchiostro")
    return s


if __name__ == "__main__":
    Sprite.save("hero_nonna", "game/assets/heroes/nonna.png", [frame(i) for i in range(4)],
                comment="Sopravvissuta, Persona 13x20")
