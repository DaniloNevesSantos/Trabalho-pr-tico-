class_name Util
extends RefCounted


const MASCARA_CORACAO := ["0110110", "1111111", "1111111", "0111110", "0011100", "0001000"]

static func novo_frames() -> SpriteFrames:
	var f := SpriteFrames.new()
	if f.has_animation("default"):
		f.remove_animation("default")
	return f


static func adiciona_anim(frames: SpriteFrames, nome: String, caminho: String, fw: int, fh: int, fps: float, loop: bool = true) -> void:
	var tex: Texture2D = load(caminho)
	if tex == null:
		push_error("Sprite não encontrado: " + caminho)
		return
	frames.add_animation(nome)
	frames.set_animation_speed(nome, fps)
	frames.set_animation_loop(nome, loop)
	var quantidade: int = tex.get_width() / fw
	for i in quantidade:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * fw, 0, fw, fh)
		frames.add_frame(nome, at)

static func frames_dino() -> SpriteFrames:
	var f := novo_frames()
	var base := "res://sprites/dino/"
	adiciona_anim(f, "idle", base + "idle.png", 24, 24, 6.0)
	adiciona_anim(f, "correr", base + "move.png", 24, 24, 12.0)
	adiciona_anim(f, "pular", base + "jump.png", 24, 24, 8.0, false)
	adiciona_anim(f, "ataque", base + "kick.png", 24, 24, 14.0, false)
	adiciona_anim(f, "dano", base + "hurt.png", 24, 24, 10.0, false)
	adiciona_anim(f, "morte", base + "dead.png", 24, 24, 7.0, false)
	return f


static func criar_tileset(pasta_terreno: String) -> TileSet:
	var tex: Texture2D = load(Dados.PASTA_CENARIOS + pasta_terreno + "/Terrain (16 x 16).png")
	var ts := TileSet.new()
	ts.tile_size = Vector2i(16, 16)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 0)
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(16, 16)
	ts.add_source(src)  # id 0
	var pontos := PackedVector2Array([Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)])
	for lin in [1, 2, 6]:
		for col in [3, 4, 5]:
			var c := Vector2i(col, lin)
			src.create_tile(c)
			var td := src.get_tile_data(c, 0)
			td.add_collision_polygon(0)
			td.set_collision_polygon_points(0, 0, pontos)
	return ts

static func _solido(mapa: Array, x: int, y: int) -> bool:
	if y < 0 or y >= mapa.size():
		return false
	var linha: String = mapa[y]
	if x < 0 or x >= linha.length():
		return false
	return linha[x] == "#"

## Escolhe o tile de bloco certo (cantos, bordas, meio) olhando os vizinhos.
static func autotile(mapa: Array, x: int, y: int) -> Vector2i:
	var topo := not _solido(mapa, x, y - 1)
	var base := not _solido(mapa, x, y + 1)
	var esq := not _solido(mapa, x - 1, y)
	var dir := not _solido(mapa, x + 1, y)
	var col := 4
	if esq and not dir:
		col = 3
	elif dir and not esq:
		col = 5
	var lin := 2
	if topo:
		lin = 1
	elif base:
		lin = 6
	return Vector2i(col, lin)

static func desenhar_coracao(ci: CanvasItem, pos: Vector2, px: float, cheio: bool) -> void:
	var cor_base := Color(0.95, 0.2, 0.25) if cheio else Color(0.25, 0.22, 0.3)
	var cor_luz := Color(1.0, 0.65, 0.65) if cheio else Color(0.35, 0.3, 0.4)
	for y in MASCARA_CORACAO.size():
		var linha: String = MASCARA_CORACAO[y]
		for x in linha.length():
			if linha[x] == "1":
				var c := cor_base
				if cheio and x == 1 and y == 1:
					c = cor_luz
				ci.draw_rect(Rect2(pos + Vector2(x, y) * px, Vector2(px, px)), c)

## Partículas de explosão/poeira que se apagam sozinhas.
static func explosao(pai: Node, pos: Vector2, cor: Color, quantidade: int = 14) -> void:
	var p := CPUParticles2D.new()
	p.position = pos
	p.amount = quantidade
	p.one_shot = true
	p.explosiveness = 1.0
	p.lifetime = 0.7
	p.spread = 180.0
	p.gravity = Vector2(0, 260)
	p.initial_velocity_min = 50.0
	p.initial_velocity_max = 130.0
	p.scale_amount_min = 1.5
	p.scale_amount_max = 3.0
	p.color = cor
	p.emitting = true
	pai.add_child.call_deferred(p)
	pai.get_tree().create_timer(1.2).timeout.connect(p.queue_free)

static func estilo_botao(b: Button, cor: Color = Color(0.95, 0.55, 0.15)) -> void:
	b.add_theme_stylebox_override("normal", _caixa_botao(cor.darkened(0.35)))
	b.add_theme_stylebox_override("hover", _caixa_botao(cor))
	b.add_theme_stylebox_override("pressed", _caixa_botao(cor.darkened(0.55)))
	b.add_theme_stylebox_override("focus", _caixa_botao(cor))
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.0))
	b.add_theme_constant_override("outline_size", 4)
	b.custom_minimum_size = Vector2(200, 40)

static func _caixa_botao(cor: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = cor
	s.set_corner_radius_all(6)
	s.set_border_width_all(3)
	s.border_color = cor.lightened(0.35)
	s.content_margin_top = 6.0
	s.content_margin_bottom = 6.0
	return s

static func estilo_painel(alfa: float = 0.88) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.07, 0.06, 0.12, alfa)
	s.set_corner_radius_all(8)
	s.set_border_width_all(3)
	s.border_color = Color(0.95, 0.6, 0.2, 0.9)
	return s

static func rotulo(tamanho: int, cor: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", cor)
	l.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.08))
	l.add_theme_constant_override("outline_size", 5)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("shadow_offset_x", 2)
	l.add_theme_constant_override("shadow_offset_y", 3)
	return l
