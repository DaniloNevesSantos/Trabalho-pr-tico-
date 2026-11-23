# 🦖 Super Dino

> Plataforma 2D em pixel art inspirada em Super Mario, feita na engine **Godot 4**.
> Trabalho prático de *Introdução ao Desenvolvimento de Jogos* — IFMG Campus Ribeirão das Neves.

## 1. Proposta do jogo (Entrega 1)

**Título:** Super Dino

**Narrativa/tema:** Em um mundo pré-histórico, um dinossauro precisa atravessar cinco regiões para recuperar a paz do seu mundo. Robôs técnicos querem acabar com a natureza e se aliaram a inimigos do próprio mundo. O jogador percorre cada região, enfrenta os inimigos e derrota o chefe de cada mundo, até chegar ao líder mecânico, que está na fortaleza final.

**Objetivo:** Percorrer os 5 mundos, coletar carnes (a moeda do jogo), derrotar os chefes de cada mundo e, por fim, o Líder Mecânico. Ao final, se o jogador tiver coletado pelo menos **20 carnes**, conquista a **coroa** e se torna o rei do mundo.

**Ações do jogador (controles):**

| Ação | Tecla |
|---|---|
| Mover para a esquerda / direita | `A` / `D` (ou setas) |
| Pular (segure para pulo alto) | `ESPAÇO` |
| Ataque especial: sopro de fogo | `TAB` |
| Interagir (placas, totens de checkpoint) | `E` |
| Reviver (na tela de derrota) | `R` |
| Pausa (continuar, menu ou sair) | `ESC` |

**Inimigos e obstáculos** — todos derrotados pulando na cabeça (estilo Mário), exceto quando indicado:

| Inimigo | Comportamento |
|---|---|
| Octi, Robô-abóbora | **Patrulha**: anda de um lado para o outro e vira nas bordas e paredes |
| Mochi, Onion | **Perseguidor**: corre atrás do jogador quando ele se aproxima |
| Daikon | **Pulador**: pula de tempos em tempos |
| Caranguejo, Totem robô, Queijo tanque | **Patrulha que revida**: ao ser atingido, parte para cima do jogador (alguns têm mais vida) |
| Cereja foguete | **Atirador**: voa e dispara mísseis mirados no jogador |

Inimigos que **não revidam** (Octi, Daikon, Onion) fogem quando atingidos. Encostar de lado em qualquer inimigo causa dano; cair em buracos também.

**Itens e coletáveis:**
- **Carne** (moeda): cai dos inimigos derrotados (1 por inimigo) e aparece em abundância nos chefes (10 por chefe).
- **Coração extra**: 8% de chance ao derrotar inimigos comuns; 100% de chance ao derrotar um chefe, que solta de 1 a 3 corações.
- **Totem checkpoint**: salva o ponto de renascimento e recupera 1 coração.
- **Placas**: mostram dicas do mundo.

**Condições de vitória:** derrotar o chefe de cada um dos 5 mundos. Com pelo menos 20 carnes, a coroa é desbloqueada.

**Condições de derrota:** perder todos os corações (3 no início, até 5 com corações extras). Cair em um buraco também tira um coração. Na tela de derrota, `R` revive no último checkpoint.

**Progressão/dificuldade:** o jogo tem 5 mundos, cada um com um cenário e uma trilha de tons próprios:

1. **Vale Verde** — chefe *Tanque*: investe contra o jogador e solta bombas.
2. **Floresta Outonal** — chefe *Totem Mecânico*: salta e cria ondas de choque no chão.
3. **Ilhas Tropicais** — chefe *Cereja Foguete*: voa e dispara mísseis.
4. **Terra Gelada** — chefe *Caranguejo Rei*: ataca com a pinça (invulnerável nesse momento) e fica vulnerável depois.
5. **Fortaleza do Líder** — chefe *Líder Mecânico*: combina os estilos anteriores em 3 fases, cada vez mais rápidas.

A dificuldade não aumenta com o tempo; ela muda a cada chefe, que exige uma estratégia diferente.

