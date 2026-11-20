"""Terreni del tavolo (tile 32x32 ripetibili, scala del mondo 1 tile = 16 px) e pezzi del recinto.
Un terreno per banda + l'erba del tavolo. Escono in game/assets/board/. Regole: docs/art/design-system.md §10."""
import os
import random
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
import pixel  # noqa: E402

ROOT = pixel.ROOT
_, COL = pixel.load_palette()
N = 32


def canvas(base):
    return [[base] * N for _ in range(N)]


def put(g, x, y, c):
    g[y % N][x % N] = c


def blob(g, cx, cy, r, c, rnd, squash=0.6):
    for y in range(-r, r + 1):
        for x in range(-r, r + 1):
            if (x / r) ** 2 + (y / (r * squash)) ** 2 <= 1.0:
                put(g, cx + x, cy + y, c)


def tuft(g, x, y, dark, light):
    """Ciuffo d'erba come nel riferimento: una V di 3 px scuri con la punta chiara."""
    put(g, x, y, dark); put(g, x + 2, y, dark); put(g, x + 1, y + 1, dark)
    put(g, x, y - 1, light); put(g, x + 2, y - 1, light)


def erba(seed=1, base="verde_4", dark="verde_3", light="verde_5"):
    rnd = random.Random(seed)
    g = canvas(base)
    for _ in range(7):
        tuft(g, rnd.randrange(N), rnd.randrange(N), dark, light)
    for _ in range(3):
        put(g, rnd.randrange(N), rnd.randrange(N), light)
    return g


def fango():          # Porcile: fango con pozze rosate e impronte
    rnd = random.Random(2)
    g = canvas("legno_5")
    for _ in range(6):
        blob(g, rnd.randrange(N), rnd.randrange(N), rnd.choice((2, 3)), "legno_4", rnd)
    for _ in range(2):
        x, y = rnd.randrange(N), rnd.randrange(N)
        blob(g, x, y, 3, "legno_3", rnd); blob(g, x - 1, y - 1, 1, "legno_6", rnd)
    for _ in range(5):
        put(g, rnd.randrange(N), rnd.randrange(N), "legno_6")
    return g


def paglia():         # Pollaio: terra battuta con fili di paglia
    rnd = random.Random(3)
    g = canvas("legno_8")
    for _ in range(5):
        blob(g, rnd.randrange(N), rnd.randrange(N), 2, "legno_7", rnd)
    for _ in range(9):
        x, y = rnd.randrange(N), rnd.randrange(N)
        d = rnd.choice((1, -1))
        for i in range(3):
            put(g, x + i, y + d * (i // 2), "legno_9")
        put(g, x + 1, y + 1, "legno_6")
    return g


def stagno():         # Stagno: acqua con increspature (2 righe chiare) e un riflesso
    rnd = random.Random(4)
    g = canvas("acqua_4")
    for _ in range(6):
        x, y = rnd.randrange(N), rnd.randrange(N)
        for i in range(4):
            put(g, x + i, y, "acqua_5")
        put(g, x + 1, y - 1, "acqua_6"); put(g, x + 2, y - 1, "acqua_6")
    for _ in range(3):
        x, y = rnd.randrange(N), rnd.randrange(N)
        put(g, x, y, "bianco")
    for _ in range(3):
        blob(g, rnd.randrange(N), rnd.randrange(N), 2, "acqua_3", rnd)
    return g


def orto():           # Patate: solchi di terra arata con germogli
    g = canvas("legno_4")
    for y in range(N):
        for x in range(N):
            r = y % 8
            if r in (0, 1):
                g[y][x] = "legno_3"
            elif r == 2:
                g[y][x] = "legno_5"
    rnd = random.Random(5)
    for y0 in (5, 13, 21, 29):
        for x0 in range(rnd.randrange(4), N, 9):
            put(g, x0, y0, "verde_2"); put(g, x0 + 1, y0 - 1, "verde_4"); put(g, x0 - 1, y0 - 1, "verde_3")
    return g


def discarica():      # Discarica: ghiaia grigia con rottami e una vite arrugginita
    rnd = random.Random(6)
    g = canvas("ferro_3")
    for _ in range(14):
        x, y = rnd.randrange(N), rnd.randrange(N)
        put(g, x, y, "ferro_2"); put(g, x + 1, y, "ferro_4")
    for _ in range(3):
        x, y = rnd.randrange(N), rnd.randrange(N)
        for i in range(4):
            put(g, x + i, y, "ruggine_2")
        put(g, x, y + 1, "ruggine_1"); put(g, x + 3, y - 1, "ruggine_4")
    for _ in range(2):
        x, y = rnd.randrange(N), rnd.randrange(N)
        blob(g, x, y, 2, "ferro_1", rnd); put(g, x - 1, y - 1, "ferro_5")
    return g


def cratere():        # Cratere: terra bruciata viola con crepe che brillano
    rnd = random.Random(7)
    g = canvas("viola_1")
    for _ in range(5):
        blob(g, rnd.randrange(N), rnd.randrange(N), 3, "prugna", rnd)
    for _ in range(3):
        x, y = rnd.randrange(N), rnd.randrange(N)
        for i in range(5):
            put(g, x + i, y + (i % 2), "legno_0")
        put(g, x + 2, y, "radio_1")
    for _ in range(4):
        put(g, rnd.randrange(N), rnd.randrange(N), "viola_2")
    return g


def save(name, g):
    rows = [[COL[c] for c in row] for row in g]
    out = os.path.join(ROOT, "game", "assets", "board", name + ".png")
    pixel.write_png(out, N, N, rows)
    print("ok  game/assets/board/%s.png" % name)


if __name__ == "__main__":
    save("erba", erba())
    save("porcile", fango())
    save("pollaio", paglia())
    save("stagno", stagno())
    save("patate", orto())
    save("discarica", discarica())
    save("cratere", cratere())
