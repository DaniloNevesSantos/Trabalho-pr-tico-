import sys
W, H = 120, 20

def grid():
    g = [[' '] * W for _ in range(H)]
    for y in range(H):
        g[y][0] = '#'; g[y][W - 1] = '#'
    for x in range(1, W - 1):
        g[18][x] = '#'; g[19][x] = '#'
    return g

def rect(g, x1, x2, y1, y2, ch='#'):
    for y in range(y1, y2 + 1):
        for x in range(x1, x2 + 1):
            g[y][x] = ch

def pit(g, x1, x2, deep=False):
    y1 = 14 if deep else 18
    for y in range(y1, 20):
        for x in range(x1, x2 + 1):
            g[y][x] = ' '

def plat(g, x1, x2, y):
    rect(g, x1, x2, y, y + 1)

def ent(g, x, y, ch, air=False):
    if g[y][x] != ' ':
        raise Exception(f"ocupado: {ch} em {x},{y} (tem '{g[y][x]}')")
    if not air and g[y + 1][x] != '#':
        raise Exception(f"sem chao: {ch} em {x},{y}")
    g[y][x] = ch

def coins_plat(g, x1, x2, top):
    for x in range(x1, x2 + 1, 2):
        if g[top - 1][x] == ' ':
            g[top - 1][x] = 'C'

def coins_floor(g, step=5):
    for x in range(3, W - 3, step):
        if g[17][x] == ' ' and g[18][x] == '#' and g[16][x] == ' ':
            g[16][x] = 'C'

def fim(g):
    return [''.join(r) for r in g]

MUNDOS = []

# ---------- MUNDO 1: Vale Verde ----------
g = grid()
pit(g, 22, 25); pit(g, 58, 61); pit(g, 96, 99)
plat(g, 19, 28, 15); plat(g, 32, 36, 15); plat(g, 38, 42, 12); plat(g, 44, 48, 9)
plat(g, 55, 63, 15); plat(g, 64, 70, 15); plat(g, 72, 78, 12); plat(g, 80, 84, 9)
plat(g, 94, 101, 15)
ent(g, 2, 17, 'P'); ent(g, 4, 17, 'S'); ent(g, 46, 17, 'S'); ent(g, 40, 17, 'T')
ent(g, 12, 17, 'o'); ent(g, 30, 17, 'o'); ent(g, 45, 17, 'p'); ent(g, 52, 17, 'm')
ent(g, 68, 17, 'd'); ent(g, 78, 17, 'c'); ent(g, 88, 17, 't'); ent(g, 104, 17, 'l')
ent(g, 92, 6, 'x', air=True); ent(g, 46, 8, 'V', air=True); ent(g, 108, 17, 'B')
coins_floor(g)
for a, b, t in [(19,28,15),(32,36,15),(38,42,12),(44,48,9),(55,63,15),(64,70,15),(72,78,12),(80,84,9),(94,101,15)]:
    coins_plat(g, a, b, t)
MUNDOS.append(dict(
    nome="Vale Verde", terreno="1 - Grassland", ceu=[0.5, 0.8, 0.97], tom=[1.0, 1.0, 1.0],
    chefe="queijo",
    fundo=[["1 - Grassland/Background parts/4 - Cloud_cover_2.png", 0.15, True],
           ["1 - Grassland/Background parts/3 - Cloud_cover_1.png", 0.25, True],
           ["1 - Grassland/Background parts/2 - Hills.png", 0.45, False],
           ["1 - Grassland/Background parts/1 - Foreground_scenery.png", 0.75, False]],
    placas=["Bem-vindo ao Vale Verde! Use A e D para andar e ESPACO para pular.",
            "Tab solta um sopro de fogo! Pise na cabeca dos inimigos para derrota-los."],
    mapa=fim(g)))

# ---------- MUNDO 2: Floresta Outonal ----------
g = grid()
pit(g, 14, 17); pit(g, 44, 49); pit(g, 80, 84)
plat(g, 4, 10, 15); plat(g, 12, 18, 12); plat(g, 20, 26, 9); plat(g, 28, 34, 6)
plat(g, 40, 44, 15); plat(g, 48, 54, 12); plat(g, 56, 60, 15)
plat(g, 76, 82, 15); plat(g, 86, 90, 15)
ent(g, 2, 17, 'P'); ent(g, 6, 17, 'S'); ent(g, 50, 17, 'S'); ent(g, 60, 17, 'T')
ent(g, 24, 17, 'o'); ent(g, 37, 17, 'p'); ent(g, 66, 17, 'd'); ent(g, 74, 17, 'm')
ent(g, 94, 17, 'c'); ent(g, 102, 17, 'l'); ent(g, 40, 5, 'x', air=True)
ent(g, 31, 4, 'V', air=True); ent(g, 112, 17, 'B')
coins_floor(g)
for a, b, t in [(4,10,15),(12,18,12),(20,26,9),(28,34,6),(40,44,15),(48,54,12),(56,60,15),(76,82,15),(86,90,15)]:
    coins_plat(g, a, b, t)
