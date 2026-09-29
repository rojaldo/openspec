## PlayScreen.gd — Pantalla de juego: tablero + panel + loop de caida + onomatopeya.
## Es la vista; todas las reglas viven en el BoardBuilder.
class_name PlayScreen
extends Node2D

const BOARD_POS := Vector2(24, 40)
const BACKGROUND := "res://textures/bg_paper.png"
## Centro de la pantalla: la onomatopeya se centra aqui, no en el tablero
## (centrarla en el tablero la dejaba 56 px a la izquierda).
const PANTALLA_CENTRO := Vector2(240, 360)

var builder: BoardBuilder
var view: BoardView
var stats: StatsPanel
var sfx: SfxPopup

var _drop_timer := 0.0
var _rng := RandomNumberGenerator.new()

func setup(rng: RandomNumberGenerator) -> void:
	_rng = rng
	builder = BoardBuilder.new(PieceFactory.new(rng))

	var bg := TextureRect.new()
	bg.texture = load(BACKGROUND)
	bg.position = Vector2.ZERO
	bg.size = Vector2(480, 720)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(bg)

	view = BoardView.new(builder)
	view.position = BOARD_POS
	add_child(view)

	stats = StatsPanel.new()
	add_child(stats)

	sfx = SfxPopup.new()
	sfx.position = PANTALLA_CENTRO
	add_child(sfx)

	builder.lines_cleared.connect(_on_lines_cleared)
	builder.game_over.connect(_on_game_over)
	_drop_timer = 0.0
	# el panel y la vista no existen hasta que el nodo entra en el arbol
	call_deferred("_arranque_visual")

func _arranque_visual() -> void:
	_refresh_stats()
	view.refresh()

func _process(delta: float) -> void:
	if builder == null or builder.over:
		return
	_drop_timer += delta
	if _drop_timer >= FallSpeed.interval(builder.lines):
		_drop_timer = 0.0
		builder.step_down()
		view.refresh()

func move_active(dx: int) -> void:
	if builder == null or builder.over:
		return
	if builder.try_move(dx, 0):
		view.refresh()

func soft_drop() -> void:
	if builder == null or builder.over:
		return
	builder.step_down()
	view.refresh()

func rotate_active() -> void:
	if builder == null or builder.over:
		return
	if builder.try_rotate(true):
		view.refresh()

func _refresh_stats() -> void:
	stats.refresh(_score, builder.lines, _next_type())

func _next_type() -> String:
	return "" if builder.over else builder.next_type()

func _on_lines_cleared(count: int, is_tetris: bool) -> void:
	_score += Scoring.points(count)
	view.refresh()
	_refresh_stats()
	sfx.pop("tetris" if is_tetris else _menor_onomatopeya())

func _on_game_over() -> void:
	view.refresh()
	_refresh_stats()

func _menor_onomatopeya() -> String:
	var opciones := ["bam", "wham", "blam"]
	return opciones[_rng.randi() % opciones.size()]

var _score := 0

func final_score() -> int:
	return _score
