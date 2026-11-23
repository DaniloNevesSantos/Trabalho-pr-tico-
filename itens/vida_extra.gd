extends Area2D


var _t := 0.0
var _coletado := false

func _ready() -> void:
	body_entered.connect(_entrou)
	_t = randf() * TAU

func _process(delta: float) -> void:
	_t += delta * 3.5
	queue_redraw()

func _draw() -> void:
	var dy := sin(_t) * 2.0
	Util.desenhar_coracao(self, Vector2(-7.0, -6.0 + dy), 2.0, true)

func _entrou(corpo: Node2D) -> void:
	if _coletado or not corpo.is_in_group("jogador"):
		return
	_coletado = true
	Jogo.ganhar_vida(1)
	Jogo.som("vida")
	Jogo.aviso.emit("+1 coração!")
	Util.explosao(get_parent(), global_position, Color(1.0, 0.4, 0.5), 8)
	queue_free()
