#!/usr/bin/env python3
"""Suoni e musiche di Fattoria Nucleare, sintetizzati da zero (niente campioni di altri: tutto originale).

Uso:  python3 art/audio/gen_audio.py            -> scrive game/assets/audio/sfx/*.wav e music/*.ogg
Serve numpy; per le musiche serve ffmpeg con libvorbis (se manca, restano i .wav).

Stile (docs/art/design-system.md, sezione Suono): cartone animato post-nucleare. Colpi pieni con un basso
che "spinge", scintille e ronzii radioattivi, strumenti buffi (tuba, marimba, theremin da scienziato pazzo).
"""
import os
import subprocess
import sys
import wave

import numpy as np

SR = 44100
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SFX_DIR = os.path.join(ROOT, "game", "assets", "audio", "sfx")
MUS_DIR = os.path.join(ROOT, "game", "assets", "audio", "music")
rng = np.random.default_rng(1957)


# --------------------------------------------------------------------------- mattoncini

def n_of(d):
    return max(1, int(round(SR * d)))


def tt(d):
    return np.arange(n_of(d)) / SR


def exp_sweep(f0, f1, d):
    x = np.linspace(0.0, 1.0, n_of(d))
    return f0 * (f1 / f0) ** x


def osc(freq, d=None, kind="sine", phase0=0.0):
    """freq: numero (serve d) o array di frequenze campione per campione (glissati)."""
    if np.isscalar(freq):
        freq = np.full(n_of(d), float(freq))
    ph = phase0 + 2 * np.pi * np.cumsum(freq) / SR
    if kind == "sine":
        return np.sin(ph)
    p = (ph / (2 * np.pi)) % 1.0
    if kind == "saw":
        return 2 * p - 1
    if kind == "square":
        return np.where(p < 0.5, 1.0, -1.0)
    if kind == "tri":
        return 2 * np.abs(2 * p - 1) - 1
    raise ValueError(kind)


def noise(d):
    return rng.uniform(-1, 1, n_of(d))


def decay(n_or_d, tau, attack=0.002):
    n = n_or_d if isinstance(n_or_d, (int, np.integer)) else n_of(n_or_d)
    t = np.arange(n) / SR
    env = np.exp(-t / tau)
    if attack > 0:
        env *= np.clip(t / attack, 0, 1)
    return env


def adsr(n, a, d, s, r, hold=None):
    t = np.arange(n) / SR
    total = n / SR
    hold = total - r if hold is None else hold
    env = np.where(t < a, t / max(a, 1e-6), s + (1 - s) * np.exp(-(t - a) / max(d, 1e-6)))
    rel = np.clip((t - hold) / max(r, 1e-6), 0, 1)
    return env * (1 - rel)


def filt(x, lo=None, hi=None, order=2, peak=None, q=4.0):
    """Filtro nel dominio delle frequenze (magnitudine di Butterworth, fase zero). peak = risonanza a quella frequenza."""
    if len(x) < 8:
        return x
    n = len(x)
    size = 1 << int(np.ceil(np.log2(n * 2)))
    X = np.fft.rfft(x, size)
    f = np.fft.rfftfreq(size, 1 / SR)
    f[0] = 1e-3
    g = np.ones_like(f)
    if hi:
        g *= 1 / np.sqrt(1 + (f / hi) ** (2 * order))
    if lo:
        g *= 1 / np.sqrt(1 + (lo / f) ** (2 * order))
    if peak:
        g *= 1 + (q - 1) * np.exp(-0.5 * ((np.log2(f / peak)) / 0.18) ** 2)
    return np.fft.irfft(X * g, size)[:n]


def drive(x, k=2.0):
    return np.tanh(k * x) / np.tanh(k)


def place(dst, src, start, gain=1.0):
    i = int(round(start * SR))
    if i >= len(dst):
        return dst
    j = min(len(dst), i + len(src))
    dst[i:j] += src[: j - i] * gain
    return dst


def buf(d):
    return np.zeros(n_of(d))


def conv(x, ir):
    size = 1 << int(np.ceil(np.log2(len(x) + len(ir))))
    return np.fft.irfft(np.fft.rfft(x, size) * np.fft.rfft(ir, size), size)[: len(x) + len(ir) - 1]


def reverb_ir(time=1.2, damp=5000, seed=0):
    r = np.random.default_rng(seed)
    t = tt(time)
    ir = r.uniform(-1, 1, len(t)) * np.exp(-t / (time / 6.9))
    ir = filt(ir, lo=200, hi=damp)
    ir[: n_of(0.012)] *= np.linspace(0, 1, n_of(0.012))   # piccolo ritardo: niente impasto col colpo
    return ir / np.sqrt(np.sum(ir ** 2))


def reverb(x, time=1.0, mix=0.2, damp=5000, seed=0):
    wet = conv(x, reverb_ir(time, damp, seed))
    out = np.zeros(len(wet))
    out[: len(x)] += x
    return out + wet * mix


