#!/usr/bin/env python3
"""Strumenti per la pixel art di Fattoria Nucleare. Solo Python standard, nessuna libreria da installare.

  python3 art/tools/pixel.py render art/sprites/rana_a_due_teste.pxl     # .pxl -> PNG (strip orizzontale)
  python3 art/tools/pixel.py render-all                                   # tutti i .pxl in art/sprites
  python3 art/tools/pixel.py check                                        # i PNG di game/assets rispettano la palette?
  python3 art/tools/pixel.py palette                                      # rigenera .gpl, .hex e campionario
  python3 art/tools/pixel.py preview in.png out.png [scala] [sfondo]      # ingrandimento netto per guardarlo
  python3 art/tools/pixel.py compare out.png a.png b.png ...              # primi fotogrammi affiancati, ×6, su erba
  python3 art/tools/pixel.py stats a.png b.png ...                        # colori, % radio, misure del corpo

Formato .pxl (testo, una riga = una fila di pixel):
  name: rana_a_due_teste
  size: 32x32                       # misura di UN fotogramma
  out: game/assets/cards/rana_a_due_teste.png
  legend:
    . = trasparente
    o = verde_1                     # nomi dalla palette (art/palette/fattoria_nucleare.json)
    s = ombra                       # notte al 29% di opacità, l'unico semitrasparente ammesso
  frame idle_0:
    ....oooo....
  frame idle_1:
    ...
Le righe mancanti in fondo a un fotogramma sono trasparenti; le righe corte sono riempite di trasparente.
"""
import json
import os
import struct
import sys
import zlib

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PALETTE_PATH = os.path.join(ROOT, "art", "palette", "fattoria_nucleare.json")


# ---------------------------------------------------------------- palette
def load_palette():
    data = json.load(open(PALETTE_PATH, encoding="utf-8"))
    colors = {}
    for ramp in data["ramps"].values():
        for name, hx in ramp.items():
            colors[name] = _hex(hx) + (255,)
    sh = data["shadow"]
    colors["ombra"] = colors[sh["color"]][:3] + (sh["alpha"],)
    colors["trasparente"] = (0, 0, 0, 0)
    return data, colors


def _hex(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


# ---------------------------------------------------------------- PNG
def write_png(path, w, h, rgba_rows):
    raw = b"".join(b"\x00" + bytes(v for px in row for v in px) for row in rgba_rows)

    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)

    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)))
        f.write(chunk(b"IDAT", zlib.compress(raw, 9)))
        f.write(chunk(b"IEND", b""))


