import wave, math, random, struct
SR = 22050
random.seed(7)
OUT = "../sons/"

def env(n, ataque=0.005, decaimento=None):
    out = []
    for i in range(n):
        t = i / SR
        a = min(1.0, t / ataque) if ataque > 0 else 1.0
        d = (1.0 - i / n) if decaimento is None else math.exp(-t / decaimento)
        out.append(a * d)
    return out

def onda(tipo, fase):
    f = fase - math.floor(fase)
    if tipo == "sq":
        return 1.0 if f < 0.5 else -1.0
    if tipo == "tri":
        return 4 * abs(f - 0.5) - 1
    return 0.0

def sweep(f0, f1, dur, tipo="sq", vol=0.4, decaimento=None):
    n = int(SR * dur)
    fase = 0.0
    e = env(n, 0.003, decaimento)
    out = []
    for i in range(n):
        f = f0 + (f1 - f0) * (i / n)
        fase += f / SR
        out.append(onda(tipo, fase) * e[i] * vol)
    return out

def nota(freq, dur, tipo="sq", vol=0.25):
    return sweep(freq, freq, dur, tipo, vol)

def ruido(dur, vol=0.3, decaimento=0.08):
    n = int(SR * dur)
    e = env(n, 0.001, decaimento)
    return [(random.random() * 2 - 1) * e[i] * vol for i in range(n)]

def mistura(*trilhas):
    n = max(len(t) for t in trilhas)
    out = [0.0] * n
    for t in trilhas:
        for i, v in enumerate(t):
            out[i] += v
    return out

def seq(*partes):
    out = []
    for p in partes:
        out += p
    return out

def salva(nome, amostras):
    pico = max(1e-6, max(abs(v) for v in amostras))
    k = min(1.0, 0.9 / pico)
    dados = b"".join(struct.pack("<h", int(max(-1, min(1, v * k)) * 32767)) for v in amostras)
    with wave.open(OUT + nome + ".wav", "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(dados)
    print(nome, round(len(amostras) / SR, 2), "s")

def midi(m):
    return 440.0 * 2 ** ((m - 69) / 12)

salva("pulo", sweep(420, 900, 0.14, "sq", 0.3))
salva("pisao", mistura(sweep(700, 180, 0.12, "sq", 0.35), ruido(0.06, 0.15)))
salva("dano", mistura(sweep(520, 110, 0.28, "sq", 0.35), ruido(0.2, 0.2)))
salva("carne", seq(nota(880, 0.06, "sq", 0.3), nota(1320, 0.1, "sq", 0.3)))
salva("vida", seq(nota(660, 0.07, "tri", 0.4), nota(880, 0.07, "tri", 0.4), nota(1320, 0.14, "tri", 0.4)))
salva("tiro", sweep(980, 260, 0.2, "sq", 0.28))
salva("morte", mistura(sweep(420, 70, 0.35, "sq", 0.3), ruido(0.3, 0.18, 0.12)))
salva("explosao", mistura(ruido(0.8, 0.5, 0.25), sweep(160, 40, 0.6, "tri", 0.35, 0.3)))
salva("acerto", mistura(sweep(360, 150, 0.08, "sq", 0.3), ruido(0.05, 0.1)))
salva("acerto_chefe", mistura(sweep(240, 90, 0.18, "sq", 0.35), ruido(0.15, 0.25)))
salva("chefe", mistura(sweep(70, 150, 0.7, "sq", 0.25), ruido(0.6, 0.15, 0.3)))
salva("checkpoint", seq(*[nota(midi(m), 0.09, "tri", 0.4) for m in (72, 76, 79, 84)]))
salva("placa", seq(nota(midi(76), 0.08, "tri", 0.35), nota(midi(72), 0.12, "tri", 0.35)))
salva("derrota", seq(*[nota(midi(m), 0.24, "sq", 0.25) for m in (67, 64, 60, 55)]))
salva("vitoria", seq(*[nota(midi(m), 0.14, "sq", 0.25) for m in (67, 71, 74, 79, 74, 79)]))

def trilha(nome, bpm, acordes, batida, melodia_tipo):
    beat = 60.0 / bpm
    partes_melodia = []
    partes_baixo = []
    for ac in acordes:
        raiz, terca, quinta = ac
        for passo in range(8):
            ordem = [raiz + 12, terca + 12, quinta + 12, terca + 12]
            nt = ordem[passo % 4] if melodia_tipo == "arp" else ordem[(passo * 3) % 4]
            partes_melodia.append(nota(midi(nt), beat / 2, "sq", 0.09))
        partes_baixo.append(nota(midi(raiz - 12), beat * 4, "tri", 0.22))
    melodia = seq(*partes_melodia)
    baixo = seq(*partes_baixo)
    # bateria simples: ruído curto no tempo forte
    perc = []
    total = len(melodia)
    base = [0.0] * total
    passo = int(SR * beat)
    for i in range(0, total, passo):
        pulso = ruido(0.04, 0.08, 0.02)
        for j, v in enumerate(pulso):
            if i + j < total:
                base[i + j] += v
    mix = mistura(melodia, baixo[:total] + [0.0] * max(0, total - len(baixo)), base)
    salva(nome, mix)

# acordes: (raiz, terça, quinta)
trilha("musica_menu", 96,
       [(60, 64, 67), (57, 60, 64), (53, 57, 60), (55, 59, 62)], None, "arp")
trilha("musica_mundo", 138,
       [(57, 60, 64), (53, 57, 60), (48, 52, 55), (52, 55, 59)], None, "dir")
