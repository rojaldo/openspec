## BoardView.gd — Dibuja el tablero leyendo del BoardBuilder, sin mutarlo.
## Usa Sprite2D en lugar de draw_texture(): en este entorno draw_texture()
## pinta las texturas en blanco, mientras Sprite2D y TextureRect si funcionan.
class_name BoardView
extends Node2D

const CELL := 32
const BLOCK_PX := 64.0
const CELL_COLOR := Color("#fdf6e3")
const INK := Color("#14110f")
const BORDER_PX := 5.0
const GHOST_ALPHA := 0.22

var builder: BoardBuilder

var _pool: Array[Sprite2D] = []
var _usados := 0

func _init(p_builder: BoardBuilder = null) -> void:
	builder = p_builder

func set_builder(p_builder: BoardBuilder) -> void:
	builder = p_builder
	refresh()

func board_size() -> Vector2:
	return Vector2(BoardBuilder.COLS * CELL, BoardBuilder.ROWS_VISIBLE * CELL)

func row_to_y(row: int) -> float:
	return float((row - BoardBuilder.ROWS_HIDDEN) * CELL)

func cell_to_screen(gx: int, gy: int) -> Vector2:
	return Vector2(gx * CELL, row_to_y(gy))

## Redibuja todo el tablero reutilizando el pool de sprites.
func refresh() -> void:
	if builder == null:
		return
	_usados = 0
	queue_redraw()
	var activa := builder.active
	if activa != null and not builder.over:
		for c in activa.cells(Vector2i(activa.pos.x, builder.ghost_y())):
			_bloque(c.x, c.y, activa.type, GHOST_ALPHA)
		for c in activa.cells():
			_bloque(c.x, c.y, activa.type, 1.0)
	for y in range(BoardBuilder.ROWS_TOTAL):
		for x in range(BoardBuilder.COLS):
			var t := builder.cell_at(x, y)
			if t != "":
				_bloque(x, y, t, 1.0)
	for i in range(_usados, _pool.size()):
		_pool[i].visible = false

func _bloque(gx: int, gy: int, tipo: String, alpha: float) -> void:
	# las filas 0..1 son la zona oculta: no se dibujan
	if gy < BoardBuilder.ROWS_HIDDEN:
		return
	var s := _sprite(_usados)
	_usados += 1
	s.texture = Tetromino.block_texture(tipo)
	s.position = cell_to_screen(gx, gy) + Vector2(CELL, CELL) / 2.0
	s.scale = Vector2(CELL / BLOCK_PX, CELL / BLOCK_PX)
	s.modulate = Color(1, 1, 1, alpha)
	s.visible = true

func _sprite(i: int) -> Sprite2D:
	if i < _pool.size():
		return _pool[i]
	var s := Sprite2D.new()
	add_child(s)
	_pool.append(s)
	return s

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, board_size())
	draw_rect(Rect2(r.position + Vector2(4, 4), r.size), INK, true)
	draw_rect(r, CELL_COLOR, true)
	var dot := Color(0, 0, 0, 0.10)
	for y in range(BoardBuilder.ROWS_VISIBLE + 1):
		for x in range(BoardBuilder.COLS + 1):
			draw_circle(Vector2(x * CELL, y * CELL), 1.5, dot)
	draw_rect(r, INK, false, BORDER_PX)