def read_png(path):
    """PNG 8 bit non interlacciati (RGBA, RGB, scala di grigi, palette). Ritorna (w, h, righe di tuple RGBA)."""
    data = open(path, "rb").read()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", "non è un PNG"
    pos, idat, plte, trns = 8, b"", None, None
    while pos < len(data):
        n = struct.unpack(">I", data[pos:pos + 4])[0]
        t = data[pos + 4:pos + 8]
        d = data[pos + 8:pos + 8 + n]
        pos += 12 + n
        if t == b"IHDR":
            w, h, depth, ctype, _, _, inter = struct.unpack(">IIBBBBB", d)
        elif t == b"PLTE":
            plte = [tuple(d[i:i + 3]) for i in range(0, len(d), 3)]
        elif t == b"tRNS":
            trns = d
        elif t == b"IDAT":
            idat += d
    if depth != 8 or inter:
        raise ValueError("%s: servono PNG a 8 bit non interlacciati" % path)
    bpp = {6: 4, 2: 3, 0: 1, 4: 2, 3: 1}[ctype]
    raw = zlib.decompress(idat)
    stride = w * bpp
    rows, prev, i = [], bytearray(stride), 0
    for _ in range(h):
        f = raw[i]
        line = bytearray(raw[i + 1:i + 1 + stride])
        i += 1 + stride
        for x in range(stride):
            a = line[x - bpp] if x >= bpp else 0
            b = prev[x]
            c = prev[x - bpp] if x >= bpp else 0
            if f == 1:
                line[x] = (line[x] + a) & 255
            elif f == 2:
                line[x] = (line[x] + b) & 255
            elif f == 3:
                line[x] = (line[x] + (a + b) // 2) & 255
            elif f == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                line[x] = (line[x] + pr) & 255
        prev = line
        out = []
        for x in range(w):
            px = line[x * bpp:(x + 1) * bpp]
            if ctype == 6:
                out.append(tuple(px))
            elif ctype == 2:
                out.append(tuple(px) + (255,))
            elif ctype == 0:
                out.append((px[0],) * 3 + (255,))
            elif ctype == 4:
                out.append((px[0],) * 3 + (px[1],))
            else:
                k = px[0]
                al = trns[k] if trns and k < len(trns) else 255
                out.append(plte[k] + (al,))
        rows.append(out)
    return w, h, rows


# ---------------------------------------------------------------- .pxl
def parse_pxl(path):
    meta, legend, frames = {}, {}, []
    mode = None
    for raw in open(path, encoding="utf-8"):
        line = raw.split("#", 1)[0].rstrip() if not raw.strip().startswith(("frame",)) else raw.rstrip()
        if not line.strip():
            continue
        s = line.strip()
        if s == "legend:":
            mode = "legend"
            continue
        if s.startswith("frame ") and s.endswith(":"):
            frames.append((s[6:-1].strip(), []))
            mode = "frame"
            continue
        if mode == "legend" and "=" in s and not raw.startswith(("name", "size", "out")):
            k, v = s.split("=", 1)
            legend[k.strip()] = v.strip()
            continue
        if mode == "frame":
            frames[-1][1].append(s)
            continue
        if ":" in s:
            k, v = s.split(":", 1)
            meta[k.strip()] = v.strip()
    return meta, legend, frames


def render(path, colors):
    meta, legend, frames = parse_pxl(path)
    fw, fh = (int(v) for v in meta["size"].split("x"))
    for k, v in legend.items():
        if v not in colors:
            raise SystemExit("%s: colore '%s' (lettera %s) non è nella palette" % (path, v, k))
    rows = [[(0, 0, 0, 0)] * (fw * len(frames)) for _ in range(fh)]
    for fi, (fname, lines) in enumerate(frames):
        if len(lines) > fh:
            raise SystemExit("%s: fotogramma %s ha %d righe, massimo %d" % (path, fname, len(lines), fh))
        top = fh - len(lines) if meta.get("align", "bottom") == "bottom" else 0
        for y, line in enumerate(lines):
            if len(line) > fw:
                raise SystemExit("%s: fotogramma %s riga %d lunga %d, massimo %d" % (path, fname, y, len(line), fw))
            for x, ch in enumerate(line):
                if ch not in legend:
                    raise SystemExit("%s: lettera '%s' non in legenda (fotogramma %s, riga %d)" % (path, ch, fname, y))
                rows[top + y][fi * fw + x] = colors[legend[ch]]
    out = os.path.join(ROOT, meta["out"])
    write_png(out, fw * len(frames), fh, rows)
    print("ok  %s -> %s  (%d fotogrammi %dx%d)" % (os.path.relpath(path, ROOT), meta["out"], len(frames), fw, fh))
    return out


# ---------------------------------------------------------------- controllo
def check(paths, colors):
    allowed = {c for n, c in colors.items() if n != "trasparente"}
    files = []
    for p in paths:
        if os.path.isdir(p):
            for d, _, fs in os.walk(p):
                files += [os.path.join(d, f) for f in fs if f.lower().endswith(".png")]
        else:
            files.append(p)
    bad = 0
    for f in sorted(files):
        w, h, rows = read_png(f)
        wrong = {}
        for row in rows:
            for px in row:
                if px[3] == 0:
                    continue
                if px not in allowed:
                    wrong[px] = wrong.get(px, 0) + 1
        if wrong:
            bad += 1
            ex = ", ".join("#%02x%02x%02x a%d (%d px)" % (k + (v,)) for k, v in sorted(wrong.items(), key=lambda kv: -kv[1])[:4])
            print("NO  %s: %d colori fuori palette: %s" % (os.path.relpath(f, ROOT), len(wrong), ex))
        else:
            print("ok  %s" % os.path.relpath(f, ROOT))
    print("%d file, %d fuori regola" % (len(files), bad))
    return bad == 0


# ---------------------------------------------------------------- palette files
def export_palette(data, colors):
    base = os.path.join(ROOT, "art", "palette", "fattoria_nucleare")
    names = [(n, hx) for ramp in data["ramps"].values() for n, hx in ramp.items()]
    with open(base + ".gpl", "w") as f:
        f.write("GIMP Palette\nName: Fattoria Nucleare\nColumns: 10\n#\n")
        for n, hx in names:
            r, g, b = _hex(hx)
            f.write("%3d %3d %3d\t%s\n" % (r, g, b, n))
    with open(base + ".hex", "w") as f:
        f.write("".join(hx.lstrip("#") + "\n" for _, hx in names))
    # campionario: una riga per rampa, quadretti 16x16 con 1 px di stacco
    ramps = list(data["ramps"].values())
    cell, pad = 16, 2
    W = max(len(r) for r in ramps) * (cell + pad) + pad
    H = len(ramps) * (cell + pad) + pad
    rows = [[colors["inchiostro"]] * W for _ in range(H)]
    for ri, ramp in enumerate(ramps):
        for ci, hx in enumerate(ramp.values()):
            c = _hex(hx) + (255,)
            for y in range(cell):
                for x in range(cell):
                    rows[pad + ri * (cell + pad) + y][pad + ci * (cell + pad) + x] = c
    write_png(base + "_campionario.png", W, H, rows)
    # copia per il gioco: i colori dell'interfaccia vengono da qui (game/ui/art.gd)
    import shutil
    shutil.copy(PALETTE_PATH, os.path.join(ROOT, "game", "data", "palette.json"))
    print("ok  palette: %d colori -> .gpl .hex _campionario.png" % len(names))


def preview(src, dst, scale=8, bg="#c8c8c8"):
    w, h, rows = read_png(src)
    b = _hex(bg)
    out = []
    for row in rows:
        line = []
        for r, g, bl, a in row:
            px = tuple((v * a + bv * (255 - a)) // 255 for v, bv in zip((r, g, bl), b)) + (255,)
            line += [px] * scale
        out += [line] * scale
    write_png(dst, w * scale, h * scale, out)
    print("ok  anteprima %s" % dst)


def compare(dst, srcs, scale=6, bg="#63c74d"):
    """Affianca il primo fotogramma di più strisce (anche di misure diverse), appoggiati in basso."""
    frames = []
    for p in srcs:
        w, h, rows = read_png(p)
        fw = h if w % h == 0 else w
        frames.append([r[:fw] for r in rows])
    H = max(len(f) for f in frames)
    W = sum(len(f[0]) for f in frames) + 4 * (len(frames) + 1)
    b = _hex(bg) + (255,)
    canvas = [[b] * W for _ in range(H + 8)]
    x = 4
    for f in frames:
        top = H + 4 - len(f)
        for y, row in enumerate(f):
            for i, px in enumerate(row):
                if px[3]:
                    a = px[3] / 255
                    canvas[top + y][x + i] = tuple(int(px[k] * a + b[k] * (1 - a)) for k in range(3)) + (255,)
        x += len(f[0]) + 4
    out = [[px for px in row for _ in range(scale)] for row in canvas for _ in range(scale)]
    write_png(dst, W * scale, (H + 8) * scale, out)
    print("ok  confronto %s" % dst)


def stats(paths, colors):
    names = {v: k for k, v in colors.items()}
    for p in paths:
        w, h, rows = read_png(p)
        fw = h if w % h == 0 else w
        used, radio, xs, ys = set(), 0, [], []
        body = 0
        for y, row in enumerate(rows):
            for x, px in enumerate(row[:fw]):
                if px[3] == 0:
                    continue
                n = names.get(px, "?")
                used.add(n)
                if px[3] == 255:
                    body += 1
                    xs.append(x)
                    ys.append(y)
                    radio += n.startswith("radio")
        bw = (max(xs) - min(xs) + 1) if xs else 0
        bh = (max(ys) - min(ys) + 1) if ys else 0
        print("%-40s fotogramma %dx%d  corpo %dx%d  colori %d  radio %.1f%%" % (os.path.relpath(p, ROOT), fw, h, bw, bh, len(used - {"ombra"}), 100.0 * radio / max(body, 1)))


def main(argv):
    data, colors = load_palette()
    cmd = argv[1] if len(argv) > 1 else "help"
    if cmd == "render":
        for p in argv[2:]:
            render(p, colors)
    elif cmd == "render-all":
        d = os.path.join(ROOT, "art", "sprites")
        for f in sorted(os.listdir(d)):
            if f.endswith(".pxl"):
                render(os.path.join(d, f), colors)
    elif cmd == "check":
        paths = argv[2:] or [os.path.join(ROOT, "game", "assets")]
        sys.exit(0 if check(paths, colors) else 1)
    elif cmd == "palette":
        export_palette(data, colors)
    elif cmd == "compare":
        compare(argv[2], argv[3:])
    elif cmd == "stats":
        stats(argv[2:], colors)
    elif cmd == "preview":
        preview(argv[2], argv[3], int(argv[4]) if len(argv) > 4 else 8, argv[5] if len(argv) > 5 else "#c8c8c8")
    else:
        print(__doc__)


if __name__ == "__main__":
    main(sys.argv)
