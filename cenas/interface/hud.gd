extends CanvasLayer


var _vida: int = 3
var _vida_max: int = 5
var _coracoes: Control
var _label_carnes: Label
var _label_mundo: Label
var _label_aviso: Label
var _label_titulo: Label
var _painel_chefe: Panel
var _label_chefe: Label
var _barra_chefe: ProgressBar
var _flash: ColorRect

func _ready() -> void:
	layer = 10
	_flash = ColorRect.new()
	_flash.color = Color(1.0, 0.1, 0.1, 0.0)
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash)

	_coracoes = Control.new()
	_coracoes.position = Vector2(12, 10)
	_coracoes.size = Vector2(200, 24)
	_coracoes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_coracoes.draw.connect(_desenhar_coracoes)
	add_child(_coracoes)

	var icone := TextureRect.new()
	var at := AtlasTexture.new()
	at.atlas = load("res://sprites/itens/baixados_carne.02.png")
	at.region = Rect2(37, 71, 272, 208)
	icone.texture = at
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone.position = Vector2(10, 40)
	icone.size = Vector2(22, 18)
	icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icone)

	_label_carnes = Util.rotulo(16, Color(1.0, 0.9, 0.5))
	_label_carnes.position = Vector2(36, 38)
	add_child(_label_carnes)

	_label_mundo = Util.rotulo(14, Color(1.0, 0.95, 0.8))
	_label_mundo.position = Vector2(0, 8)
	_label_mundo.size = Vector2(640, 24)
	_label_mundo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_label_mundo)

	_painel_chefe = Panel.new()
	_painel_chefe.position = Vector2(396, 8)
	_painel_chefe.size = Vector2(232, 48)
	_painel_chefe.add_theme_stylebox_override("panel", Util.estilo_painel())
	_painel_chefe.visible = false
	add_child(_painel_chefe)
	_label_chefe = Util.rotulo(13, Color(1.0, 0.85, 0.6))
	_label_chefe.position = Vector2(8, 2)
	_painel_chefe.add_child(_label_chefe)
	_barra_chefe = ProgressBar.new()
	_barra_chefe.position = Vector2(8, 26)
	_barra_chefe.size = Vector2(216, 14)
	_barra_chefe.show_percentage = false
	var preench := StyleBoxFlat.new()
	preench.bg_color = Color(0.95, 0.25, 0.25)
	preench.set_corner_radius_all(3)
	_barra_chefe.add_theme_stylebox_override("fill", preench)
	_painel_chefe.add_child(_barra_chefe)

	_label_aviso = Util.rotulo(14, Color.WHITE)
	_label_aviso.position = Vector2(0, 282)
	_label_aviso.size = Vector2(640, 26)
	_label_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_aviso.modulate.a = 0.0
	add_child(_label_aviso)

	_label_titulo = Util.rotulo(30, Color(1.0, 0.9, 0.5))
	_label_titulo.position = Vector2(0, 110)
	_label_titulo.size = Vector2(640, 50)
	_label_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_titulo.modulate.a = 0.0
	add_child(_label_titulo)

	Jogo.vida_mudou.connect(_on_vida)
	Jogo.carnes_mudou.connect(_on_carnes)
	Jogo.aviso.connect(mostrar_aviso)
	Jogo.chefe_status.connect(_on_chefe)
	_on_vida(Jogo.vida, Jogo.VIDA_MAXIMA)
	_on_carnes(Jogo.carnes)

func _desenhar_coracoes() -> void:
	for i in _vida_max:
		Util.desenhar_coracao(_coracoes, Vector2(i * 22.0, 0.0), 3.0, i < _vida)

func _on_vida(v: int, vmax: int) -> void:
	var perdeu := v < _vida
	_vida = v
	_vida_max = vmax
	_coracoes.queue_redraw()
	if perdeu:
		_flash.color = Color(1.0, 0.1, 0.1, 0.35)
		var t := create_tween()
		t.tween_property(_flash, "color", Color(1.0, 0.1, 0.1, 0.0), 0.4)

func _on_carnes(total: int) -> void:
	_label_carnes.text = "x %d" % total

func _on_chefe(nome: String, atual: int, maximo: int, visivel: bool) -> void:
	_painel_chefe.visible = visivel
	_label_chefe.text = nome
	_barra_chefe.max_value = maximo
	_barra_chefe.value = atual

func mostrar_aviso(texto: String) -> void:
	if texto == "":
		return
	_label_aviso.text = texto
	_label_aviso.modulate.a = 1.0
	var t := create_tween()
	t.tween_interval(2.4)
	t.tween_property(_label_aviso, "modulate:a", 0.0, 0.6)

func titulo(texto: String) -> void:
	_label_mundo.text = texto
	_label_titulo.text = texto
	_label_titulo.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(_label_titulo, "modulate:a", 1.0, 0.5)
	t.tween_interval(1.8)
	t.tween_property(_label_titulo, "modulate:a", 0.0, 0.7)
