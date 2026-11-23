extends Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fundo := ColorRect.new()
	fundo.color = Color(0.08, 0.06, 0.14)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)

	var titulo := Util.rotulo(34, Color(1.0, 0.85, 0.3))
	titulo.text = "Créditos"
	titulo.position = Vector2(0, 20)
	titulo.size = Vector2(640, 50)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(titulo)

	var texto := Util.rotulo(14, Color(0.95, 0.93, 0.88))
	texto.text = ("Jogo: Super Dino\n" \
		+ "Desenvolvido pela dupla: Danilo Paulo e Pedro Bernardo\n" \
		+ "Introdução ao Desenvolvimento de Jogos - IFMG Ribeirão das Neves\n" \
		+ "Professora: Camila Laranjeira\n\n" \
		+ "Engine: Godot Engine\n" \
		)
	texto.position = Vector2(60, 90)
	texto.size = Vector2(520, 180)
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD
	add_child(texto)

	var voltar := Button.new()
	voltar.text = "Voltar"
	Util.estilo_botao(voltar)
	voltar.position = Vector2(220, 270)
	voltar.pressed.connect(func(): get_tree().change_scene_to_file("res://cenas/menu_principal.tscn"))
	add_child(voltar)
	voltar.grab_focus()
