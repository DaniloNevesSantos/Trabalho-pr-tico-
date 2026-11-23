extends CharacterBody2D


const CENA_PROJETIL := preload("res://efeitos/projetil_inimigo.tscn")
const CENA_CARNE := preload("res://itens/carne.tscn")
const CENA_VIDA := preload("res://itens/vida_extra.tscn")

var tipo := "patrulha"
var vida := 1
var revida := false
var velocidade := 40.0
var alcance := 120.0
var direcao := -1.0
var morto := false
var _config: Dictionary = {}
var _escala := 1.0
var _modo := "normal"
var _modo_tempo := 0.0
var _tempo_tiro := 1.5
var _tempo_pulo := 1.0
var _flash := 0.0
var _origem := Vector2.ZERO
var _tempo_voo := 0.0

@onready var anim: AnimatedSprite2D = $Anim
@onready var borda: RayCast2D = $Borda
@onready var colisao: CollisionShape2D = $Colisao

func configurar(chave: String) -> void:
	_config = Dados.INIMIGOS[chave]

func _ready() -> void:
	add_to_group("inimigos")
	tipo = _config["tipo"]
	revida = _config["revida"]
	velocidade = _config["vel"]
	vida = _config["vida"]
	alcance = _config.get("alcance", 120.0)
	_escala = _config["escala"]
	var fw: int = _config["fw"]
	var fh: int = _config["fh"]
	var frames := Util.novo_frames()
	Util.adiciona_anim(frames, "andar", Dados.PASTA_PERSONAGENS + _config["folha"], fw, fh, 6.0)
	anim.sprite_frames = frames
	anim.scale = Vector2(_escala, _escala)
	anim.play("andar")
	var forma := RectangleShape2D.new()
	forma.size = Vector2(fw * _escala * 0.7, fh * _escala * 0.85)
	colisao.shape = forma
	borda.target_position = Vector2(0, fh * _escala * 0.5 + 10.0)
	borda.enabled = true
	_origem = global_position
	_tempo_tiro = randf_range(1.0, 2.5)
	_tempo_pulo = randf_range(0.5, 1.5)

func _physics_process(delta: float) -> void:
	if morto:
		return
	_modo_tempo = maxf(0.0, _modo_tempo - delta)
	if _modo_tempo <= 0.0:
		_modo = "normal"
	borda.position.x = direcao * (_escala * 8.0 + 2.0)
	if tipo == "atirador":
		_voar(delta)
	else:
		if not is_on_floor():
			velocity += get_gravity() * delta
		_andar(delta)
	move_and_slide()
	anim.flip_h = direcao < 0.0

func _andar(delta: float) -> void:
	var alvo := _jogador()
	var dx := 0.0
	if alvo:
		dx = alvo.global_position.x - global_position.x
	var v := velocidade
	if _modo == "revidar" and alvo:
		if dx != 0.0:
			direcao = signf(dx)
		v = velocidade * 2.2
	elif _modo == "fugir" and alvo:
		if dx != 0.0:
			direcao = -signf(dx)
		v = velocidade * 2.0
	elif tipo == "perseguidor" and alvo and absf(dx) < alcance:
		if dx != 0.0:
			direcao = signf(dx)
		v = velocidade * 1.8
	elif tipo == "pulador":
		_tempo_pulo -= delta
		if is_on_floor():
			v = 0.0
			if _tempo_pulo <= 0.0:
				velocity.y = -290.0
				_tempo_pulo = randf_range(1.2, 2.2)
				if alvo and dx != 0.0:
					direcao = signf(dx)
		else:
			v = velocidade * 1.6
	else:
		if is_on_wall() or (is_on_floor() and not borda.is_colliding()):
			direcao = -direcao
		v = velocidade
	velocity.x = direcao * v

func _voar(delta: float) -> void:
	_tempo_voo += delta
	if absf(global_position.x - _origem.x) > 90.0 or is_on_wall():
		direcao = -signf(global_position.x - _origem.x)
		if direcao == 0.0:
			direcao = -1.0
	velocity.x = direcao * velocidade
	velocity.y = sin(_tempo_voo * 2.2) * 45.0
	_tempo_tiro -= delta
	var alvo := _jogador()
	if _tempo_tiro <= 0.0 and alvo and absf(alvo.global_position.x - global_position.x) < 260.0:
		_tempo_tiro = 2.4
		_disparar(alvo)

func _disparar(alvo: Node2D) -> void:
	var p = CENA_PROJETIL.instantiate()
	p.direcao = (alvo.global_position - global_position).normalized()
	p.velocidade = 130.0
	p.position = global_position
	get_parent().add_child.call_deferred(p)

func levar_dano(qtd: int, _origem_dano: String = "") -> void:
	if morto:
		return
	vida -= qtd
	_flash = 0.12
	Jogo.som("acerto")
	if vida <= 0:
		_morrer()
		return
	if revida:
		_modo = "revidar"
		_modo_tempo = 2.5
	else:
		_modo = "fugir"
		_modo_tempo = 1.8

func _process(delta: float) -> void:
	if _flash > 0.0:
		_flash -= delta
		anim.modulate = Color(2.2, 2.2, 2.2)
	else:
		anim.modulate = Color.WHITE

func _morrer() -> void:
	morto = true
	colisao.set_deferred("disabled", true)
	Util.explosao(get_parent(), global_position, Color(1.0, 0.7, 0.2), 14)
	Jogo.som("morte")
	Jogo.tremor.emit(1.5)
	_soltar(CENA_CARNE)
	if randf() < Dados.CHANCE_VIDA_INIMIGO:
		_soltar(CENA_VIDA)
	queue_free()

func _soltar(cena: PackedScene) -> void:
	var item = cena.instantiate()
	item.position = global_position + Vector2(randf_range(-6.0, 6.0), -10.0)
	get_parent().add_child.call_deferred(item)

func _jogador() -> Node2D:
	return get_tree().get_first_node_in_group("jogador") as Node2D