def finish(x, peak=0.9, fade=0.006):
    x = x - np.mean(x)
    f = min(n_of(fade), len(x) // 4)
    if f > 0:
        x[-f:] *= np.linspace(1, 0, f)
        x[:8] *= np.linspace(0, 1, 8)
    # taglia il silenzio in coda
    a = np.abs(x)
    thr = np.max(a) * 0.002
    last = np.nonzero(a > thr)[0]
    if len(last):
        x = x[: min(len(x), last[-1] + n_of(0.02))]
    m = np.max(np.abs(x))
    return x / m * peak if m > 0 else x


def midi(m):
    return 440.0 * 2 ** ((m - 69) / 12.0)


def write_wav(path, x, stereo=None):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if stereo is not None:
        data = np.stack([x, stereo], axis=1)
        ch = 2
    else:
        data = x
        ch = 1
    pcm = (np.clip(data, -1, 1) * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(ch)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


# --------------------------------------------------------------------------- strumenti

def kick(d=0.32, f_hi=170, f_lo=46, punch=0.03, k=2.5):
    t = tt(d)
    f = f_lo + (f_hi - f_lo) * np.exp(-t / punch)
    body = osc(f) * decay(len(t), d * 0.45, 0.001)
    click = filt(noise(0.006), lo=2000) * 0.5
    out = body
    out[: len(click)] += click
    return drive(out, k)


def snare(d=0.2, tone=190, bright=6500, amt=1.0):
    t = tt(d)
    body = osc(tone * (1 + 0.4 * np.exp(-t / 0.01))) * decay(len(t), 0.05)
    sn = filt(noise(d), lo=1200, hi=bright) * decay(len(t), d * 0.3)
    return drive(body * 0.6 + sn * amt, 1.5)


def hat(d=0.05, open_=False):
    t = tt(0.35 if open_ else d)
    metal = sum(osc(f, len(t) / SR, "square") for f in (2520, 3310, 4190, 5370, 6830)) / 5
    x = filt(noise(len(t) / SR) * 0.7 + metal * 0.5, lo=7000)
    return x * decay(len(t), 0.11 if open_ else 0.018)


def clap(d=0.25):
    out = buf(d)
    for k, off in enumerate((0.0, 0.011, 0.022)):
        place(out, filt(noise(0.012), lo=900, hi=4000) * decay(0.012, 0.004), off, 1.0 - 0.15 * k)
    tail = filt(noise(d - 0.03), lo=900, hi=5000) * decay(d - 0.03, 0.06)
    place(out, tail, 0.03, 0.8)
    return out


def crash(d=1.6):
    t = tt(d)
    metal = sum(osc(f * (1 + 0.002 * np.sin(2 * np.pi * 3 * t)), kind="square") for f in (3150, 4430, 5710, 7040, 8530)) / 5
    x = filt(noise(d) * 0.8 + metal * 0.35, lo=3500, hi=14000)
    return x * decay(len(t), d * 0.32, 0.001)


def tom(f=110, d=0.35):
    t = tt(d)
    return drive(osc(f * (1 + 0.6 * np.exp(-t / 0.04))) * decay(len(t), d * 0.4), 1.8)


def pluck(f, d=0.45, bright=1.0):
    """Marimba: fondamentale + armonica 4 che muore in fretta, attacco di legno."""
    t = tt(d)
    x = osc(f, d) * decay(len(t), d * 0.4) + 0.35 * bright * osc(f * 4.0, d) * decay(len(t), 0.05)
    x += 0.12 * bright * osc(f * 9.9, d) * decay(len(t), 0.012)
    return x


def bell(f, d=0.8):
    t = tt(d)
    parts = ((1.0, 1.0, d * 0.5), (2.76, 0.45, d * 0.25), (5.4, 0.25, d * 0.12), (8.93, 0.12, 0.05))
    return sum(a * osc(f * r, d) * decay(len(t), tau) for r, a, tau in parts)


def brass(f, d=0.5, bright=3200, dark=500, vib=0.0, att=0.03, rel=0.08, detune=0.004):
    """Ottoni da cartone: tre seghe un po' stonate tra loro, filtro che si apre all'attacco e si richiude ("uah")."""
    n = n_of(d)
    t = np.arange(n) / SR
    fv = f * (1 + vib * np.sin(2 * np.pi * 5.6 * t) * np.clip(t / 0.25, 0, 1))
    x = (osc(fv, kind="saw") + osc(fv * (1 + detune), kind="saw") + osc(fv * (1 - detune), kind="saw")) / 3
    x += 0.4 * osc(fv * 0.5)
    b_env = np.exp(-t / 0.18) * 0.7 + 0.3
    b_env *= np.clip(t / att, 0, 1)
    y = filt(x, hi=dark) * (1 - b_env) + filt(x, hi=bright) * b_env
    return drive(y * adsr(n, att, 0.2, 0.75, rel), 1.4)


def tuba(f, d=0.4):
    n = n_of(d)
    x = osc(f, d, "saw") * 0.6 + osc(f, d) * 0.7
    y = filt(x, hi=700, peak=f * 3, q=2.0)
    return drive(y * adsr(n, 0.012, 0.15, 0.6, 0.06), 1.6)


def synth_bass(f, d=0.2, cutoff=1100):
    n = n_of(d)
    t = np.arange(n) / SR
    x = osc(f, d, "saw") * 0.7 + osc(f * 0.5, d, "square") * 0.35
    dark = filt(x, hi=250)
    bright = filt(x, hi=cutoff, peak=cutoff * 0.8, q=2.5)
    e = np.exp(-t / 0.06)
    return drive((dark * (1 - e) + bright * e) * adsr(n, 0.004, 0.1, 0.7, 0.03), 2.0)


def theremin_line(notes, beat, total, glide=0.05, vib_rate=5.8, vib_depth=0.012):
    """Il theremin dello scienziato pazzo: una sola voce che scivola tra le note con un vibrato largo."""
    n = n_of(total)
    t = np.arange(n) / SR
    freq = np.full(n, midi(notes[0][2]))
    amp = np.zeros(n)
    since = np.zeros(n)
    cur = midi(notes[0][2])
    for (start, dur, m) in notes:
        s, e = n_of(start * beat), min(n, n_of((start + dur) * beat))
        target = midi(m)
        g = n_of(glide)
        seg = np.full(e - s, target)
        k = min(g, e - s)
        seg[:k] = cur * (target / cur) ** np.linspace(0, 1, k)
        freq[s:e] = seg
        cur = target
        a = np.ones(e - s)
        a[: n_of(0.03)] = np.linspace(0.55, 1, len(a[: n_of(0.03)]))
        r = n_of(0.06)
        a[-r:] *= np.linspace(1, 0.15, len(a[-r:]))
        amp[s:e] = np.maximum(amp[s:e], a)
        since[s:e] = np.arange(e - s) / SR
    # tra due note staccate resta la frequenza dell'ultima
    for i in range(1, n):
        if amp[i] == 0:
            freq[i] = freq[i - 1]
    vib = 1 + vib_depth * np.sin(2 * np.pi * vib_rate * t) * np.clip(since / 0.18, 0, 1)
    f = freq * vib
    x = osc(f) + 0.18 * osc(f * 2) + 0.06 * osc(f * 3)
    amp = np.convolve(amp, np.ones(n_of(0.012)) / n_of(0.012), mode="same")
    return x * amp


def geiger_crackle(d, rate=6.0, seed=3):
    r = np.random.default_rng(seed)
    out = buf(d)
    tcur = 0.0
    while True:
        tcur += r.exponential(1 / rate)
        if tcur >= d:
            break
        c = filt(r.uniform(-1, 1, n_of(0.003)), lo=1800, hi=7000) * decay(0.003, 0.0008, 0)
        place(out, c, tcur, r.uniform(0.4, 1.0))
    return out


def riser(d=1.0, f0=300, f1=4000):
    n = n_of(d)
    x = noise(d)
    lo = filt(x, lo=f0 * 0.7, hi=f0 * 1.6)
    hi = filt(x, lo=f1 * 0.6, hi=f1 * 1.4)
    p = np.linspace(0, 1, n) ** 2
    return (lo * (1 - p) + hi * p) * np.linspace(0.1, 1, n) ** 2


# --------------------------------------------------------------------------- effetti sonori

def sfx_tap():
    x = osc(exp_sweep(1300, 620, 0.05)) * decay(0.05, 0.012, 0.0005)
    x += 0.5 * osc(2600, 0.05) * decay(0.05, 0.004, 0.0005)
    return x


def sfx_card_pick():
    d = 0.16
    sw = filt(noise(d), lo=2500, hi=9000) * np.sin(np.linspace(0, np.pi, n_of(d))) ** 2
    blip = osc(exp_sweep(700, 1150, 0.07)) * decay(0.07, 0.03)
    out = buf(0.2)
    place(out, sw, 0, 0.6)
    place(out, blip, 0.02, 0.5)
    return out


def sfx_card_drop():
    blip = osc(exp_sweep(900, 520, 0.08)) * decay(0.08, 0.03)
    sw = filt(noise(0.1), lo=1800, hi=6000) * decay(0.1, 0.03)
    out = buf(0.12)
    place(out, blip, 0, 0.6)
    place(out, sw, 0, 0.4)
    return out


def sfx_whoosh():
    d = 0.28
    n = n_of(d)
    x = noise(d)
    p = np.linspace(0, 1, n)
    y = filt(x, lo=500, hi=1500) * (1 - p) + filt(x, lo=2500, hi=7000) * p
    return y * np.sin(p * np.pi) ** 1.5


def sfx_land():
    """Una creatura atterra nel recinto: tonfo pieno, polvere e una molla da cartone."""
    out = buf(0.6)
    place(out, kick(0.35, 140, 42, 0.025, 3.0), 0, 1.0)
    place(out, filt(noise(0.25), hi=900) * decay(0.25, 0.06), 0, 0.5)
    t = tt(0.4)
    boing = osc(260 * (1 + 0.35 * np.sin(2 * np.pi * 16 * t) * np.exp(-t / 0.12))) * decay(len(t), 0.13, 0.004)
    place(out, boing, 0.02, 0.35)
    return reverb(out, 0.5, 0.12)


def sfx_clank():
    """Una struttura cade sul tavolo: lamiera che risuona più il tonfo."""
    out = buf(0.9)
    place(out, kick(0.3, 120, 50, 0.02, 2.0), 0, 0.8)
    t = tt(0.8)
    metal = sum(a * osc(f, 0.8) * decay(len(t), tau) for f, a, tau in
                ((523, 1.0, 0.25), (1312, 0.7, 0.16), (2207, 0.5, 0.1), (3480, 0.35, 0.06), (4911, 0.2, 0.03)))
    place(out, metal, 0.004, 0.45)
    place(out, filt(noise(0.04), lo=2000) * decay(0.04, 0.008), 0, 0.5)
    return reverb(out, 0.7, 0.18)


def sfx_jump():
    """Rincorsa dell'attacco: fischio che sale e uno spostamento d'aria."""
    d = 0.22
    t = tt(d)
    w = osc(exp_sweep(320, 1100, d)) * np.sin(np.linspace(0, np.pi, len(t))) * 0.5
    sw = filt(noise(d), lo=900, hi=4000) * np.sin(np.linspace(0, np.pi, len(t))) ** 2
    return w + sw * 0.7


def sfx_hit():
    """Pugno da cartone: cassa, schiocco e uno scricchiolio distorto."""
    out = buf(0.5)
    place(out, kick(0.3, 210, 55, 0.02, 3.5), 0, 1.0)
    place(out, filt(noise(0.03), lo=1800, hi=9000) * decay(0.03, 0.006), 0, 0.9)
    crunch = drive(filt(noise(0.12), lo=300, hi=2500) * decay(0.12, 0.03), 4.0)
    place(out, crunch, 0.004, 0.45)
    return reverb(out, 0.4, 0.1)


def sfx_hit_hero():
    """Colpo alla Pazienza: più pesante, con un "dong" di metallo (il ritratto incassa)."""
    out = buf(1.0)
    place(out, kick(0.4, 180, 40, 0.03, 3.5), 0, 1.0)
    place(out, filt(noise(0.04), lo=1500) * decay(0.04, 0.008), 0, 0.8)
    place(out, bell(midi(50), 0.8), 0.005, 0.35)
    place(out, drive(filt(noise(0.15), lo=200, hi=1800) * decay(0.15, 0.04), 4), 0, 0.4)
    return reverb(out, 0.8, 0.16)


def sfx_botta():
    """BOTTA ATOMICA: scoppio, crollo nel sub, raggio radioattivo e crepitio Geiger che si spegne."""
    out = buf(2.6)
    t = tt(1.6)
    sub = osc(30 + 70 * np.exp(-t / 0.25)) * decay(len(t), 0.55, 0.001)
    place(out, drive(sub, 2.5), 0, 0.9)
    place(out, kick(0.4, 260, 50, 0.02, 4.0), 0, 1.0)
    boom = filt(noise(1.6), hi=1400) * decay(1.6, 0.35, 0.002)
    place(out, drive(boom, 3.0), 0, 0.8)
    crack = filt(noise(0.06), lo=2500) * decay(0.06, 0.012)
    place(out, crack, 0, 0.9)
    zt = tt(0.6)
    zap = osc(exp_sweep(2400, 140, 0.6), kind="saw") * osc(55 * np.ones(len(zt)) * 1.0, kind="square")
    place(out, filt(zap, hi=5000) * decay(len(zt), 0.18), 0.01, 0.35)
    place(out, geiger_crackle(1.8, 40, 11) * np.linspace(1, 0, n_of(1.8)) ** 1.5, 0.15, 0.45)
    return reverb(out, 1.8, 0.28, 3500, 2)


def sfx_death():
    """Una creatura finisce nel Letamaio: fischio che scende, puff e scintille verdi."""
    out = buf(1.1)
    d = 0.55
    t = tt(d)
    f = exp_sweep(1300, 180, d) * (1 + 0.04 * np.sin(2 * np.pi * 9 * t))
    whistle = (osc(f) + 0.15 * osc(f * 2)) * adsr(len(t), 0.01, 0.4, 0.8, 0.1)
    place(out, whistle, 0, 0.5)
    place(out, filt(noise(0.35), lo=300, hi=3000) * decay(0.35, 0.09, 0.01), 0.42, 0.55)
    place(out, kick(0.2, 120, 60, 0.02, 2), 0.42, 0.4)
    for k in range(7):
        place(out, osc(midi(84 + rng.integers(0, 12)), 0.12) * decay(0.12, 0.03), 0.48 + k * 0.045, 0.18)
    return reverb(out, 0.9, 0.2)


def sfx_boing():
    """Scuotere: molla cartone che oscilla, poi un luccichio di Caos che sale."""
    out = buf(0.9)
    t = tt(0.5)
    f = 180 * (1 + 0.5 * np.sin(2 * np.pi * 13 * t) * np.exp(-t / 0.18)) * np.linspace(1, 1.25, len(t))
    place(out, (osc(f) + 0.3 * osc(f * 2.01)) * decay(len(t), 0.2, 0.004), 0, 0.7)
    for k, m in enumerate((76, 79, 83, 88)):
        place(out, bell(midi(m), 0.35), 0.12 + k * 0.05, 0.25)
    return reverb(out, 0.7, 0.2)


def sfx_zap():
    """Raggio dell'abilità: laser radioattivo che parte e ronza."""
    d = 0.42
    t = tt(d)
    f = exp_sweep(1800, 380, d)
    x = osc(f, kind="square") * 0.5 + osc(f * 1.5, kind="saw") * 0.3
    x *= 0.6 + 0.4 * osc(60.0, d, "square")
    x = filt(x, lo=200, hi=6000) * decay(len(t), 0.16, 0.002)
    return reverb(x, 0.4, 0.12)


def sfx_buff():
    """Cura, +DEF, +ATK: arpeggio che sale, campanelle."""
    out = buf(0.9)
    for k, m in enumerate((72, 76, 79, 84)):
        place(out, bell(midi(m), 0.5), k * 0.055, 0.35)
        place(out, pluck(midi(m), 0.3), k * 0.055, 0.15)
    return reverb(out, 0.8, 0.2)


def sfx_debuff():
    out = buf(0.9)
    for k, m in enumerate((67, 63, 60, 56)):
        place(out, filt(osc(midi(m), 0.18, "saw"), hi=1800) * decay(0.18, 0.07), k * 0.06, 0.45)
    t = tt(0.4)
    place(out, filt(osc(exp_sweep(300, 90, 0.4), kind="square"), hi=900) * decay(len(t), 0.15), 0.24, 0.35)
    return reverb(out, 0.6, 0.15)


def sfx_caos():
    """Caos guadagnato: bolle radioattive che salgono."""
    out = buf(0.7)
    for k in range(6):
        d = 0.09
        f0 = 300 + 140 * k + rng.uniform(-30, 30)
        place(out, osc(exp_sweep(f0, f0 * 2.6, d)) * decay(d, 0.04, 0.003), k * 0.06, 0.5)
    return reverb(out, 0.6, 0.18)


def sfx_hero_power():
    """Abilità del sopravvissuto: accordo d'ottoni che sale con un raggio."""
    out = buf(1.4)
    place(out, riser(0.35, 400, 3500), 0, 0.35)
    for m in (60, 64, 67, 72):
        place(out, brass(midi(m), 0.55, 4200, 600), 0.3, 0.3)
    place(out, kick(0.3), 0.3, 0.6)
    place(out, crash(1.0), 0.3, 0.25)
    return reverb(out, 1.0, 0.22)


def sfx_turn_you():
    """"Tocca a te!": due colpi d'ottoni che salgono e un rullante."""
    out = buf(1.2)
    place(out, snare(0.15) * 0.5, 0.0, 0.5)
    for m in (55, 59, 62):
        place(out, brass(midi(m), 0.14, 3800), 0.0, 0.32)
    for m in (60, 64, 67, 72):
        place(out, brass(midi(m), 0.5, 4200, 700, vib=0.006), 0.16, 0.3)
    place(out, kick(0.3), 0.16, 0.6)
    place(out, crash(0.9), 0.16, 0.18)
    return reverb(out, 0.9, 0.2)


def sfx_turn_opp():
    """Turno dell'avversario: "dun dun" basso e un po' minaccioso."""
    out = buf(1.2)
    for k, ms in enumerate(((40, 47), (39, 46))):
        for m in ms:
            place(out, brass(midi(m), 0.32, 1500, 300), k * 0.3, 0.4)
        place(out, tom(70 - k * 6, 0.4), k * 0.3, 0.7)
    return reverb(out, 1.0, 0.22)


def sfx_lever():
    """Fine turno: leva di ferro tirata più un ding."""
    out = buf(0.8)
    place(out, filt(noise(0.05), lo=600, hi=3000) * decay(0.05, 0.012), 0, 0.6)
    place(out, kick(0.2, 300, 90, 0.01, 2), 0.04, 0.5)
    place(out, filt(noise(0.03), lo=1500, hi=5000) * decay(0.03, 0.008), 0.09, 0.6)
    place(out, bell(midi(79), 0.6), 0.1, 0.45)
    return reverb(out, 0.6, 0.15)


def sfx_tick():
    """Un clic del contatore Geiger (il mirino che gira)."""
    c = filt(noise(0.004), lo=1800, hi=8000) * decay(0.004, 0.0009, 0)
    out = buf(0.03)
    place(out, c, 0, 1.0)
    return out


def sfx_dial_colpo():
    out = buf(0.8)
    place(out, bell(midi(84), 0.6), 0, 0.6)
    place(out, bell(midi(91), 0.5), 0.05, 0.4)
    place(out, kick(0.2, 200, 80), 0, 0.4)
    return reverb(out, 0.6, 0.18)


def sfx_dial_botta():
    """Mirino sul rosso: sirena radioattiva corta e un accordo che esplode."""
    out = buf(1.0)
    t = tt(0.45)
    siren = osc(900 + 350 * np.sin(2 * np.pi * 7 * t), kind="square")
    place(out, filt(siren, hi=3500) * adsr(len(t), 0.01, 0.2, 0.8, 0.05), 0, 0.25)
    for m in (72, 76, 79, 84):
        place(out, bell(midi(m), 0.7), 0.0, 0.3)
    place(out, geiger_crackle(0.6, 60, 5), 0.0, 0.5)
    return reverb(out, 0.8, 0.2)


def sfx_dial_normale():
    t = tt(0.25)
    x = osc(exp_sweep(260, 170, 0.25)) * decay(len(t), 0.08) + 0.4 * filt(noise(0.25), hi=600) * decay(len(t), 0.03)
    return x


def sfx_deny():
    t = tt(0.22)
    x = filt(osc(140, 0.22, "square") + osc(147, 0.22, "saw"), hi=1500) * adsr(len(t), 0.005, 0.1, 0.8, 0.04)
    return x


def sfx_win():
    """Vittoria: fanfara d'ottoni con rullo di tamburi e piatto."""
    out = buf(3.4)
    beat = 0.13
    for k in range(10):
        place(out, snare(0.1, amt=0.8), k * 0.035, 0.18 + 0.03 * k)
    seq = ((0, 67), (1, 72), (2, 76), (3, 79))
    for i, m in seq:
        for mm in (m, m - 12):
            place(out, brass(midi(mm), beat * 0.95, 4500, 800), 0.35 + i * beat, 0.25)
        place(out, pluck(midi(m + 12), 0.3), 0.35 + i * beat, 0.2)
    t0 = 0.35 + 4 * beat
    for m in (60, 64, 67, 72, 76, 84):
        place(out, brass(midi(m), 1.6, 5000, 900, vib=0.008, rel=0.5), t0, 0.22)
    place(out, kick(0.5), t0, 0.9)
    place(out, crash(2.4), t0, 0.4)
    for k in range(6):
        place(out, bell(midi(96 - k * 2), 0.6), t0 + 0.1 + k * 0.07, 0.12)
    return reverb(out, 1.6, 0.25)


def sfx_lose():
    """Sconfitta: trombone triste che scende, l'ultima nota trema."""
    out = buf(3.2)
    notes = ((0.0, 0.42, 55), (0.48, 0.42, 54), (0.96, 0.42, 53), (1.44, 1.3, 52))
    for s, d, m in notes:
        last = d > 1
        place(out, brass(midi(m), d, 1600 if not last else 2000, 350, vib=0.03 if last else 0.0, att=0.06, rel=0.3 if last else 0.06), s, 0.5)
    return reverb(out, 1.1, 0.2)


def sfx_coins():
    """Ricompensa: scatolette di latta che tintinnano."""
    out = buf(1.0)
    for k in range(7):
        f = rng.uniform(1900, 2900)
        t = tt(0.25)
        tin = sum(a * osc(f * r, 0.25) * decay(len(t), tau) for r, a, tau in ((1, 1, 0.08), (2.3, 0.5, 0.04), (3.9, 0.3, 0.02)))
        place(out, tin, k * 0.07 + rng.uniform(0, 0.02), 0.35)
    return reverb(out, 0.6, 0.15)


def sfx_resurrect():
    out = buf(2.0)
    place(out, riser(0.7, 250, 5000), 0, 0.4)
    for m in (60, 67, 72, 76, 79):
        t = tt(1.2)
        f = midi(m)
        choir = (osc(f, 1.2) + osc(f * 1.003, 1.2) + 0.4 * osc(f * 2, 1.2)) * adsr(len(t), 0.25, 0.4, 0.8, 0.4)
        place(out, choir, 0.6, 0.15)
    place(out, crash(1.4), 0.65, 0.25)
    return reverb(out, 1.4, 0.3)


def sfx_play():
    """"Gioca!": spostamento d'aria e un colpo d'ottoni pieno."""
    out = buf(1.4)
    place(out, riser(0.25, 600, 6000), 0, 0.45)
    for m in (60, 64, 67, 72):
        place(out, brass(midi(m), 0.7, 4800, 800, vib=0.006), 0.22, 0.3)
    place(out, kick(0.4), 0.22, 0.9)
    place(out, crash(1.1), 0.22, 0.3)
    return reverb(out, 0.9, 0.2)


def sfx_swish():
    """Frecce della home: il personaggio cambia."""
    d = 0.2
    p = np.linspace(0, 1, n_of(d))
    x = noise(d)
    y = filt(x, lo=3000, hi=9000) * (1 - p) + filt(x, lo=800, hi=2500) * p
    return y * np.sin(p * np.pi) ** 1.5


def sfx_pop():
    t = tt(0.12)
    return osc(exp_sweep(400, 900, 0.12)) * decay(len(t), 0.035, 0.002) + 0.3 * pluck(midi(84), 0.12)


SFX = {
    "tap": (sfx_tap, 0.45), "card_pick": (sfx_card_pick, 0.55), "card_drop": (sfx_card_drop, 0.45),
    "whoosh": (sfx_whoosh, 0.6), "land": (sfx_land, 0.9), "clank": (sfx_clank, 0.8), "jump": (sfx_jump, 0.55),
    "hit": (sfx_hit, 0.9), "hit_hero": (sfx_hit_hero, 0.95), "botta": (sfx_botta, 1.0), "death": (sfx_death, 0.8),
    "boing": (sfx_boing, 0.75), "zap": (sfx_zap, 0.65), "buff": (sfx_buff, 0.6), "debuff": (sfx_debuff, 0.6),
    "caos": (sfx_caos, 0.55), "hero_power": (sfx_hero_power, 0.85), "turn_you": (sfx_turn_you, 0.75),
    "turn_opp": (sfx_turn_opp, 0.7), "lever": (sfx_lever, 0.7), "tick": (sfx_tick, 0.5),
    "dial_colpo": (sfx_dial_colpo, 0.7), "dial_botta": (sfx_dial_botta, 0.8), "dial_normale": (sfx_dial_normale, 0.6),
    "deny": (sfx_deny, 0.45), "win": (sfx_win, 0.9), "lose": (sfx_lose, 0.8), "coins": (sfx_coins, 0.6),
    "resurrect": (sfx_resurrect, 0.85), "play": (sfx_play, 0.9), "swish": (sfx_swish, 0.5), "pop": (sfx_pop, 0.5),
}


# --------------------------------------------------------------------------- musiche

class Track:
    def __init__(self, seconds):
        self.L = buf(seconds)
        self.R = buf(seconds)

    def add(self, x, start, gain=1.0, pan=0.0):
        a = (pan + 1) * np.pi / 4
        place(self.L, x, start, gain * np.cos(a) * 1.414)
        place(self.R, x, start, gain * np.sin(a) * 1.414)


def render_loop(name, bars, bpm, build, reverb_mix=0.16):
    beat = 60.0 / bpm
    loop_len = bars * 4 * beat
    tail = 3.0
    tr = Track(loop_len + tail)
    build(tr, beat)
    L = reverb(tr.L, 1.3, reverb_mix, 4500, 21)[: len(tr.L)]
    R = reverb(tr.R, 1.3, reverb_mix, 4500, 22)[: len(tr.R)]
    n = n_of(loop_len)
    outs = []
    for ch in (L, R):
        y = ch[:n].copy()
        y[: len(ch) - n] += ch[n:]          # la coda rientra all'inizio: il giro si chiude senza stacco
        outs.append(y)
    L, R = outs
    m = max(np.max(np.abs(L)), np.max(np.abs(R)))
    L, R = drive(L / m * 1.1, 1.2) * 0.85, drive(R / m * 1.1, 1.2) * 0.85
    wav = os.path.join(MUS_DIR, name + ".wav")
    write_wav(wav, L, R)
    ogg = os.path.join(MUS_DIR, name + ".ogg")
    try:
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-c:a", "libvorbis", "-q:a", "5", ogg], check=True)
        os.remove(wav)
        print("  musica", name, "%.1f s" % loop_len)
    except (OSError, subprocess.CalledProcessError):
        print("  ffmpeg non trovato: resta", wav)


def chord_tones(root_name):
    return {
        "C": (60, 64, 67), "Am": (57, 60, 64), "F": (57, 60, 65), "G": (55, 59, 62), "Ab": (56, 60, 63),
        "G7": (55, 59, 65), "E": (56, 59, 64), "Fm": (56, 60, 65), "Dm": (57, 62, 65),
    }[root_name]


def build_menu(tr, beat):
    """Home: tuba "oom-pah", marimba, theremin buffo e crepitio Geiger. Allegro e un po' storto."""
    chords = ["C", "Am", "F", "G", "C", "Ab", "F", "G7"]
    roots = {"C": 36, "Am": 33, "F": 29, "G": 31, "Ab": 32, "G7": 31}
    swing = 0.09
    for b, ch in enumerate(chords):
        t0 = b * 4 * beat
        r = roots[ch]
        tr.add(tuba(midi(r), beat * 0.9), t0, 0.55)
        tr.add(tuba(midi(r + 7), beat * 0.9), t0 + 2 * beat, 0.5)
        tr.add(tuba(midi(r + 12 if b % 2 else r + 7), beat * 0.45), t0 + 3.5 * beat + swing * beat, 0.35)
        for k in (1, 3):
            for m in chord_tones(ch):
                tr.add(pluck(midi(m), 0.25, 0.6), t0 + k * beat, 0.12, -0.35)
        tr.add(kick(0.3, 130, 45), t0, 0.55)
        tr.add(kick(0.3, 130, 45), t0 + 2 * beat, 0.45)
        tr.add(snare(0.16, bright=5000, amt=0.7), t0 + beat, 0.22, 0.1)
        tr.add(snare(0.16, bright=5000, amt=0.7), t0 + 3 * beat, 0.22, 0.1)
        for e in range(8):
            off = (swing * beat) if e % 2 else 0.0
            tr.add(hat(), t0 + e * beat / 2 + off, 0.12 if e % 2 else 0.07, 0.4)
        if b == 7:
            for s in range(4):
                tr.add(snare(0.1, amt=0.8), t0 + 3 * beat + s * beat / 4, 0.12 + 0.04 * s, 0.1)
        if b >= 4:   # seconda metà: marimba che rincorre la melodia
            tones = chord_tones(ch)
            for e, idx in enumerate((0, 1, 2, 1, 0, 2, 1, 2)):
                off = (swing * beat) if e % 2 else 0.0
                tr.add(pluck(midi(tones[idx] + 12), 0.2), t0 + e * beat / 2 + off, 0.09, 0.45)
    mel = [
        (0, 1.5, 67), (1.5, 0.5, 64), (2, 1, 67), (3, 1, 72),
        (4, 1.5, 69), (5.5, 0.5, 71), (6, 2, 72),
        (8, 1, 77), (9, 1, 76), (10, 1, 74), (11, 1, 72),
        (12, 2.5, 74), (15, 1, 67),
        (16, 1.5, 72), (17.5, 0.5, 67), (18, 1, 72), (19, 1, 76),
        (20, 2, 75), (22, 1, 72), (23, 1, 68),
        (24, 1, 69), (25, 1, 72), (26, 1, 77), (27, 1, 76),
        (28, 2, 74), (30, 1.8, 71),
    ]
    tr.add(theremin_line(mel, beat, 32 * beat + 1), 0, 0.2, 0.25)
    tr.add(geiger_crackle(32 * beat, 3.0, 9), 0, 0.12, -0.6)


def build_match(tr, beat):
    """Partita: più spinta. Basso a ottavi, cassa dritta, ottoni a contrattempo; nella seconda metà entra il theremin."""
    chords = ["Am", "Am", "F", "G", "Am", "Am", "F", "E"] * 2
    roots = {"Am": 45, "F": 41, "G": 43, "E": 40}
    for b, ch in enumerate(chords):
        t0 = b * 4 * beat
        r = roots[ch]
        for e in range(8):
            m = r + (12 if e in (2, 6) else 0) + (7 if e == 5 else 0)
            tr.add(synth_bass(midi(m - 12), beat * 0.45, 900 + 400 * (e % 2)), t0 + e * beat / 2, 0.42)
        for k in range(4):
            tr.add(kick(0.28, 150, 46, 0.025, 3.0), t0 + k * beat, 0.6)
        tr.add(clap(), t0 + beat, 0.32, 0.05)
        tr.add(clap(), t0 + 3 * beat, 0.32, 0.05)
        for s in range(16):
            acc = 1.0 if s % 4 == 2 else (0.55 if s % 2 else 0.35)
            tr.add(hat(open_=(s % 4 == 2 and b % 2 == 1)), t0 + s * beat / 4, 0.1 * acc, 0.45)
        # ottoni a contrattempo
        for pos, dur in ((1.5, 0.35), (3.5, 0.35)) if b % 2 == 0 else ((0.5, 0.3), (2.5, 0.6)):
            for m in chord_tones(ch):
                tr.add(brass(midi(m), dur * beat * 1.6, 3000, 500), t0 + pos * beat, 0.08, -0.3)
        if b < 8:   # prima metà: ostinato di marimba
            tones = chord_tones(ch)
            for e, idx in enumerate((0, 1, 2, 1, 2, 1, 0, 1)):
                tr.add(pluck(midi(tones[idx] + 12), 0.18), t0 + e * beat / 2, 0.1, 0.4)
        if b == 7:
            tr.add(riser(4 * beat, 300, 6000), t0, 0.18)
            for s in range(8):
                tr.add(snare(0.1), t0 + 2 * beat + s * beat / 4, 0.08 + 0.03 * s, -0.1)
        if b in (0, 8):
            tr.add(crash(2.0), t0, 0.2, 0.2)
    mel = [
        (0, 1.5, 76), (1.5, 0.5, 74), (2, 1, 72), (3, 1, 71),
        (4, 3, 69), (7, 1, 64),
        (8, 1.5, 72), (9.5, 0.5, 74), (10, 1, 76), (11, 1, 77),
        (12, 3, 79), (15, 1, 74),
        (16, 1.5, 81), (17.5, 0.5, 79), (18, 1, 76), (19, 1, 72),
        (20, 2, 74), (22, 2, 76),
        (24, 1, 77), (25, 1, 76), (26, 1, 74), (27, 1, 72),
        (28, 2, 71), (30, 1, 68), (31, 1, 64),
    ]
    tr.add(theremin_line(mel, beat, 32 * beat + 1, vib_depth=0.016), 32 * beat, 0.17, 0.25)
    tr.add(geiger_crackle(64 * beat, 2.0, 4), 0, 0.1, -0.6)


def main():
    only = set(sys.argv[1:])
    os.makedirs(SFX_DIR, exist_ok=True)
    for name, (fn, gain) in SFX.items():
        if only and name not in only:
            continue
        x = finish(fn()) * gain
        write_wav(os.path.join(SFX_DIR, name + ".wav"), x)
    print("effetti:", len(SFX))
    if not only or "music" in only:
        render_loop("menu", 8, 112, build_menu)
        render_loop("match", 16, 126, build_match)


if __name__ == "__main__":
    main()
