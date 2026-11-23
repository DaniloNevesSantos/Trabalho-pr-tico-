extends Area2D


var _t := 0.0
var _coletada := false
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	body_entered.connect(_ao_entrar)
	_t = randf() * TAU
	var at := AtlasTexture.new()
	at.atlas = load("res://sprites/itens/baixados_carne.02.png")
	at.region = Rect2(37, 71, 272, 208)
	sprite.texture = at

func _process(delta: float) -> void:
	_t += delta * 4.0
	sprite.position.y = sin(_t) * 1.5

func _ao_entrar(corpo: Node2D) -> void:
	if _coletada or not corpo.is_in_group("jogador"):
		return
	_coletada = true
	Jogo.adicionar_carne(1)
	Jogo.som("carne")
	Util.explosao(get_parent(), global_position, Color(1.0, 0.8, 0.3), 6)
	queue_free()
