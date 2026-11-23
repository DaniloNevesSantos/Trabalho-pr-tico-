extends Area2D


@export var mensagem := ""
@export var checkpoint := false
var _dentro := false
var _usado := false

@onready var dica: Label = $Dica

func _ready() -> void:
	body_entered.connect(_entrou)
	body_exited.connect(_saiu)
	dica.visible = false
	dica.text = "[E] Ativar" if checkpoint else "[E] Ler"

func _entrou(corpo: Node2D) -> void:
	if corpo.is_in_group("jogador"):
		_dentro = true
		dica.visible = true

func _saiu(corpo: Node2D) -> void:
	if corpo.is_in_group("jogador"):
		_dentro = false
		dica.visible = false

func _process(_delta: float) -> void:
	if _dentro and Input.is_action_just_pressed("interagir"):
		_usar()

func _usar() -> void:
	if checkpoint:
		Jogo.salvar_checkpoint(global_position + Vector2(0, -14))
		if not _usado:
			Jogo.ganhar_vida(1)
		_usado = true
		Jogo.som("checkpoint")
		Jogo.aviso.emit("Checkpoint salvo!")
	else:
		Jogo.som("placa")
		Jogo.aviso.emit(mensagem)
	queue_redraw()

func _draw() -> void:
	if checkpoint:
		draw_rect(Rect2(-6, -14, 12, 30), Color(0.45, 0.28, 0.16))
		draw_rect(Rect2(-6, -14, 12, 4), Color(0.6, 0.4, 0.22))
		draw_rect(Rect2(-4, 2, 8, 2), Color(0.3, 0.18, 0.1))
		var gema := Color(0.4, 0.95, 0.5) if _usado else Color(0.5, 0.75, 1.0)
		draw_circle(Vector2(0, -18), 4.0, gema)
		draw_circle(Vector2(-1, -19), 1.5, Color(1, 1, 1, 0.8))
	else:
		draw_rect(Rect2(-1, -2, 2, 16), Color(0.45, 0.28, 0.16))
		draw_rect(Rect2(-12, -12, 24, 12), Color(0.95, 0.88, 0.7))
		draw_rect(Rect2(-12, -12, 24, 2), Color(0.7, 0.5, 0.3))
		draw_rect(Rect2(-8, -8, 16, 1), Color(0.5, 0.35, 0.2))
		draw_rect(Rect2(-8, -5, 12, 1), Color(0.5, 0.35, 0.2))
