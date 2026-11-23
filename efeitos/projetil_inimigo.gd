extends Area2D


const TEX_MISSIL := "res://sprites/personagens/8 - Comrade Cheese Puff/Missile (16 x 8).png"
const TEX_BOMBA := "res://sprites/personagens/8 - Comrade Cheese Puff/Dropped_Bomb (8 x 8).png"

var direcao := Vector2.LEFT
var velocidade := 140.0
var gravidade := false
var _vel := Vector2.ZERO
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	body_entered.connect(_ao_bater)
	_vel = direcao * velocidade
	if gravidade:
		sprite.texture = load(TEX_BOMBA)
		sprite.scale = Vector2(2.0, 2.0)
	else:
		sprite.texture = load(TEX_MISSIL)
		sprite.scale = Vector2(1.6, 1.6)
		rotation = direcao.angle()
	get_tree().create_timer(4.0).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	if gravidade:
		_vel.y += 620.0 * delta
	position += _vel * delta

func _ao_bater(corpo: Node) -> void:
	if corpo.is_in_group("jogador") and corpo.has_method("sofrer_dano"):
		corpo.sofrer_dano(1, global_position.x)
	queue_free()
