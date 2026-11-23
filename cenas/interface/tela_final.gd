extends CanvasLayer


var _vitoria := false
var _coroa := false
var _botao_principal: Button

func _ready() -> void:
	layer = 30
	_vitoria = Jogo.info_final["vitoria"]
	_coroa = Jogo.info_final["coroa"]

	var fundo := ColorRect.new()
	if _vitoria:
		fundo.color = Color(0.14, 0.09, 0.03, 0.94)
	else:
		fundo.color = Color(0.06, 0.04, 0.09, 0.94)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)

	var titulo := Util.rotulo(40, Color(1.0, 0.85, 0.3) if _vitoria else Color(1.0, 0.4, 0.4))
	titulo.position = Vector2(0, 40)
	titulo.size = Vector2(640, 60)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var sub := Util.rotulo(15, Color(0.95, 0.92, 0.85))
	sub.position = Vector2(60, 190)
	sub.size = Vector2(520, 50)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD

	if _vitoria and _coroa:
		titulo.text = "COROA CONQUISTADA!"
		sub.text = "Você derrotou o chefe e é o rei do mundo pré-histórico! Carnes coletadas: %d" % Jogo.carnes
		var coroa := Control.new()
		coroa.position = Vector2(290, 120)
		coroa.size = Vector2(60, 40)
		coroa.mouse_filter = Control.MOUSE_FILTER_IGNORE
		coroa.draw.connect(func(): _desenhar_coroa(coroa))
		add_child(coroa)
	elif _vitoria:
		titulo.text = "VITÓRIA!"
		sub.text = "Você venceu o chefe, mas precisava de %d carnes para a coroa. Você tem %d." % [Dados.CARNES_PARA_COROA, Jogo.carnes]
	else:
		titulo.text = "VOCÊ MORREU..."
		sub.text = "Seus corações acabaram. Reviva no último checkpoint ou volte ao menu."
	add_child(titulo)
	add_child(sub)

	var caixa := VBoxContainer.new()
	caixa.position = Vector2(220, 240)
	caixa.size = Vector2(200, 80)
	caixa.add_theme_constant_override("separation", 10)
	add_child(caixa)

	_botao_principal = Button.new()
	_botao_principal.text = "Jogar de novo (R)" if _vitoria else "Reviver (R)"
	Util.estilo_botao(_botao_principal, Color(0.3, 0.7, 0.35))
	_botao_principal.pressed.connect(_reiniciar)
	caixa.add_child(_botao_principal)

	var menu := Button.new()
	menu.text = "Menu principal (ESC)"
	Util.estilo_botao(menu)
	menu.pressed.connect(func(): Jogo.voltar_menu())
	caixa.add_child(menu)
	_botao_principal.grab_focus()

func _desenhar_coroa(c: Control) -> void:
	var ouro := Color(1.0, 0.82, 0.2)
	var pontos := PackedVector2Array([Vector2(0, 40), Vector2(0, 12), Vector2(15, 26), Vector2(30, 0), Vector2(45, 26), Vector2(60, 12), Vector2(60, 40)])
	c.draw_colored_polygon(pontos, ouro)
	c.draw_rect(Rect2(0, 32, 60, 8), Color(0.9, 0.6, 0.1))

func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("reviver"):
		_reiniciar()
	elif evento.is_action_pressed("pausar"):
		Jogo.voltar_menu()

func _reiniciar() -> void:
	if _vitoria:
		Jogo.novo_jogo()
		get_tree().change_scene_to_file("res://cenas/fase.tscn")
	else:
		Jogo.reviver()
