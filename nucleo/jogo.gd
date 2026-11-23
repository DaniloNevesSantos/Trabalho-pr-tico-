extends Node


signal vida_mudou(vida: int, vida_max: int)
signal carnes_mudou(total: int)
signal aviso(texto: String)
signal chefe_status(nome: String, atual: int, maximo: int, visivel: bool)
signal tremor(intensidade: float)

const VIDA_INICIAL := 3
const VIDA_MAXIMA := 5
const TOTAL_MUNDOS := 1

var vida := VIDA_INICIAL
var carnes := 0
var mundo_atual := 1
var checkpoint := Vector2.ZERO
var tem_checkpoint := false
var inicio_fase := Vector2(32, 272)
var info_final := {"vitoria": false, "coroa": false}
var _trocando := false
var _sons := {}
var _pool: Array[AudioStreamPlayer] = []
var _musica: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_configurar_teclas()
	for i in 8:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)
	_musica = AudioStreamPlayer.new()
	_musica.volume_db = -10.0
	add_child(_musica)

func _configurar_teclas() -> void:
	var mapa := {
		"mover_esquerda": [KEY_A, KEY_LEFT],
		"mover_direita": [KEY_D, KEY_RIGHT],
		"pular": [KEY_SPACE],
		"interagir": [KEY_E],
		"ataque_especial": [KEY_TAB],
		"reviver": [KEY_R],
		"pausar": [KEY_ESCAPE],
	}
	for acao in mapa:
		if not InputMap.has_action(acao):
			InputMap.add_action(acao)
		for tecla in mapa[acao]:
			var ev := InputEventKey.new()
			ev.physical_keycode = tecla
			InputMap.action_add_event(acao, ev)
	# W/A/S/D também navegam pelos menus
	var navegacao := {"ui_left": KEY_A, "ui_right": KEY_D, "ui_up": KEY_W, "ui_down": KEY_S}
	for acao in navegacao:
		var ev := InputEventKey.new()
		ev.physical_keycode = navegacao[acao]
		InputMap.action_add_event(acao, ev)



func som(nome: String) -> void:
	if not _sons.has(nome):
		var s := load("res://sons/%s.wav" % nome) as AudioStream
		if s == null:
			return
		_sons[nome] = s
	for p in _pool:
		if not p.playing:
			p.stream = _sons[nome]
			p.play()
			return

func tocar_musica(nome: String) -> void:
	var s := load("res://sons/%s.wav" % nome) as AudioStreamWAV
	if s == null:
		return
	if _musica.stream == s and _musica.playing:
		return
	s.loop_mode = AudioStreamWAV.LOOP_FORWARD
	s.loop_begin = 0
	s.loop_end = s.data.size() / 2
	_musica.stream = s
	_musica.play()



func novo_jogo() -> void:
	vida = VIDA_INICIAL
	carnes = 0
	mundo_atual = 1
	tem_checkpoint = false
	_trocando = false
	_emitir_vida()
	_emitir_carnes()

func perder_vida(qtd: int = 1) -> void:
	vida = maxi(0, vida - qtd)
	_emitir_vida()

func ganhar_vida(qtd: int = 1) -> void:
	vida = mini(VIDA_MAXIMA, vida + qtd)
	_emitir_vida()

func adicionar_carne(qtd: int = 1) -> void:
	carnes += qtd
	_emitir_carnes()

func salvar_checkpoint(pos: Vector2) -> void:
	checkpoint = pos
	tem_checkpoint = true

func _emitir_vida() -> void:
	vida_mudou.emit(vida, VIDA_MAXIMA)

func _emitir_carnes() -> void:
	carnes_mudou.emit(carnes)




func concluir_mundo() -> void:
	if _trocando:
		return
	_trocando = true
	som("vitoria")
	if mundo_atual >= TOTAL_MUNDOS:
		info_final = {"vitoria": true, "coroa": carnes >= Dados.CARNES_PARA_COROA}
		_agendar("res://cenas/interface/tela_final.tscn", 3.0)
	else:
		aviso.emit("Mundo %d concluído! Próximo mundo..." % mundo_atual)
		mundo_atual += 1
		vida = VIDA_MAXIMA
		_emitir_vida()
		tem_checkpoint = false
		_agendar("res://cenas/fase.tscn", 3.0)


func derrota() -> void:
	if _trocando:
		return
	_trocando = true
	info_final = {"vitoria": false, "coroa": false}
	som("derrota")
	get_tree().change_scene_to_file("res://cenas/interface/tela_final.tscn")


func reviver() -> void:
	vida = VIDA_INICIAL
	_emitir_vida()
	_trocando = false
	get_tree().change_scene_to_file("res://cenas/fase.tscn")

func voltar_menu() -> void:
	_trocando = false
	tocar_musica("musica_menu")
	get_tree().change_scene_to_file("res://cenas/menu_principal.tscn")

func _agendar(cena: String, tempo: float) -> void:
	
	get_tree().create_timer(tempo).timeout.connect(func():
		_trocando = false
		get_tree().change_scene_to_file(cena))
