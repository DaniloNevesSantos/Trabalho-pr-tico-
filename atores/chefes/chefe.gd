extends CharacterBody2D


signal morreu

const CENA_PROJETIL := preload("res://efeitos/projetil_inimigo.tscn")
const CENA_VIDA := preload("res://itens/vida_extra.tscn")
const CENA_CARNE := preload("res://itens/carne.tscn")

var estilo := "carga"
var voa := false
var vida := 6
var vida_max := 6
var nome_chefe := "Chefe"
var _config: Dictionary = {}
var _cor_base := Color.WHITE
var _ativo := false
var _morto := false
var _escudo := false
var _invuln := 0.0
var _flash := 0.0
var _acao := "espera"
var _tempo := 1.2
var _tempo_bomba := 2.0
var _tempo_tiro := 1.0
var _tempo_ciclo := 0.0
var _subacao := "carga"
var _origem := Vector2.ZERO
var _dir := -1.0
var _tempo_voo := 0.0

@onready var anim: AnimatedSprite2D = $Anim
@onready var colisao: CollisionShape2D = $Colisao

func configurar(chave: String) -> void:
	_config = Dados.CHEFES[chave]

func _ready() -> void:
	add_to_group("inimigos")
	add_to_group("chefes")
	estilo = _config["estilo"]
	voa = _config["voa"]
	vida = _config["vida"]
	vida_max = vida
	nome_chefe = _config["nome"]
	var esc: float = _config["escala"]
	var fw: int = _config["fw"]
	var fh: int = _config["fh"]
	var frames := Util.novo_frames()
	Util.adiciona_anim(frames, "andar", Dados.PASTA_PERSONAGENS + _config["folha"], fw, fh, 5.0)
	var pinca: String = _config.get("pinca", _config["folha"])
	Util.adiciona_anim(frames, "atacar", Dados.PASTA_PERSONAGENS + pinca, fw, fh, 5.0)
	anim.sprite_frames = frames
	anim.scale = Vector2(esc, esc)
	anim.play("andar")
	var c: Array = _config["cor"]
	_cor_base = Color(c[0], c[1], c[2])
	anim.modulate = _cor_base
	var forma := RectangleShape2D.new()
	forma.size = Vector2(fw * esc * 0.6, fh * esc * 0.8)
	colisao.shape = forma
	_origem = global_position

func _physics_process(delta: float) -> void:
	if _morto:
		return
	var alvo := _jogador()
	if not voa and not is_on_floor():
		velocity += get_gravity() * delta
	if alvo and not _ativo and absf(alvo.global_position.x - global_position.x) < 300.0:
		_ativar()
	if not _ativo or alvo == null:
		velocity.x = 0.0
		if voa:
			velocity = Vector2.ZERO
		move_and_slide()
		_atualizar_visual()
		return
	_invuln = maxf(0.0, _invuln - delta)
	_flash = maxf(0.0, _flash - delta)
	_tempo_ciclo += delta
	match estilo:
		"carga":
			_carga(delta, alvo)
		"pulo":
			_pulo(delta, alvo)
		"tiro":
			_tiro(delta, alvo)
		"garra":
			_garra(delta, alvo)
		"lider":
			_lider(delta, alvo)
	move_and_slide()
	_atualizar_visual()

func _ativar() -> void:
	_ativo = true
	Jogo.chefe_status.emit(nome_chefe, vida, vida_max, true)
	Jogo.som("chefe")
	Jogo.tremor.emit(6.0)



func _carga(delta: float, alvo: Node2D) -> void:
	var dx := alvo.global_position.x - global_position.x
	_tempo -= delta
	_tempo_bomba -= delta
	if _tempo_bomba <= 0.0:
		_tempo_bomba = 2.0
		_bomba(alvo)
	match _acao:
		"espera":
			_dir = signf(dx) if dx != 0.0 else _dir
			velocity.x = _dir * 40.0
			if _tempo <= 0.0:
				_acao = "carrega"
				_tempo = 1.1
		"carrega":
			velocity.x = _dir * 240.0
			if is_on_wall() or _tempo <= 0.0:
				_acao = "atordoado"
				_tempo = 1.4
				velocity.x = 0.0
				Jogo.tremor.emit(4.0)
		"atordoado":
			velocity.x = 0.0
			if _tempo <= 0.0:
				_acao = "espera"
				_tempo = 1.0

func _pulo(delta: float, alvo: Node2D) -> void:
	var dx := alvo.global_position.x - global_position.x
	_tempo -= delta
	match _acao:
		"espera":
			velocity.x = 0.0
			if _tempo <= 0.0 and is_on_floor():
				_dir = signf(dx) if dx != 0.0 else _dir
				velocity.y = -430.0
				velocity.x = _dir * 150.0
				_acao = "no_ar"
				_tempo = 0.3
		"no_ar":
			if _tempo <= 0.0 and is_on_floor():
				_onda()
				_acao = "espera"
				_tempo = 1.8

