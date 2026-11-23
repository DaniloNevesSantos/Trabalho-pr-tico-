extends Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Jogo.tocar_musica("musica_menu")

	var fundo := TextureRect.new()
	fundo.texture = load(Dados.PASTA_CENARIOS + "1 - Grassland/Background parts/_Complete_static_BG_(288 x 208).png")
	fundo.stretch_mode = TextureRect.STRETCH_SCALE
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)

	var sombra := ColorRect.new()
	sombra.color = Color(0.05, 0.1, 0.2, 0.35)
	sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(sombra)

	var titulo := Util.rotulo(54, Color(1.0, 0.85, 0.3))
	titulo.text = "SUPER DINO"
	titulo.position = Vector2(0, 26)
	titulo.size = Vector2(640, 70)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(titulo)


	var caixa := VBoxContainer.new()
	caixa.position = Vector2(60, 150)
	caixa.size = Vector2(220, 150)
	caixa.add_theme_constant_override("separation", 12)
	add_child(caixa)

	var jogar := Button.new()
	jogar.text = "Jogar"
	Util.estilo_botao(jogar, Color(0.3, 0.7, 0.35))
	jogar.pressed.connect(_jogar)
	caixa.add_child(jogar)

	var creditos := Button.new()
	creditos.text = "Créditos"
	Util.estilo_botao(creditos)
	creditos.pressed.connect(func(): get_tree().change_scene_to_file("res://cenas/creditos.tscn"))
	caixa.add_child(creditos)

	var sair := Button.new()
	sair.text = "Sair"
	Util.estilo_botao(sair, Color(0.75, 0.25, 0.25))
	sair.pressed.connect(func(): get_tree().quit())
	caixa.add_child(sair)
	jogar.grab_focus()

	var dino := AnimatedSprite2D.new()
	dino.sprite_frames = Util.frames_dino()
	dino.scale = Vector2(5, 5)
	dino.position = Vector2(470, 230)
	dino.play("correr")
	add_child(dino)
	var t := create_tween().set_loops()
	t.tween_property(dino, "position:y", 218.0, 0.35)
	t.tween_property(dino, "position:y", 230.0, 0.35)

	

func _jogar() -> void:
	Jogo.novo_jogo()
	get_tree().change_scene_to_file("res://cenas/fase.tscn")
