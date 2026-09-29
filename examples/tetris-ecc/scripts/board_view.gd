## board_view.gd — "El canvas" (vista). NO contiene reglas de juego.
##
## Dibuja, con las texturas del pack: fondo de papel comic, rejilla halftone,
## la pila depositada, el fantasma (ghost) y la pieza activa.
##
## El patrón 6 (Command) apunta al HUD (ComicHud.set_next_piece) como receptor;
## esta vista solo dibuja el tablero: pila (Composite), fantasma y pieza activa.
extends Node2D
class_name BoardView

const CELL := 32
const COLS := 10
const VISIBLE_ROWS := 20
const BUFFER := 2

var model: BoardModel
## Gate de visibilidad (S1): el FSM decide si el tablero se pinta.
## START -> false (pantalla de título sin tablero); PLAYING/GAME_OVER -> true
## (en GAME_OVER se conserva el tablero muerto bajo la explosión, por drama).
var show_board := true
var _bg: Texture2D
## Cache de texturas de bloque. IMPORTANTE: se cargan en _ready(), no en _draw().
## Si se llama a load() dentro de _draw(), la primera pasada dibuja la textura en
## blanco (aún no está subida a la GPU) y el tablero se queda en blanco.
var _block_cache: Dictionary = {}

func _ready() -> void:
	_bg = load("res://textures/bg_paper.png") as Texture2D
	for t in Tetromino.TYPES:
		_block_cache[t] = Tetromino.block_texture(t)

## Textura de bloque del tipo dado (desde la cache de _ready).
func _block(type: String) -> Texture2D:
	return _block_cache.get(type, null)

## Tamaño en píxeles del área visible del tablero.
func board_size() -> Vector2:
	return Vector2(COLS * CELL, VISIBLE_ROWS * CELL)

## Convierte (col, row_visible) a píxeles locales. row_visible=0 es la primera
## fila VISIBLE (fila BUFFER del grid).
func cell_to_local(x: int, visible_row: int) -> Vector2:
	return Vector2(x * CELL, visible_row * CELL)

## Estado legible para tests: "shown" / "hidden".
func visible_or_hidden_state() -> String:
	return "shown" if show_board else "hidden"

func _draw() -> void:
	if not show_board:
		return
	var size := board_size()
	# Fondo: papel cómic del pack. NO se tilea: el asset es 480x720 y al teselar
	# en 320x640 se recortaba su marco (borde derecho/inferior desaparecían ->
	# tablero con marco asimétrico). Se escala y se dibuja un marco simétrico
	# propio, así el borde es idéntico en los 4 lados.
	if _bg != null:
		draw_texture_rect(_bg, Rect2(Vector2.ZERO, size), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#fdf6e3"), true)
	draw_rect(Rect2(Vector2.ZERO, size), Color("#14110f"), false, 3.0)

	# Rejilla halftone de puntos (marcas de celda, estilo impresión comic).
	var dot := Color(0, 0, 0, 0.10)
	for y in range(VISIBLE_ROWS + 1):
		for x in range(COLS + 1):
			draw_circle(Vector2(x * CELL, y * CELL), 1.5, dot)


	if model == null:
		return

	# Celdas depositadas (Composite): se dibuja cada hoja con su textura.
	for gy in range(BUFFER, BUFFER + VISIBLE_ROWS):
		for gx in range(COLS):
			var cell := model.pile.cell_at(gx, gy)
			if cell != null and cell.filled:
				var tex := _block(cell.type)
				draw_texture(tex, cell_to_local(gx, gy - BUFFER))

	# Pieza activa y su fantasma.
	if model.active != null:
		var piece := model.active
		var tex := _block(piece.type)
		# Fantasma: la pieza desciende al fondo (ghost_y) en semitransparente.
		var dy: int = model.ghost_y() - piece.pos.y
		for c in piece.cells():
			var gy: int = c.y + dy
			if gy >= BUFFER:
				draw_texture(tex, cell_to_local(c.x, gy - BUFFER), Color(1, 1, 1, 0.22))
		# Pieza real.
		for c in piece.cells():
			if c.y >= BUFFER:
				draw_texture(tex, cell_to_local(c.x, c.y - BUFFER))