func _tiro(delta: float, alvo: Node2D) -> void:
	_tempo_voo += delta
	_tempo_tiro -= delta
	var dx := alvo.global_position.x - global_position.x
	_dir = signf(dx) if dx != 0.0 else _dir
	if voa:
		var ponto := Vector2(_origem.x + sin(_tempo_voo * 0.9) * 130.0, _origem.y + sin(_tempo_voo * 1.4) * 30.0)
		velocity = (ponto - global_position) * 2.2
	else:
		velocity.x = _dir * 40.0
	if _tempo_tiro <= 0.0:
		_tempo_tiro = 1.4 if vida > vida_max * 0.5 else 0.9
		_mirar(alvo)

func _garra(delta: float, alvo: Node2D) -> void:
	var dx := alvo.global_position.x - global_position.x
	_tempo -= delta
	match _acao:
		"espera":
			_escudo = false
			_dir = signf(dx) if dx != 0.0 else _dir
			velocity.x = _dir * 35.0
			if _tempo <= 0.0:
				_acao = "pinca"
				_tempo = 0.7
				_escudo = true
		"pinca":
			velocity.x = _dir * 360.0
			if _tempo <= 0.0:
				_acao = "recupera"
				_tempo = 1.8
				_escudo = false
		"recupera":
			velocity.x = 0.0
			if _tempo <= 0.0:
				_acao = "espera"
				_tempo = 1.2

func _lider(delta: float, alvo: Node2D) -> void:
	if _tempo_ciclo > 4.5:
		_tempo_ciclo = 0.0
		var opcoes := ["carga"]
		var proporcao := float(vida) / float(vida_max)
		if proporcao < 0.66:
			opcoes = ["carga", "pulo"]
		if proporcao < 0.33:
			opcoes = ["pulo", "tiro", "carga"]
		_subacao = opcoes[randi() % opcoes.size()]
		_acao = "espera"
		_tempo = 0.6
	match _subacao:
		"carga":
			_carga(delta, alvo)
		"pulo":
			_pulo(delta, alvo)
		"tiro":
			_tiro(delta, alvo)



func _bomba(alvo: Node2D) -> void:
	var p = CENA_PROJETIL.instantiate()
	p.gravidade = true
	p.direcao = Vector2.DOWN
	p.velocidade = 0.0
	p.position = Vector2(alvo.global_position.x + randf_range(-24.0, 24.0), alvo.global_position.y - 130.0)
	get_parent().add_child.call_deferred(p)

func _onda() -> void:
	for d in [-1.0, 1.0]:
		var p = CENA_PROJETIL.instantiate()
		p.direcao = Vector2(d, 0.0)
		p.velocidade = 190.0
		p.gravidade = false
		p.position = Vector2(global_position.x, global_position.y + 4.0)
		get_parent().add_child.call_deferred(p)
	Jogo.tremor.emit(7.0)

func _mirar(alvo: Node2D) -> void:
	var p = CENA_PROJETIL.instantiate()
	p.direcao = (alvo.global_position - global_position).normalized()
	p.velocidade = 150.0
	p.position = global_position
	get_parent().add_child.call_deferred(p)



func levar_dano(qtd: int, _origem_dano: String = "") -> void:
	if _morto or not _ativo or _invuln > 0.0 or _escudo:
		return
	vida -= qtd
	_invuln = 0.45
	_flash = 0.12
	Jogo.som("acerto_chefe")
	Jogo.tremor.emit(3.0)
	Jogo.chefe_status.emit(nome_chefe, maxi(vida, 0), vida_max, true)
	if vida <= 0:
		_morrer()

func _morrer() -> void:
	_morto = true
	colisao.set_deferred("disabled", true)
	velocity = Vector2.ZERO
	Jogo.chefe_status.emit(nome_chefe, 0, vida_max, false)
	Jogo.som("explosao")
	Jogo.tremor.emit(14.0)
	for i in 4:
		Util.explosao(get_parent(), global_position + Vector2(randf_range(-30.0, 30.0), randf_range(-30.0, 30.0)), Color(1.0, 0.6, 0.2), 18)
	for i in randi_range(1, 3):
		_soltar(CENA_VIDA)
	for i in 10:
		_soltar(CENA_CARNE)
	morreu.emit()
	get_tree().create_timer(0.9).timeout.connect(queue_free)

func _soltar(cena: PackedScene) -> void:
	var item = cena.instantiate()
	item.position = global_position + Vector2(randf_range(-60.0, 60.0), randf_range(-30.0, 0.0))
	get_parent().add_child.call_deferred(item)

func _atualizar_visual() -> void:
	var nome := "andar"
	if _escudo or _acao == "pinca" or _acao == "carrega":
		nome = "atacar"
	if anim.animation != nome:
		anim.play(nome)
	anim.flip_h = _dir < 0.0
	if _flash > 0.0:
		anim.modulate = Color(2.2, 2.2, 2.2)
	elif _escudo:
		anim.modulate = _cor_base * Color(0.6, 0.8, 1.2)
	else:
		anim.modulate = _cor_base

func _jogador() -> Node2D:
	return get_tree().get_first_node_in_group("jogador") as Node2D
