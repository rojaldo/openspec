## board_model.gd — Estado y reglas del juego (orquesta los 6 patrones).
##
## Aquí NO se dibuja nada y NO se leen teclas: solo se aplican las reglas.
## Es el punto donde los patrones colaboran en el orden exacto del enunciado:
##   1. Orbol genera/distribuye  -> (dentro de PieceFactory)
##   2. Factory elige la siguiente pieza a caer
##   3. Command informa al canvas de esa pieza siguiente
##   4. La pieza cae; al posarse, Composite forma la unidad (Pile)
##   5. Builder detecta y elimina filas completas
##   6. Observer recibe el aviso -> sube score y contador de líneas
##   7. Se elige otra pieza (vuelta al paso 2)
##   8. Si la pila supera el área de juego -> fin de partida
##
## Márgenes de seguridad: el grid tiene ROWS_TOTAL=22 filas = 2 de buffer arriba
## (invisibles) + 20 visibles. El buffer se usa para SPAWN y rotación, y garantiza
## que ninguna pieza traspasa los bordes: el origen nunca baja de y=0.
class_name BoardModel
extends RefCounted

const COLS := 10
const VISIBLE_ROWS := 20
const BUFFER := 2                       ## Buffer de seguridad de 2 celdas.
const ROWS_TOTAL := VISIBLE_ROWS + BUFFER  ## 22.

## Señales para la VISTA (el Observer del patrón 4 va por LineSubject).
signal state_changed                     ## Reordenar redibujado.
signal piece_locked(type: String)
signal lines_cleared(count: int, is_tetris: bool)
signal game_over

var pile: CompositePile.Pile
var builder: LineBuilder
var subject: LineSubject
## Observador de puntuación (patrón 4). El controlador lo crea y lo adjunta al
## subject; la vista lo consulta para pintar score/líneas/nivel.
var score_observer: ScoreObserver = null

var _factory: PieceFactory
var _canvas: Object = null      ## Receptor del patrón Command (la vista).
var active: Piece = null
var next_type := ""
# NOTA (A2): el modelo NO guarda ningún flag de fin de partida. Solo DETECTA el
# desbordamiento y emite la señal `game_over`; el estado lo mantiene el FSM
# (GameStateMachine, patrón 7), que es la autoridad única.

func _init(factory: PieceFactory, builder: LineBuilder, subject: LineSubject) -> void:
	_factory = factory
	self.builder = builder
	self.subject = subject
	pile = CompositePile.Pile.new(ROWS_TOTAL, COLS)

## Arranca la partida: prepara el pipeline de piezas (activa + siguiente).
func start() -> void:
	# Primera pieza: Factory (paso 2).
	active = _factory.create_next()
	# Pieza siguiente que se comunicará al canvas (paso 3).
	next_type = _factory.create_next().type
	# 3. Command: informa al canvas cuál es la siguiente pieza a caer.
	_execute_next_command()
	_emit_state()

## El controlador entrega la vista ("canvas") receptora del patrón Command.
func attach_canvas(canvas: Object) -> void:
	_canvas = canvas
	_execute_next_command()

## Ejecuta el Command con la pieza siguiente actual hacia el canvas.
func _execute_next_command() -> void:
	if _canvas != null:
		SetNextPieceCommand.new(_canvas, next_type).execute()

func _emit_state() -> void:
	state_changed.emit()

## ---- Consultas de colisión sobre el COMPOSITE (unidad cohesiva) ----

## ¿Cabe `matrix` con origen `pos` dentro del grid y sin chocar con la pila?
## Nota del buffer: se exige pos.y >= 0, así una pieza jamás sale por arriba;
## como mucho ocupa la fila 0 (primera fila del buffer), nunca fuera del grid.
func _fits(matrix: Array, pos: Vector2i) -> bool:
	if pos.y < 0:
		return false
	for r in range(matrix.size()):
		for c in range(matrix[r].size()):
			if matrix[r][c] == 0:
				continue
			var gx := pos.x + c
			var gy := pos.y + r
			if gy < 0 or gy >= ROWS_TOTAL:
				return false
			if pile.blocks(gx, gy):
				return false
	return true

## ---- Movimiento y rotación (controles) ----
func try_move(dx: int, dy: int) -> bool:
	if active == null:
		return false
	var np := Vector2i(active.pos.x + dx, active.pos.y + dy)
	if _fits(active.matrix, np):
		active.pos = np
		_emit_state()
		return true
	return false

## Rota con "wall kicks" simples: si no cabe girada, prueba desplazamientos.
func try_rotate(clockwise := true) -> bool:
	if active == null:
		return false
	var rot := active.rotated(clockwise)
	for kick in [Vector2i(0,0), Vector2i(-1,0), Vector2i(1,0), Vector2i(-2,0), Vector2i(2,0), Vector2i(0,-1)]:
		if _fits(rot, active.pos + kick):
			active.matrix = rot
			active.pos += kick
			_emit_state()
			return true
	return false

## Un paso de gravedad: baja si puede, si no, aterriza (lock).
func step() -> void:
	if active == null:
		return
	if not try_move(0, 1):
		_lock_piece()

func hard_drop() -> void:
	if active == null:
		return
	while try_move(0, 1):
		pass
	_lock_piece()

## Fila donde aterrizaría la pieza (para el "ghost" de la vista).
func ghost_y() -> int:
	if active == null:
		return 0
	var y := active.pos.y
	while _fits(active.matrix, Vector2i(active.pos.x, y + 1)):
		y += 1
	return y

## ---- Aterrizaje: Composite -> Builder -> Observer ----
func _lock_piece() -> void:
	var locked_type := active.type
	# 4. Composite: la pieza se funde en la pila (unidad cohesiva).
	pile.merge_piece(active.cells(), active.type)
	piece_locked.emit(locked_type)

	# 5. Builder: detecta y elimina filas completas (una o varias).
	var cleared := builder.process_rows(pile)
	if cleared > 0:
		# 6. Observer: se notifica el hecho; él actualiza score y contador.
		subject.notify_lines_cleared(cleared, builder.last_was_tetris)
		lines_cleared.emit(cleared, builder.last_was_tetris)

	# 8. Fin de partida si la pila invade el buffer superior.
	if pile.invades_top(BUFFER):
		_end_game()
		return

	# 2-3. Factory elige la siguiente; Command la comunica al canvas.
	_spawn_next()

func _spawn_next() -> void:
	var piece := _factory.create_next()
	# ¿Cabe en el buffer? Si no, la pila tapó la zona de aparición -> fin.
	if not _fits(piece.matrix, piece.pos):
		_end_game()
		return
	active = piece
	next_type = _factory.create_next().type
	# 3. Command: comunica al canvas la nueva pieza siguiente.
	_execute_next_command()
	_emit_state()

func _end_game() -> void:
	# Al no quedar pieza activa, todas las acciones quedan bloqueadas solas
	# (los guards comprueban active == null). El FSM mantiene el estado.
	active = null
	game_over.emit()
	_emit_state()
