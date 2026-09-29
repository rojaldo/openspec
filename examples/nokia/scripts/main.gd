extends Control
## Flujo de pantallas. Mantiene una sola pantalla hija activa a la vez.

const Layout = preload("res://scripts/screens/screen_layout.gd")
const StartScreen = preload("res://scripts/screens/start_screen.gd")
const LevelSelectScreen = preload("res://scripts/screens/level_select_screen.gd")
const GameScreen = preload("res://scripts/screens/game_screen.gd")
const ScoresScreen = preload("res://scripts/screens/scores_screen.gd")


func _ready() -> void:
	Layout.build(self)
	_show_start()


func _clear() -> void:
	for child in get_children():
		if child is ColorRect or child is VBoxContainer:
			continue
		child.queue_free()


func _show_start() -> void:
	_clear()
	var screen := StartScreen.new()
	screen.play_requested.connect(_show_game)
	screen.select_level_requested.connect(_show_level_select)
	add_child(screen)


func _show_level_select() -> void:
	_clear()
	var screen := LevelSelectScreen.new()
	screen.level_chosen.connect(func(index: int): _show_game(index))
	screen.back_requested.connect(_show_start)
	add_child(screen)


## Arranca una partida nueva. `start_level` decide el nivel inicial: 0 es el
## primero, que es lo que usa la opcion de empezar partida.
func _show_game(start_level: int = 0) -> void:
	_clear()
	var screen = GameScreen.new()
	screen.start_level = start_level
	screen.game_over.connect(_show_scores)
	add_child(screen)


func _show_scores(score: int, level_reached: int, victory: bool) -> void:
	_clear()
	var screen = ScoresScreen.new()
	screen.play_requested.connect(_show_game)
	screen.menu_requested.connect(_show_start)
	add_child(screen)
	screen.show_result(score, level_reached, victory)