MUNDOS.append(dict(
    nome="Floresta Outonal", terreno="2 - Autumn Forest", ceu=[0.98, 0.72, 0.45], tom=[1.0, 0.93, 0.85],
    chefe="totem",
    fundo=[["2 - Autumn Forest/Background parts/6 - Distant_trees.png", 0.1, False],
           ["2 - Autumn Forest/Background parts/4 - Tree_row_BG_1.png", 0.3, False],
           ["2 - Autumn Forest/Background parts/2 - Trees.png", 0.5, False],
           ["2 - Autumn Forest/Background parts/3 - Bottom_leaf_piles.png", 0.8, False]],
    placas=["Floresta Outonal: as plataformas sao mais altas. Escale com cuidado!",
            "Inimigos que revidam vao te perseguir. Os outros fogem de voce."],
    mapa=fim(g)))

# ---------- MUNDO 3: Ilhas Tropicais ----------
g = grid()
pit(g, 21, 25); pit(g, 53, 56); pit(g, 67, 72); pit(g, 91, 93); pit(g, 35, 39, deep=True)
rect(g, 26, 34, 15, 19); rect(g, 57, 66, 15, 19); plat(g, 60, 62, 12)
ent(g, 2, 17, 'P'); ent(g, 5, 17, 'S'); ent(g, 43, 17, 'S'); ent(g, 45, 17, 'T')
ent(g, 8, 17, 'd'); ent(g, 17, 17, 'l'); ent(g, 30, 14, 'c'); ent(g, 47, 17, 'd')
ent(g, 58, 14, 'm'); ent(g, 77, 17, 'p'); ent(g, 84, 17, 'c')
ent(g, 70, 6, 'x', air=True); ent(g, 61, 11, 'V', air=True); ent(g, 110, 17, 'B')
coins_floor(g)
for a, b, t in [(26,34,15),(57,66,15),(60,62,12)]:
    coins_plat(g, a, b, t)
MUNDOS.append(dict(
    nome="Ilhas Tropicais", terreno="3 - Tropics", ceu=[0.45, 0.85, 0.95], tom=[1.0, 1.0, 1.0],
    chefe="cereja",
    fundo=[["3 - Tropics/Background parts/4 - Background_clouds.png", 0.15, True],
           ["3 - Tropics/Background parts/3 - Floating_clouds.png", 0.3, True],
           ["3 - Tropics/Background parts/2 - Waters_version_2.png", 0.5, False],
           ["3 - Tropics/Background parts/1 - Waters_version_1.png", 0.75, False]],
    placas=["Ilhas Tropicais: nao caia no mar! Cada queda custa um coracao.",
            "Pressione E diante de um totem para salvar seu ponto de renascimento."],
    mapa=fim(g)))

# ---------- MUNDO 4: Terra Gelada ----------
g = grid()
pit(g, 18, 21); pit(g, 60, 63); pit(g, 100, 103)
plat(g, 16, 23, 15); plat(g, 40, 46, 15); plat(g, 50, 56, 12); plat(g, 58, 65, 15)
plat(g, 70, 74, 15); plat(g, 76, 80, 12); plat(g, 82, 86, 9); plat(g, 88, 93, 6)
ent(g, 2, 17, 'P'); ent(g, 6, 17, 'S'); ent(g, 42, 17, 'S'); ent(g, 33, 17, 'T')
ent(g, 10, 17, 'o'); ent(g, 26, 17, 'm'); ent(g, 37, 17, 't'); ent(g, 44, 14, 'm')
ent(g, 53, 11, 'o'); ent(g, 78, 11, 'l'); ent(g, 96, 17, 'c'); ent(g, 88, 3, 'x', air=True)
ent(g, 84, 8, 'V', air=True); ent(g, 112, 17, 'B')
coins_floor(g)
for a, b, t in [(16,23,15),(40,46,15),(50,56,12),(58,65,15),(70,74,15),(76,80,12),(82,86,9),(88,93,6)]:
    coins_plat(g, a, b, t)
MUNDOS.append(dict(
    nome="Terra Gelada", terreno="4 - Winter World", ceu=[0.6, 0.75, 0.92], tom=[0.92, 0.96, 1.0],
    chefe="caranguejo",
    fundo=[["4 - Winter World/Background parts/3 - Big_mountain_BG.png", 0.1, False],
           ["4 - Winter World/Background parts/2 - Smaller_mountains.png", 0.35, False],
           ["4 - Winter World/Background parts/1 - Snowy_foreground_area.png", 0.7, False]],
    placas=["Terra Gelada: o Caranguejo Rei fica invulneravel quando abre a pinca.",
            "Derrote-o quando ele estiver recuperando o folego!"],
    mapa=fim(g)))

