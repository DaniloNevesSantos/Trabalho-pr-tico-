extends CharacterBody2D


const VELOCIDADE := 165.0
const FORCA_PULO := -360.0
const TEMPO_INVENCIVEL := 1.3
const COOLDOWN_SOPRO := 0.8
const ESCALA := 1.75
const CENA_SOPRO := preload("res://efeitos/projetil_jogador.tscn")

var virado_direita := true
var morto := false
var limite_queda := 400.0
var _invencivel := 0.0
var _cooldown := 0.0
var _trava := 0.0
var _tremor := 0.0
var _ataque := 0.0
var _estava_no_chao := true

@onready var anim: AnimatedSprite2D = $Anim
@onready var camera: Camera2D = $Camera
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	add_to_group("jogador")
	anim.sprite_frames = Util.frames_dino()
	anim.scale = Vector2(ESCALA, ESCALA)
	anim.play("idle")
	hitbox.body_entered.connect(_ao_tocar_inimigo)
	Jogo.tremor.connect(_receber_tremor)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0

func _receber_tremor(intensidade: float) -> void:
	_tremor = maxf(_tremor, intensidade)

func _physics_process(delta: float) -> void:
	_invencivel = maxf(0.0, _invencivel - delta)
	_cooldown = maxf(0.0, _cooldown - delta)
	_trava = maxf(0.0, _trava - delta)
	_ataque = maxf(0.0, _ataque - delta)
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direcao := 0.0
	if not morto and _trava <= 0.0:
		direcao = Input.get_axis("mover_esquerda", "mover_direita")
		if Input.is_action_just_pressed("pular") and is_on_floor():
			velocity.y = FORCA_PULO
			Jogo.som("pulo")
			_esticar(0.75, 1.3)
		if Input.is_action_just_released("pular") and velocity.y < -120.0:
			velocity.y *= 0.45
		if Input.is_action_just_pressed("ataque_especial") and _cooldown <= 0.0:
			_sopro()
	if morto:
		direcao = 0.0
	velocity.x = direcao * VELOCIDADE
	if absf(direcao) > 0.01:
		virado_direita = direcao > 0.0

	move_and_slide()

	if is_on_floor() and not _estava_no_chao:
		_esticar(1.3, 0.75)
		Util.explosao(get_parent(), global_position + Vector2(0, 14), Color(0.8, 0.7, 0.5), 6)
	_estava_no_chao = is_on_floor()

	if not morto and global_position.y > limite_queda:
		_cair()
	_atualizar_anim()

func _process(delta: float) -> void:
	anim.visible = not (_invencivel > 0.0 and int(_invencivel * 14.0) % 2 == 0)
	if _tremor > 0.0:
		camera.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _tremor
		_tremor = move_toward(_tremor, 0.0, 14.0 * delta)
	else:
		camera.offset = Vector2.ZERO

func _esticar(fator_x: float, fator_y: float) -> void:
	anim.scale = Vector2(ESCALA * fator_x, ESCALA * fator_y)
	var t := create_tween()
	t.tween_property(anim, "scale", Vector2(ESCALA, ESCALA), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _sopro() -> void:
	_cooldown = COOLDOWN_SOPRO
	_ataque = 0.25
	var s = CENA_SOPRO.instantiate()
	s.direcao = 1.0 if virado_direita else -1.0
	s.position = global_position + Vector2(20.0 * s.direcao, -4.0)
	get_parent().add_child.call_deferred(s)
	Jogo.som("tiro")

func _atualizar_anim() -> void:
	var nome := "idle"
	if morto:
		nome = "morte"
	elif _ataque > 0.0:
		nome = "ataque"
	elif not is_on_floor():
		nome = "pular"
	elif absf(velocity.x) > 5.0:
		nome = "correr"
	if anim.animation != nome:
		anim.play(nome)
	anim.flip_h = not virado_direita

func _ao_tocar_inimigo(corpo: Node2D) -> void:
	if morto or not corpo.is_in_group("inimigos"):
		return
	var pisao := velocity.y > 0.0 and global_position.y < corpo.global_position.y - 6.0
	if pisao:
		corpo.levar_dano(1, "pisao")
		velocity.y = FORCA_PULO * 0.6
		_invencivel = maxf(_invencivel, 0.2)
		Jogo.som("pisao")
		_esticar(1.3, 0.7)
	else:
		sofrer_dano(1, corpo.global_position.x)

func sofrer_dano(qtd: int, origem_x: float) -> void:
	if morto or _invencivel > 0.0:
		return
	_invencivel = TEMPO_INVENCIVEL
	_trava = 0.25
	var lado := signf(global_position.x - origem_x)
	if lado == 0.0:
		lado = 1.0
	velocity = Vector2(lado * 170.0, -220.0)
	_tremor = 5.0
	Jogo.perder_vida(qtd)
	Jogo.som("dano")
	if Jogo.vida <= 0:
		_morrer()

func _cair() -> void:
	Jogo.som("dano")
	Jogo.perder_vida(1)
	if Jogo.vida <= 0:
		_morrer()
		return
	var destino: Vector2 = Jogo.checkpoint if Jogo.tem_checkpoint else Jogo.inicio_fase
	global_position = destino
	velocity = Vector2.ZERO
	_invencivel = TEMPO_INVENCIVEL
	_tremor = 6.0

func _morrer() -> void:
	if morto:
		return
	morto = true
	velocity = Vector2(0, -260)
	hitbox.set_deferred("monitoring", false)
	get_tree().create_timer(1.8).timeout.connect(Jogo.derrota)
