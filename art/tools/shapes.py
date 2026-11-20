"""Libreria di forme per disegnare sprite secondo docs/art/design-system.md.

Uso tipico (un file per sprite in art/gen/<id>.py, che scrive art/sprites/<id>.pxl):

    import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
    from shapes import Sprite, RAMPS

    def frame(i):
        s = Sprite(32, 32)
        s.shadow(16, 28, 9, 2.4)                       # ombra a terra (sempre per prima)
        s.ellipse(16, 21, 8, 6, RAMPS["maiale"])         # corpo: luce in alto, ombra in basso
        s.ellipse(11, 15 + (i == 1), 5, 4, RAMPS["maiale"])  # testa (si abbassa di 1 px nel fotogramma 1)
        s.px(9, 15, "inchiostro")                        # occhio
        s.outline()                                      # contorno selettivo (tono più scuro di ogni parte)
        return s
    Sprite.save("maiale_di_prova", "game/assets/cards/maiale_di_prova.png", [frame(i) for i in range(4)])

Una rampa è (contorno, scuro, base, chiaro) con nomi della palette. Le parti disegnate dopo coprono quelle prima.
`outline()` va chiamato quando tutte le parti sono disegnate; i dettagli (occhi, bocche, macchie) si aggiungono dopo.
"""
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

# Rampe pronte (contorno, scuro, base, chiaro). Aggiungine di nuove solo con colori della palette.
RAMPS = {
    "maiale":    ("rosa_1", "rosa_2", "rosa_4", "bianco"),
    "maiale_b":  ("rosa_1", "rosa_2", "rosa_3", "rosa_4"),
    "rana":      ("verde_1", "verde_2", "verde_4", "verde_5"),
    "erba":      ("verde_1", "verde_2", "verde_3", "verde_4"),
    "foglia":    ("verde_0", "verde_1", "verde_2", "verde_3"),
    "lamiera":   ("ferro_1", "ferro_2", "ferro_4", "ferro_5"),
    "ferro":     ("notte", "ferro_1", "ferro_2", "ferro_3"),
    "bianco":    ("notte", "ferro_4", "ferro_5", "bianco"),
    "piuma":     ("ferro_2", "ferro_4", "ferro_6", "bianco"),
    "legno":     ("legno_1", "legno_3", "legno_5", "legno_7"),
    "legno_ch":  ("legno_3", "legno_5", "legno_7", "legno_8"),
    "paglia":    ("legno_4", "legno_7", "legno_8", "legno_9"),
    "pelle":     ("legno_3", "pelle_1", "pelle_3", "pelle_5"),
    "gallina":   ("legno_3", "pelle_1", "pelle_2", "pelle_3"),
    "cresta":    ("rosso_1", "rosso_1", "rosso_2", "rosso_3"),
    "rosso":     ("rosso_1", "rosso_1", "rosso_2", "rosso_4"),
    "ruggine":   ("legno_2", "ruggine_1", "ruggine_2", "ruggine_4"),
    "terra":     ("legno_1", "legno_3", "legno_4", "legno_5"),
    "patata":    ("legno_3", "legno_5", "legno_7", "legno_8"),
    "carota":    ("ruggine_1", "arancio_1", "arancio_2", "arancio_3"),
    "zucca":     ("ruggine_1", "arancio_1", "arancio_3", "arancio_4"),
    "rapa":      ("viola_1", "viola_2", "viola_3", "viola_4"),
    "giallo":    ("arancio_1", "arancio_4", "giallo_2", "bianco"),
    "becco":     ("ruggine_1", "arancio_1", "arancio_3", "arancio_4"),
    "acqua":     ("acqua_1", "acqua_3", "acqua_4", "acqua_6"),
    "anatra":    ("verde_1", "verde_2", "verde_3", "verde_4"),
    "oca":       ("ferro_2", "ferro_4", "ferro_6", "bianco"),
    "grigio":    ("notte", "ferro_1", "ferro_3", "ferro_4"),
    "procione":  ("notte", "ferro_1", "ferro_2", "ferro_4"),
    "capra":     ("legno_3", "legno_7", "legno_8", "legno_9"),
    "viola":     ("legno_0", "viola_1", "viola_2", "viola_3"),
    "radio":     ("verde_1", "verde_2", "radio_1", "radio_2"),
    "pietra":    ("notte", "ferro_2", "ferro_3", "ferro_4"),
    "tela":      ("legno_3", "legno_6", "legno_8", "legno_9"),
}


def _in_ellipse(x, y, cx, cy, rx, ry):
    return ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1.0