**Referências visuais/estéticas:** pixel art colorida, inspirada em Super Mario Bros. Cenários com parallax (camadas de nuvens, colinas, florestas, ilhas e montanhas), sprites de dinossauros e robôs no estilo pixel art, e efeitos de partículas nas explosões.

---

## 2. Requisitos técnicos atendidos (Entrega 2)

- [x] **Menu inicial** com Jogar, Créditos e Sair (`cenas/menu_principal.tscn`).
- [x] **Cena principal** com:
  - [x] **Câmera** seguindo o jogador, com limites de mundo e suavização (`Camera2D` filho do jogador).
  - [x] **TileMapLayer** para construção do cenário, com autotile de blocos (`cenas/fase.tscn` → `Mundo/Cenario`).
  - [x] **Inimigos com lógica de comportamento** (patrulha, perseguidor, pulador, atirador; revida ou foge).
  - [x] **Itens coletáveis** (carne, coração extra) e **uso** de itens (sopro de fogo, checkpoint).
  - [x] **Instâncias dinâmicas em tempo de execução**: projéteis do jogador, mísseis e bombas, carnes e corações que surgem ao derrotar inimigos, ondas de choque dos chefes.
  - [x] **Menu de pausa em `CanvasLayer`** (`cenas/interface/pausa.tscn`), com continuar, voltar ao menu e sair.
- [x] **Telas de final** (vitória com ou sem coroa, e derrota), com opções de reiniciar/reviver e voltar ao menu (`cenas/interface/tela_final.tscn`).
- [x] **Organização**: nós nomeados em português e arquivos separados por função (`atores/`, `cenas/`, `itens/`, `efeitos/`, `nucleo/`, `sprites/`, `sons/`).

## 3. Estrutura do projeto

```
super-dino/
├── project.godot            configurações (janela 640x320, parallax, autoload "Jogo")
├── nucleo/
│   ├── jogo.gd              autoload: vida, carnes, mundos, sons, teclas
│   ├── dados.gd             catálogo: inimigos, chefes e mapas dos 5 mundos
│   └── util.gd              animações, autotile, partículas, pixel art, estilos de UI
├── cenas/
│   ├── menu_principal.tscn  menu inicial
│   ├── creditos.tscn        créditos
│   ├── fase.tscn            cena principal (monta o mundo a partir do mapa)
│   └── interface/           hud, pausa (CanvasLayer), tela final
├── atores/
│   ├── jogador/             player.tscn / player.gd
│   ├── inimigos/            inimigo.tscn / inimigo.gd (comportamentos configuráveis)
│   └── chefes/              chefe.tscn / chefe.gd (5 estilos de luta)
├── itens/                   carne, vida extra, interagível (placa/checkpoint)
├── efeitos/                 projéteis do jogador e dos inimigos
├── sprites/                 cenários, personagens e dino (GrafxKid, CC0)
├── sons/                    efeitos sonoros e músicas (WAV)
└── shaders/                 movimento das nuvens
```

## 4. Como executar

1. Instale a **Godot 4.x** (o projeto foi escrito para a família 4.x; se a sua versão pedir, aceite a conversão automática).
2. Abra a Godot, clique em **Importar** e selecione o arquivo `project.godot`.
3. Pressione **F5** (Executar projeto). A cena inicial é o menu.

## 5. Créditos e licenças

- Tiles, cenários e personagens: **GrafxKid** (Seasonal Tilesets e Sprite Pack 2), licença **CC0 1.0**.
- Sprites do dino: material base da disciplina.
- Sons e músicas: gerados pela dupla por síntese procedural.
- Desenvolvido por: *[preencher os nomes da dupla]*.

## 6. Ferramentas (opcional)

- `ferramentas/dados_gen.py`: desenha os mapas dos 5 mundos e valida as posições. Gera `mundos_block.txt`, que foi colado em `nucleo/dados.gd`.
- `ferramentas/sons.py`: gera os efeitos e as músicas em `sons/` (rodar a partir da pasta `ferramentas/`).
