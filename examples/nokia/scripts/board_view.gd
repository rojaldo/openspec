extends Control
## Vista del tablero: dibuja fondo, rejilla, borde segun el nivel, celdas
## solidas, coco y serpiente. Es solo lectura sobre la simulacion: interpola
## entre prev_cells y cells y pinta el cruce de borde a ambos lados (ghost).

const GridConfig = preload("res://scripts/logic/grid_config.gd")
const BoardRender = preload("res://scripts/logic/board_render.gd")

const BG := Color("#9bbc0f")
const INK := Color("#0f2a12")
const GRID := Color("#8aa80d")
const WALL := Color("#4a6b06")
const OBSTACLE := Color("#3a5a08")

var game = null
var progress := 0.0


func _init() -> void:
	custom_minimum_size = GridConfig.board_size_px()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	_draw_board()
	if game == null or game.level == null:
		return
	_draw_solids()
	_draw_food()
	_draw_snake()


func _size() -> Vector2:
	if game != null and game.level != null:
		return GridConfig.board_size_px(game.level.width, game.level.height)
	return GridConfig.board_size_px()


func _draw_board() -> void:
	var size := _size()
	draw_rect(Rect2(Vector2.ZERO, size), BG)
	var w := GridConfig.WIDTH
	var h := GridConfig.HEIGHT
	if game != null and game.level != null:
		w = game.level.width
		h = game.level.height
	for x in range(w + 1):
		var px := x * GridConfig.CELL
		draw_line(Vector2(px, 0), Vector2(px, size.y), GRID, 1.0)
	for y in range(h + 1):
		var py := y * GridConfig.CELL
		draw_line(Vector2(0, py), Vector2(size.x, py), GRID, 1.0)
	# El borde solo se dibuja como muro cuando el nivel lo hace mortal.
	var deadly: bool = game != null and game.level != null and game.level.border == game.level.BORDER_DEADLY
	var width := 4.0 if deadly else 2.0
	draw_rect(Rect2(Vector2.ZERO, size), INK, false, width)


## Las celdas solidas del nivel: paredes del anillo y obstaculos interiores.
func _draw_solids() -> void:
	var lvl = game.level
	var inset := 1.0
	var side := GridConfig.CELL - inset * 2
	var ring: bool = lvl.border == lvl.BORDER_DEADLY
	for c in lvl.solids.keys():
		var is_ring: bool = ring and (c.x == 0 or c.y == 0 or c.x == lvl.width - 1 or c.y == lvl.height - 1)
		draw_rect(Rect2(
			Vector2(c.x * GridConfig.CELL + inset, c.y * GridConfig.CELL + inset),
			Vector2(side, side)
		), WALL if is_ring else OBSTACLE)


func _draw_food() -> void:
	var inset := 5.0
	draw_rect(Rect2(
		Vector2(game.food) * GridConfig.CELL + Vector2(inset, inset),
		Vector2.ONE * (GridConfig.CELL - inset * 2)
	), INK)


func _draw_snake() -> void:
	var positions := BoardRender.snake_positions(game.prev_cells, game.cells, progress)
	var inset := 2.0
	var side := GridConfig.CELL - inset * 2
	for segment in positions:
		for pos in segment:
			draw_rect(Rect2(
				Vector2(pos.x * GridConfig.CELL + inset, pos.y * GridConfig.CELL + inset),
				Vector2(side, side)
			), INK)