class Sprite:
    def __init__(self, w=32, h=32):
        self.w, self.h = w, h
        self.c = [[None] * w for _ in range(h)]      # nome colore o None
        self.part = [[None] * w for _ in range(h)]   # colore del contorno della parte che occupa il pixel
        self.shadow_px = set()

    # ------------------------------------------------------------ base
    def inside(self, x, y):
        return 0 <= x < self.w and 0 <= y < self.h

    def px(self, x, y, color, outline=None):
        x, y = int(x), int(y)
        if self.inside(x, y):
            self.c[y][x] = color
            if outline is not None:
                self.part[y][x] = outline

    def get(self, x, y):
        return self.c[int(y)][int(x)] if self.inside(x, y) else None

    def pixels(self, pts, color):
        for x, y in pts:
            self.px(x, y, color)

    def recolor(self, old, new, region=None):
        for y in range(self.h):
            for x in range(self.w):
                if self.c[y][x] == old and (region is None or (x, y) in region):
                    self.c[y][x] = new

    # ------------------------------------------------------------ forme
    def shadow(self, cx, cy, rx, ry):
        for y in range(self.h):
            for x in range(self.w):
                if _in_ellipse(x, y, cx, cy, rx, ry):
                    self.shadow_px.add((x, y))

    def _fill(self, pts, ramp, cx, cy, rx, ry, light=0.55, dark=0.55, shade=True):
        o, d, b, l = ramp
        for x, y in pts:
            if not shade:
                col = b
            else:
                u = (x + 0.5 - cx) / rx
                v = (y + 0.5 - cy) / ry
                if v < -light or (u < -0.72 and v < 0.15):
                    col = l
                elif v > dark or u > 0.8:
                    col = d
                else:
                    col = b
            self.c[y][x] = col
            self.part[y][x] = o
        return set(pts)

    def ellipse(self, cx, cy, rx, ry, ramp, light=0.55, dark=0.55, shade=True):
        pts = [(x, y) for y in range(self.h) for x in range(self.w) if _in_ellipse(x, y, cx, cy, rx, ry)]
        return self._fill(pts, ramp, cx, cy, rx, ry, light, dark, shade)

    def rect(self, x0, y0, w, h, ramp, shade=True):
        pts = [(x, y) for y in range(int(y0), int(y0 + h)) for x in range(int(x0), int(x0 + w)) if self.inside(x, y)]
        return self._fill(pts, ramp, x0 + w / 2, y0 + h / 2, w / 2, h / 2, shade=shade)

    def polygon(self, verts, ramp, shade=True):
        """Poligono pieno (lista di (x, y)); utile per becchi, orecchie, lame, tetti."""
        xs = [v[0] for v in verts]
        ys = [v[1] for v in verts]
        pts = []
        for y in range(self.h):
            for x in range(self.w):
                if _point_in_poly(x + 0.5, y + 0.5, verts):
                    pts.append((x, y))
        cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2
        rx, ry = max(0.5, (max(xs) - min(xs)) / 2), max(0.5, (max(ys) - min(ys)) / 2)
        return self._fill(pts, ramp, cx, cy, rx, ry, shade=shade)

    def blob(self, cx, cy, rx, ry, ramp, spot=0.35):
        """Ellisse con luce "a palla": macchia chiara in alto a sinistra, mezzaluna scura in basso a destra.
        Più morbida di ellipse() per corpi tondi (maiali, patate, zucche)."""
        o, d, b, l = ramp
        pts = []
        for y in range(self.h):
            for x in range(self.w):
                if _in_ellipse(x, y, cx, cy, rx, ry):
                    u = (x + 0.5 - cx) / rx
                    v = (y + 0.5 - cy) / ry
                    if (u + 0.35) ** 2 + (v + 0.45) ** 2 < spot:
                        col = l
                    elif u * 0.55 + v > 0.62 or (u * u + v * v > 0.78 and u + v > 0.55):
                        col = d
                    else:
                        col = b
                    self.c[y][x] = col
                    self.part[y][x] = o
                    pts.append((x, y))
        return set(pts)

    def grid(self, rows, legend, x0=0, y0=0, outline=None):
        """Disegna una griglia di lettere (come nei .pxl): legend = {"a": "rosa_3", ...}; "." = vuoto.
        `outline` = colore di contorno da usare per questi pixel in outline() (default: nessun contorno automatico)."""
        for y, row in enumerate(rows):
            for x, ch in enumerate(row):
                if ch in (".", " "):
                    continue
                self.px(x0 + x, y0 + y, legend[ch], outline)

    def tidy(self):
        """Toglie i pixel isolati (nessun vicino dello stesso colore e al massimo un vicino pieno): da chiamare prima di outline()."""
        kill = []
        for y in range(self.h):
            for x in range(self.w):
                col = self.c[y][x]
                if col is None:
                    continue
                same = full = 0
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    n = self.get(x + dx, y + dy)
                    if n is not None:
                        full += 1
                        same += n == col
                if same == 0 and full <= 1:
                    kill.append((x, y))
        for x, y in kill:
            self.c[y][x] = None
            self.part[y][x] = None

    def erase(self, pts):
        for x, y in pts:
            if self.inside(x, y):
                self.c[y][x] = None
                self.part[y][x] = None

    def line(self, x0, y0, x1, y1, color, outline=None):
        n = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
        for i in range(n):
            t = i / max(1, n - 1)
            self.px(round(x0 + (x1 - x0) * t), round(y0 + (y1 - y0) * t), color, outline)

    def outline(self, color=None):
        """Contorno di 1 px fuori da tutte le parti: tono più scuro della parte vicina, o `color` (es. 'inchiostro')."""
        add = []
        for y in range(self.h):
            for x in range(self.w):
                if self.c[y][x] is not None:
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if self.inside(nx, ny) and self.c[ny][nx] is not None and self.part[ny][nx] is not None:
                        add.append((x, y, color or self.part[ny][nx]))
                        break
        for x, y, col in add:
            self.c[y][x] = col
            self.part[y][x] = None

    def seam(self, region, color=None):
        """Linea di 1 px dove la parte `region` (insieme di pixel restituito da ellipse/rect) tocca altre parti sotto."""
        add = []
        for x, y in region:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if self.inside(nx, ny) and (nx, ny) not in region and self.c[ny][nx] is not None and self.part[ny][nx] is not None:
                    add.append((x, y))
                    break
        for x, y in add:
            self.c[y][x] = color or self.part[y][x]

    def mirror_x(self):
        self.c = [list(reversed(r)) for r in self.c]
        self.part = [list(reversed(r)) for r in self.part]
        self.shadow_px = {(self.w - 1 - x, y) for x, y in self.shadow_px}

    def shift(self, dx, dy):
        c = [[None] * self.w for _ in range(self.h)]
        p = [[None] * self.w for _ in range(self.h)]
        for y in range(self.h):
            for x in range(self.w):
                if self.inside(x + dx, y + dy):
                    c[y + dy][x + dx] = self.c[y][x]
                    p[y + dy][x + dx] = self.part[y][x]
        self.c, self.part = c, p

    # ------------------------------------------------------------ uscita
    def rows(self):
        out = []
        for y in range(self.h):
            row = []
            for x in range(self.w):
                col = self.c[y][x]
                if col is None:
                    col = "ombra" if (x, y) in self.shadow_px else "trasparente"
                row.append(col)
            out.append(row)
        return out

    @staticmethod
    def save(name, out, frames, frame_names=None, comment=""):
        """Scrive art/sprites/<name>.pxl (fonte modificabile a mano) e lo trasforma in PNG."""
        letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@$%&*+?!~^"
        legend = {"trasparente": "."}
        for f in frames:
            for row in f.rows():
                for col in row:
                    if col not in legend:
                        legend[col] = letters[len(legend) - 1]
        if "ombra" in legend and legend["ombra"] != "s" and "s" not in legend.values():
            legend["ombra"] = "s"
        w, h = frames[0].w, frames[0].h
        names = frame_names or ["idle_%d" % i for i in range(len(frames))]
        lines = ["# %s — generato da art/gen/%s.py (si può ritoccare a mano, ma rigenerando si perde il ritocco)" % (name, name)]
        if comment:
            lines.append("# " + comment)
        lines += ["name: %s" % name, "size: %dx%d" % (w, h), "out: %s" % out, "align: top", "legend:"]
        lines += ["  %s = %s" % (k, v) for v, k in legend.items()]
        for n, f in zip(names, frames):
            lines.append("frame %s:" % n)
            lines += ["  " + "".join(legend[c] for c in row) for row in f.rows()]
        path = os.path.join(ROOT, "art", "sprites", name + ".pxl")
        open(path, "w", encoding="utf-8").write("\n".join(lines) + "\n")
        import pixel  # stesso folder
        _, colors = pixel.load_palette()
        return pixel.render(path, colors)


def _point_in_poly(x, y, verts):
    inside = False
    j = len(verts) - 1
    for i in range(len(verts)):
        xi, yi = verts[i]
        xj, yj = verts[j]
        if (yi > y) != (yj > y) and x < (xj - xi) * (y - yi) / (yj - yi + 1e-9) + xi:
            inside = not inside
        j = i
    return inside
