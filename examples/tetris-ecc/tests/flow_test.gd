## tests/flow_test.gd — GameFlow: gobernanza PURA del juego por el FSM (T3).
##
## Ejecutar: godot --headless --path . --script res://tests/flow_test.gd
## Ejercita el objeto de gobernanza REAL (no un replica), sin escena ni nodos.
extends SceneTree

var _failures := 0

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS  ", msg)
	else:
		_failures += 1
		printerr("  FAIL  ", msg)

## Receptor falso del Command (canvas): registra la pieza siguiente.
class FakeCanvas:
	extends RefCounted
	var last_next := ""
	var calls := 0
	func set_next_piece(t: String) -> void:
		last_next = t
		calls += 1

## Observador falso (patrón Observer): registra los avisos de línea.
class FakeObserver:
	extends RefCounted
	var total := 0
	func on_lines_cleared(count: int, _is_tetris: bool) -> void:
		total += count

func _initialize() -> void:
	print("=== Tetris Comic :: GameFlow test (gobernanza FSM) ===")

	var S := GameStateMachine.State
	var flow := GameFlow.new()
	var canvas := FakeCanvas.new()
	var observer := FakeObserver.new()
	flow.attach_canvas(canvas)
	flow.attach_lines_observer(observer)

	# --- START: el juego NO existe aún ---
	_ok(flow.state() == S.START, "GameFlow arranca en START")
	_ok(flow.model == null, "en START no hay modelo (el juego no ha empezado)")
	_ok(flow.tick(0.5, false) == false, "tick no hace nada en START (juego inerte)")
	_ok(not flow.move(-1) and not flow.rotate() and not flow.hard_drop(),
		"movimiento/rotación/hard-drop inertes en START")

	# --- START -> PLAYING ---
	_ok(flow.press_start() == true, "press_start() en START -> transición a PLAYING")
	_ok(flow.state() == S.PLAYING, "estado = PLAYING")
	_ok(flow.model != null and flow.model.active != null, "en PLAYING hay modelo con pieza activa")
	_ok(canvas.calls >= 1, "el Command notificó al canvas la pieza siguiente (%d)" % canvas.calls)

	# --- tick avanza la gravedad (juego gobernado) ---
	var y0: int = flow.model.active.pos.y
	var moved := false
	for i in range(40):
		if flow.tick(0.1, false):
			moved = true
	_ok(moved, "tick mueve la pieza (gravedad activa en PLAYING)")

	# --- acciones de juego ---
	# Con la pieza pegada a la pared izquierda, mover a la izquierda debe fallar.
	for i in range(12):
		flow.move(-1)
	_ok(flow.move(-1) == false, "move(-1) falla si no cabe (p. ej. contra la pared)")
	_ok(flow.hard_drop(), "hard_drop() funciona en PLAYING")

	# --- la línea eliminada se notifica al observador ---
	var pre := observer.total
	# Rellena una fila casi completa y deja caer una monocelda.
	var R := BoardModel.ROWS_TOTAL
	var cells: Array[Vector2i] = []
	for x in range(BoardModel.COLS - 1):
		cells.append(Vector2i(x, R - 1))
	flow.model.pile.merge_piece(cells, "T")
	flow.model.active.pos = Vector2i(BoardModel.COLS - 1, 5)
	flow.model.active.matrix = [[1]]
	flow.hard_drop()
	_ok(observer.total > pre, "el Observer recibió la notificación de línea (%d -> %d)" % [pre, observer.total])

	# --- PLAYING -> GAME_OVER por señal del modelo ---
	flow.model.pile.grid[0][0] = CompositePile.Cell.new("I")
	flow.model.pile.grid[1][7] = CompositePile.Cell.new("I")
	flow.model.active.pos = Vector2i(4, 3)
	flow.model.active.matrix = [[1, 1, 1, 1]]
	flow.hard_drop()
	_ok(flow.state() == S.GAME_OVER, "la pila que invade el buffer -> GAME_OVER (gobernado por el FSM)")
	_ok(flow.model.active == null, "en GAME_OVER no hay pieza activa")
	_ok(flow.tick(5.0, true) == false, "tick inerte en GAME_OVER")
	_ok(not flow.move(1) and not flow.rotate() and not flow.hard_drop(),
		"acciones inertes en GAME_OVER (no mutan el tablero)")

	# --- GAME_OVER -> START (volver al título) ---
	_ok(flow.return_to_title() == true, "return_to_title() en GAME_OVER -> START")
	_ok(flow.state() == S.START, "estado = START")
	_ok(flow.model == null, "al volver al título se suelta el modelo")

	# --- START -> PLAYING otra vez: partida NUEVA (tablero y score limpios) ---
	var canvas_calls := canvas.calls
	_ok(flow.press_start() == true, "segundo press_start() -> PLAYING de nuevo")
	_ok(flow.model.pile.height() == 0, "partida nueva: tablero vacío (reinicio real)")
	_ok(flow.model.active != null, "partida nueva: hay pieza activa")
	_ok(canvas.calls > canvas_calls, "el Command vuelve a notificar al canvas en la nueva partida")

	# --- press_start() ilegal durante PLAYING ---
	var before := flow.state()
	_ok(flow.press_start() == false and flow.state() == before,
		"press_start() es ilegal durante PLAYING (no reinicia a mitad)")

	# --- la señal state_changed llega con (from, to) ---
	var seen: Array = []
	flow.state_changed.connect(func(from, to): seen.append([from, to]))
	flow.model.pile.grid[0][0] = CompositePile.Cell.new("I")
	flow.model.active.pos = Vector2i(5, 3)
	flow.model.active.matrix = [[1]]
	flow.hard_drop()
	_ok(flow.state() == S.GAME_OVER and seen.size() >= 1 and seen[-1][1] == S.GAME_OVER,
		"state_changed emite (from, GAME_OVER)")

	print("=== ", ("ALL PASS" if _failures == 0 else str(_failures) + " FAILURE(S)"), " ===")
	quit(1 if _failures > 0 else 0)
