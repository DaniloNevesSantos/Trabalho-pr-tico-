extends Area2D


var direcao := 1.0
var _tempo := 0.0

func _ready() -> void:
	body_entered.connect(_ao_bater)
	get_tree().create_timer(1.3).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	_tempo += delta
	position.x += direcao * 280.0 * delta
	position.y += sin(_tempo * 22.0) * 0.5
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2(-direcao * 7.0, 0.0), 3.5, Color(1.0, 0.35, 0.1, 0.55))
	draw_circle(Vector2(-direcao * 3.5, 0.0), 4.5, Color(1.0, 0.45, 0.1, 0.8))
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.45, 0.1))
	draw_circle(Vector2(direcao * 1.5, 0.0), 3.0, Color(1.0, 0.95, 0.4))

func _ao_bater(corpo: Node) -> void:
	if corpo.is_in_group("jogador"):
		return
	if corpo.has_method("levar_dano"):
		corpo.levar_dano(1, "fogo")
	Util.explosao(get_parent(), global_position, Color(1.0, 0.6, 0.2), 8)
	queue_free()
