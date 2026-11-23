extends CanvasLayer


var _ativo := false
var _botao_continuar: Button

func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	var escurece := ColorRect.new()
	escurece.color = Color(0, 0, 0, 0.6)
	escurece.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	escurece.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(escurece)

	var painel := Panel.new()
	painel.position = Vector2(190, 50)
	painel.size = Vector2(260, 220)
	painel.add_theme_stylebox_override("panel", Util.estilo_painel(0.95))
	add_child(painel)

	var caixa := VBoxContainer.new()
	caixa.position = Vector2(30, 22)
	caixa.size = Vector2(200, 180)
	caixa.add_theme_constant_override("separation", 12)
	painel.add_child(caixa)

	var titulo := Util.rotulo(26, Color(1.0, 0.9, 0.5))
	titulo.text = "PAUSA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa.add_child(titulo)

	_botao_continuar = Button.new()
	_botao_continuar.text = "Continuar"
	Util.estilo_botao(_botao_continuar, Color(0.3, 0.7, 0.35))
	_botao_continuar.pressed.connect(_alternar)
	caixa.add_child(_botao_continuar)

	var menu := Button.new()
	menu.text = "Menu principal"
	Util.estilo_botao(menu)
	menu.pressed.connect(_voltar_menu)
	caixa.add_child(menu)

	var sair := Button.new()
	sair.text = "Sair do jogo"
	Util.estilo_botao(sair, Color(0.75, 0.25, 0.25))
	sair.pressed.connect(func(): get_tree().quit())
	caixa.add_child(sair)

func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("pausar"):
		_alternar()
		get_viewport().set_input_as_handled()

func _alternar() -> void:
	_ativo = not _ativo
	visible = _ativo
	get_tree().paused = _ativo
	if _ativo:
		_botao_continuar.grab_focus()

func _voltar_menu() -> void:
	get_tree().paused = false
	_ativo = false
	visible = false
	Jogo.voltar_menu()
