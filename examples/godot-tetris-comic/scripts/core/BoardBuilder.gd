## BoardBuilder.gd — Dueno unico de la altura ocupada y del estado de la partida.
## Compone las piezas al aterrizar, resuelve lineas visibles y detecta el fin
## de partida. No sabe dibujar ni conoce nodos.
class_name BoardBuilder
extends RefCounted

signal lines_cleared(count: int, is_tetris: bool)
signal piece_locked(type: String)
signal game_over

const COLS := 10
const ROWS_VISIBLE := 20
const ROWS_HIDDEN := 2
const ROWS_TOTAL := ROWS_VISIBLE + ROWS_HIDDEN

var grid: Array = []
var active: ActivePiece = null
var lines := 0
var over := false

var _factory: PieceFactory

func _init(factory: PieceFactory) -> void:
	_factory = factory
	_reset_grid()
	spawn()

func _reset_grid() -> void:
	grid = []
	for y in range(ROWS_TOTAL):
		var row := []
		for x in range(COLS):
			row.append("")
		grid.append(row)

## Pide una pieza a la factory y la coloca asomando en la primera fila visible.
func spawn() -> void:
	active = _factory.create(Vector2i.ZERO)
	active.pos = Vector2i((COLS - active.width()) / 2, ROWS_HIDDEN - _bottom_row(active.shape))
	if not fits(active.shape, active.pos):
		_declare_game_over()

func _bottom_row(shape: Array) -> int:
	for r in range(shape.size() - 1, -1, -1):
		for c in range(shape[r].size()):
			if shape[r][c] != 0:
				return r
	return 0

## True si la forma encaja en la posicion dada sin salirse ni solapar.
func fits(shape: Array, pos: Vector2i) -> bool:
	for r in range(shape.size()):
		for c in range(shape[r].size()):
			if shape[r][c] == 0:
				continue
			var gx := pos.x + c
			var gy := pos.y + r
			if gx < 0 or gx >= COLS or gy >= ROWS_TOTAL:
				return false
			if gy >= 0 and grid[gy][gx] != "":
				return false
	return true

func try_move(dx: int, dy: int) -> bool:
	if over or active == null:
		return false
	var np := Vector2i(active.pos.x + dx, active.pos.y + dy)
	if fits(active.shape, np):
		active.pos = np
		return true
	return false

func try_rotate(clockwise: bool = true) -> bool:
	if over or active == null:
		return false
	var rotated := active.rotated(clockwise)
	if fits(rotated, active.pos):
		active.shape = rotated
		return true
	for kick in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(2, 0), Vector2i(0, -1)]:
		if fits(rotated, active.pos + kick):
			active.shape = rotated
			active.pos += kick
			return true
	return false

## Fila mas baja alcanzable por la pieza activa (previsualizacion de caida).
func ghost_y() -> int:
	var y := active.pos.y
	while fits(active.shape, Vector2i(active.pos.x, y + 1)):
		y += 1
	return y

## Baja una fila; si no puede, fija la pieza.
func step_down() -> void:
	if over or active == null:
		return
	if not try_move(0, 1):
		lock_piece()

func lock_piece() -> void:
	if over or active == null:
		return
	var locked := active.type
	var tocado := false
	var min_row := ROWS_TOTAL
	for cell in active.cells():
		if cell.y < 0 or cell.y >= ROWS_TOTAL or cell.x < 0 or cell.x >= COLS:
			continue
		grid[cell.y][cell.x] = locked
		min_row = mini(min_row, cell.y)
		tocado = true
	active = null
	if tocado:
		piece_locked.emit(locked)
		# una celda fijada en la zona oculta = la pila supera el lienzo visible
		if min_row < ROWS_HIDDEN:
			_declare_game_over()
			return
	var cleared := _clear_lines()
	if cleared > 0:
		lines_cleared.emit(cleared, cleared >= 4)
	spawn()

func _clear_lines() -> int:
	var full: Array[int] = []
	# solo filas visibles: la zona oculta no regala lineas
	for y in range(ROWS_HIDDEN, ROWS_TOTAL):
		var all := true
		for x in range(COLS):
			if grid[y][x] == "":
				all = false
				break
		if all:
			full.append(y)
	if full.is_empty():
		return 0
	var new_grid: Array = []
	for y in range(ROWS_TOTAL):
		if y in full:
			continue
		new_grid.append(grid[y])
	while new_grid.size() < ROWS_TOTAL:
		var empty_row := []
		for x in range(COLS):
			empty_row.append("")
		new_grid.push_front(empty_row)
	grid = new_grid
	lines += full.size()
	return full.size()

func _declare_game_over() -> void:
	if over:
		return
	over = true
	active = null
	game_over.emit()

func cell_at(gx: int, gy: int) -> String:
	if gy < 0 or gy >= ROWS_TOTAL or gx < 0 or gx >= COLS:
		return ""
	return grid[gy][gx]

## Tipo de la pieza que aparecera despues de la activa.
func next_type() -> String:
	return _factory.peek_next()