# ---------- MUNDO 5: Fortaleza do Lider ----------
g = grid()
pit(g, 12, 16); pit(g, 40, 45); pit(g, 70, 76); pit(g, 104, 106)
plat(g, 10, 17, 15); rect(g, 28, 31, 15, 19); plat(g, 33, 38, 12); plat(g, 36, 46, 15)
rect(g, 56, 59, 15, 19); plat(g, 62, 68, 12); plat(g, 68, 78, 15)
plat(g, 84, 88, 12); plat(g, 92, 96, 9); plat(g, 102, 108, 15)
ent(g, 2, 17, 'P'); ent(g, 5, 17, 'S'); ent(g, 46, 17, 'S'); ent(g, 66, 17, 'T')
ent(g, 22, 17, 't'); ent(g, 25, 17, 'o'); ent(g, 49, 17, 'c'); ent(g, 82, 17, 'q')
ent(g, 97, 17, 'm'); ent(g, 86, 11, 'l'); ent(g, 100, 17, 'd'); ent(g, 63, 5, 'x', air=True)
ent(g, 94, 8, 'V', air=True); ent(g, 112, 17, 'B')
coins_floor(g)
for a, b, t in [(10,17,15),(33,38,12),(36,46,15),(62,68,12),(68,78,15),(84,88,12),(92,96,9),(102,108,15)]:
    coins_plat(g, a, b, t)
MUNDOS.append(dict(
    nome="Fortaleza do Lider", terreno="1 - Grassland", ceu=[0.3, 0.15, 0.25], tom=[0.62, 0.42, 0.55],
    chefe="lider",
    fundo=[["3 - Tropics/Background parts/4 - Background_clouds.png", 0.15, True],
           ["3 - Tropics/Background parts/3 - Floating_clouds.png", 0.3, True],
           ["3 - Tropics/Background parts/2 - Waters_version_2.png", 0.5, False],
           ["3 - Tropics/Background parts/1 - Waters_version_1.png", 0.75, False]],
    placas=["Fortaleza do Lider: a ultima batalha. Colete carne para ganhar a coroa!",
            "Use tudo que aprendeu: pulos, sopro de fogo e paciencia."],
    mapa=fim(g)))

# ---------- validacao ----------
for i, m in enumerate(MUNDOS, 1):
    rows = m['mapa']
    assert len(rows) == 20, i
    assert all(len(r) == W for r in rows), (i, [len(r) for r in rows])
    cnt = {}
    for r in rows:
        for c in r: cnt[c] = cnt.get(c, 0) + 1
    print(f"Mundo {i} {m['nome']}: P={cnt.get('P',0)} S={cnt.get('S',0)} T={cnt.get('T',0)} B={cnt.get('B',0)} C={cnt.get('C',0)} V={cnt.get('V',0)} inim={sum(cnt.get(k,0) for k in 'opmcdxtql')}", file=sys.stderr)
    assert cnt.get('P',0)==1 and cnt.get('B',0)==1 and cnt.get('S',0)==2 and cnt.get('T',0)==1

def gs(s): return '"' + s.replace('"', '\\"') + '"'

out = []
for m in MUNDOS:
    out.append('\t{')
    out.append(f'\t\t"nome": {gs(m["nome"])},')
    out.append(f'\t\t"terreno": {gs(m["terreno"])},')
    out.append(f'\t\t"ceu": {m["ceu"]},')
    out.append(f'\t\t"tom": {m["tom"]},')
    out.append(f'\t\t"chefe": {gs(m["chefe"])},')
    out.append('\t\t"fundo": [')
    for f, mo, nu in m['fundo']:
        out.append(f'\t\t\t[{gs(f)}, {mo}, {"true" if nu else "false"}],')
    out.append('\t\t],')
    out.append('\t\t"placas": [')
    for p in m['placas']:
        out.append(f'\t\t\t{gs(p)},')
    out.append('\t\t],')
    out.append('\t\t"mapa": [')
    for r in m['mapa']:
        out.append(f'\t\t\t"{r}",')
    out.append('\t\t],')
    out.append('\t},')
open('mundos_block.txt', 'w', encoding='utf-8').write('\n'.join(out) + '\n')
# print maps for visual check
for i, m in enumerate(MUNDOS, 1):
    print(f"--- {i} {m['nome']}")
    for r in m['mapa']:
        print(r)
