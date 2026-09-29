## Game.gd — Raiz de flujo: START -> PLAYING -> GAMEOVER.
## Monta y desmonta las pantallas; las reglas viven en el core.
extends Node2D

enum Estado { START, PLAYING, GAMEOVER }

var estado: Estado = Estado.START

var _start: StartScreen
var _play: PlayScreen
var _overlay: GameOverOverlay
var _router: InputRouter

func _ready() -> void:
	_router = InputRouter.new()
	add_child(_router)
	_ir_a_inicio()

func _ir_a_inicio() -> void:
	_limpiar_pantallas()
	estado = Estado.START
	_start = StartScreen.new()
	_start.start_requested.connect(_empezar)
	add_child(_start)

func _empezar() -> void:
	_limpiar_pantallas()
	estado = Estado.PLAYING
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_play = PlayScreen.new()
	_play.setup(rng)
	add_child(_play)
	_router.target = _play
	_router.activo = true
	_router.reset()
	_play.builder.game_over.connect(_on_game_over)

func _on_game_over() -> void:
	estado = Estado.GAMEOVER
	_router.activo = false
	_router.reset()
	_overlay = GameOverOverlay.new()
	_overlay.set_score(_play.final_score())
	_overlay.retry_requested.connect(_empezar)
	_overlay.menu_requested.connect(_ir_a_inicio)
	add_child(_overlay)

func _limpiar_pantallas() -> void:
	for n in [_start, _play, _overlay]:
		if is_instance_valid(n):
			n.queue_free()
	_start = null
	_play = null
	_overlay = null
