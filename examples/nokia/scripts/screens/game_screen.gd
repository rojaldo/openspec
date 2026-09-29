extends Control
## Pantalla de juego: tablero, serpiente, coco, celdas solidas, nivel,
## progreso del objetivo y puntuacion. El acumulador marca los ticks y la
## interpolacion: una sola fuente de tiempo.

signal game_over(score: int, level_reached: int, victory: bool)

const SnakeGame = preload("res://scripts/logic/snake_game.gd")
const Levels = preload("res://scripts/logic/levels.gd")
const BoardView = preload("res://scripts/board_view.gd")
const Layout = preload("res://scripts/screens/screen_layout.gd")

## Tope de ticks por frame: una pausa larga no dispara una rafaga.
const MAX_TICKS_PER_FRAME := 4
## Duracion del aviso de nivel, en segundos.
const BANNER_TIME := 1.1

var game
var view: Control
var level_label: Label
var goal_label: Label
var banner: Label

## Nivel en el que arranca la partida. Se fija ANTES de anadir la pantalla,
## porque _ready corre dentro de add_child. Por defecto, el primero.
var start_level := 0

var _acc := 0.0
var _interval := 0.0
var _banner_left := 0.0


func _ready() -> void:
	var column := Layout.build(self)

	level_label = Layout.label("NIVEL 1", 22)
	column.add_child(level_label)
	goal_label = Layout.label("COCOS 0/5", 18)
	column.add_child(goal_label)

	view = BoardView.new()
	view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(view)

	banner = Layout.label("", 24)
	column.add_child(banner)

	game = SnakeGame.new()
	game.start(0, start_level)
	game.level_completed.connect(_on_level_completed)
	view.game = game
	_interval = game.current_interval()
	_acc = 0.0
	_show_level_banner()
	_update_hud()


func _process(delta: float) -> void:
	if game == null or not game.alive:
		return
	if _banner_left > 0.0:
		_banner_left -= delta
		if _banner_left <= 0.0:
			banner.text = ""
		return

	_acc += delta
	var ticks := 0
	while _acc >= _interval and ticks < MAX_TICKS_PER_FRAME and game.alive:
		step_tick()
		ticks += 1

	if not game.alive:
		return

	view.progress = clampf(_acc / _interval, 0.0, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if game == null or not game.alive:
		return
	if event.is_action_pressed("move_up"):
		game.set_direction(Vector2i.UP)
	elif event.is_action_pressed("move_down"):
		game.set_direction(Vector2i.DOWN)
	elif event.is_action_pressed("move_left"):
		game.set_direction(Vector2i.LEFT)
	elif event.is_action_pressed("move_right"):
		game.set_direction(Vector2i.RIGHT)


## Avanza la simulacion un tick. Sirve para tests y para el bucle normal.
func step_tick() -> void:
	if game == null or not game.alive:
		return
	game.tick()
	_acc -= _interval
	_interval = game.current_interval()
	_update_hud()
	if game.finished:
		view.progress = 1.0
		game_over.emit(game.score, Levels.count(), true)
		return
	if not game.alive:
		view.progress = 1.0
		game_over.emit(game.score, game.level_index + 1, false)


func _on_level_completed(_completed_index: int) -> void:
	_interval = game.current_interval()
	_acc = 0.0
	_show_level_banner()
	_update_hud()


func _show_level_banner() -> void:
	banner.text = "NIVEL %d - %d COCOS" % [game.level_index + 1, game.level.target]
	_banner_left = BANNER_TIME


func _update_hud() -> void:
	level_label.text = "NIVEL %d/%d" % [game.level_index + 1, Levels.count()]
	goal_label.text = "COCOS %d/%d   PUNTOS %d" % [game.level_eaten, game.level.target, game.score]
