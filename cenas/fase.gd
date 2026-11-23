extends Node2D


const CENA_INIMIGO := preload("res://atores/inimigos/inimigo.tscn")
const CENA_CHEFE := preload("res://atores/chefes/chefe.tscn")
const CENA_CARNE := preload("res://itens/carne.tscn")
const CENA_VIDA := preload("res://itens/vida_extra.tscn")
const CENA_INTERAGIVEL := preload("res://itens/interagivel.tscn")

var nivel: Dictionary = {}
var largura := 0
var altura := 0

@onready var cenario: TileMapLayer = $Mundo/Cenario
@onready var entidades: Node2D = $Entidades
@onready var jogador = $Jogador
@onready var hud = $HUD

func _ready() -> void:
	nivel = Dados.MUNDOS[Jogo.mundo_atual - 1]
	var mapa: Array = nivel["mapa"]
	altura = mapa.size()
	largura = (mapa[0] as String).length()
	_montar_fundo()
	_montar_cenario(mapa)
	_montar_entidades(mapa)
	_configurar_camera()
	hud.titulo("Mundo %d · %s" % [Jogo.mundo_atual, nivel["nome"]])
	Jogo.tocar_musica("musica_mundo")

func _montar_fundo() -> void:
	var fundo := ParallaxBackground.new()
	add_child(fundo)
	move_child(fundo, 0)
	var ceu := ParallaxLayer.new()
	ceu.motion_scale = Vector2.ZERO
	fundo.add_child(ceu)
	var cor_ceu: Array = nivel["ceu"]
	var fundo_cor := ColorRect.new()
	fundo_cor.color = Color(cor_ceu[0], cor_ceu[1], cor_ceu[2])
	fundo_cor.size = Vector2(640, 320)
	ceu.add_child(fundo_cor)
	for camada in nivel["fundo"]:
		var pl := ParallaxLayer.new()
		pl.motion_scale = Vector2(camada[1], 0.0)
		pl.motion_mirroring = Vector2(432, 0)
		var sp := Sprite2D.new()
		sp.texture = load(Dados.PASTA_CENARIOS + camada[0])
		sp.centered = false
		sp.scale = Vector2(1.5, 1.5)
		sp.position = Vector2(0, 8)
		if camada[2]:
			sp.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
			var mat := ShaderMaterial.new()
			mat.shader = load("res://shaders/movement_nuvens.gdshader")
			mat.set_shader_parameter("move_speed", 0.015)
			sp.material = mat
		pl.add_child(sp)
		fundo.add_child(pl)
	var tom: Array = nivel["tom"]
	var cm := CanvasModulate.new()
	cm.color = Color(tom[0], tom[1], tom[2])
	add_child(cm)

func _montar_cenario(mapa: Array) -> void:
	cenario.tile_set = Util.criar_tileset(nivel["terreno"])
	for y in altura:
		var linha: String = mapa[y]
		for x in largura:
			if linha[x] == "#":
				cenario.set_cell(Vector2i(x, y), 0, Util.autotile(mapa, x, y))

func _montar_entidades(mapa: Array) -> void:
	var placas: Array = nivel["placas"].duplicate()
	for y in altura:
		var linha: String = mapa[y]
		for x in largura:
			var c := linha[x]
			var pos := Vector2(x * 16 + 8, y * 16 + 8)
			match c:
				"P":
					jogador.position = pos + Vector2(0, -6)
					Jogo.inicio_fase = jogador.position
				"C":
					_spawn(CENA_CARNE, pos)
				"V":
					_spawn(CENA_VIDA, pos)
				"T":
					_criar_interagivel(pos, "", true)
				"S":
					var texto := ""
					if placas.size() > 0:
						texto = placas.pop_front()
					_criar_interagivel(pos, texto, false)
				"B":
					_criar_chefe(pos)
				_:
					if Dados.CODIGO_INIMIGO.has(c):
						_criar_inimigo(Dados.CODIGO_INIMIGO[c], pos)
	if Jogo.tem_checkpoint:
		jogador.position = Jogo.checkpoint

func _spawn(cena: PackedScene, pos: Vector2) -> void:
	var n = cena.instantiate()
	n.position = pos
	entidades.add_child(n)

func _criar_inimigo(chave: String, pos: Vector2) -> void:
	var n = CENA_INIMIGO.instantiate()
	n.configurar(chave)
	n.position = pos
	entidades.add_child(n)

func _criar_chefe(pos: Vector2) -> void:
	var b = CENA_CHEFE.instantiate()
	b.configurar(nivel["chefe"])
	b.position = pos + Vector2(0, -20)
	b.morreu.connect(_chefe_derrotado)
	entidades.add_child(b)

func _criar_interagivel(pos: Vector2, texto: String, checkpoint: bool) -> void:
	var n = CENA_INTERAGIVEL.instantiate()
	n.mensagem = texto
	n.checkpoint = checkpoint
	n.position = pos
	entidades.add_child(n)

func _configurar_camera() -> void:
	var cam: Camera2D = jogador.get_node("Camera")
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = largura * 16
	cam.limit_bottom = altura * 16
	jogador.limite_queda = altura * 16 + 24.0

func _chefe_derrotado() -> void:
	Jogo.concluir_mundo()
