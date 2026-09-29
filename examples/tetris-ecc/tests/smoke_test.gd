## tests/smoke_test.gd — Comprobación headless de la lógica del juego.
##
## Ejecutar:  godot --headless --path . --script res://tests/smoke_test.gd
## Verifica los requisitos clave, sobre todo la distribución uniforme del Orbol
## (10 de cada tipo por cada 70) y el buffer de seguridad.
extends SceneTree

var _failures := 0

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS  ", msg)
	else:
		_failures += 1
		printerr("  FAIL  ", msg)

func _initialize() -> void:
	print("=== Tetris Comic :: smoke test ===")

	_test_orbol_uniformity()
	_test_factory_and_piece()
	_test_composite_collision()
	_test_builder_multiline()
	_test_observer_score()
	_test_buffer_game_over()

	print("=== ", ("ALL PASS" if _failures == 0 else str(_failures) + " FAILURE(S)"), " ===")
	quit(1 if _failures > 0 else 0)

## 5. ORBOL: cada 70 tiradas deben salir 10 de cada tipo.
func _test_orbol_uniformity() -> void:
	print("[5] Orbol — distribución uniforme")
	var orbol := Orbol.new(12345)
	var counts := {}
	for t in Tetromino.TYPES:
		counts[t] = 0
	for i in range(70):
		counts[orbol.draw()] += 1
	var bad := false
	for t in Tetromino.TYPES:
		if counts[t] != 10:
			bad = true
	_ok(not bad, "70 tiradas -> 10 de cada tipo (obtenido: %s)" % str(counts))
	# Y cualquier bloque de 7 contiene una de cada.
	var o2 := Orbol.new(999)
	var block := {}
	for i in range(7):
		block[o2.draw()] = true
	_ok(block.size() == 7, "un bloque de 7 contiene las 7 piezas distintas")

## 1. FACTORY: elige/crea la pieza con tipo, matriz y posición válidos.
func _test_factory_and_piece() -> void:
	print("[1] Factory — creación de piezas")
	var factory := PieceFactory.new(Orbol.new(7))
	var p := factory.create_next()
	_ok(Tetromino.TYPES.has(p.type), "la pieza creada es de uno de los 7 tipos (%s)" % p.type)
	_ok(p.matrix.size() > 0, "la pieza tiene matriz")
	_ok(p.cells().size() >= 4, "la pieza tiene al menos 4 celdas (%d)" % p.cells().size())

## 2. COMPOSITE: la pila se comporta como unidad (colisión, altura).
func _test_composite_collision() -> void:
	print("[2] Composite — unidad cohesiva")
	var pile := CompositePile.Pile.new(BoardModel.ROWS_TOTAL, BoardModel.COLS)
	_ok(not pile.blocks(3, 10), "celda vacía no bloquea")
	# Deposita la fila inferior completa menos una.
	var cells: Array[Vector2i] = []
	for x in range(9):
		cells.append(Vector2i(x, BoardModel.ROWS_TOTAL - 1))
	pile.merge_piece(cells, "T")
	_ok(pile.blocks(0, BoardModel.ROWS_TOTAL - 1), "celda fusionada bloquea")
	_ok(not pile.blocks(9, BoardModel.ROWS_TOTAL - 1), "celda no fusionada sigue libre")
	_ok(pile.height() == 1, "altura de la pila = 1")
	_ok(not pile.is_row_full(BoardModel.ROWS_TOTAL - 1), "fila incompleta no es completa")

## 3. BUILDER: detecta y elimina una o varias filas y colapsa la pila.
func _test_builder_multiline() -> void:
	print("[3] Builder — eliminación de filas (múltiples)")
	var pile := CompositePile.Pile.new(BoardModel.ROWS_TOTAL, BoardModel.COLS)
	var r := BoardModel.ROWS_TOTAL
	# Dos filas completas + una pieza encima que debe caer al colapsar.
	for y in [r - 1, r - 2]:
		var cells: Array[Vector2i] = []
		for x in range(BoardModel.COLS):
			cells.append(Vector2i(x, y))
		pile.merge_piece(cells, "O")
	pile.merge_piece([Vector2i(4, r - 3)] as Array[Vector2i], "Z")
	var builder := LineBuilder.new()
	var cleared := builder.process_rows(pile)
	_ok(cleared == 2, "se eliminan 2 filas a la vez (%d)" % cleared)
	_ok(pile.blocks(4, r - 1), "la pieza de encima colapsa al fondo")
	_ok(pile.height() == 1, "tras colapsar solo queda 1 fila ocupada")

## 4. OBSERVER: al eliminar línea sube score y contador.
func _test_observer_score() -> void:
	print("[4] Observer — notificación a score/líneas")
	var subject := LineSubject.new()
	var obs := ScoreObserver.new()
	subject.attach(obs)
	subject.notify_lines_cleared(1, false)
	_ok(obs.score == 100 and obs.lines == 1, "1 fila -> score 100, lines 1")
	subject.notify_lines_cleared(4, true)
	_ok(obs.score == 900 and obs.lines == 5, "tetris (4) -> +800, lines 5 (%d/%d)" % [obs.score, obs.lines])
	# Nivel: 10 líneas -> nivel 2.
	var o2 := ScoreObserver.new()
	for i in range(10):
		o2.on_lines_cleared(1, false)
	_ok(o2.level == 2, "10 líneas -> nivel 2")

## Buffer de 2 celdas + fin de partida.
func _test_buffer_game_over() -> void:
	print("[buffer] Seguridad de bordes y fin de partida")
	var pile := CompositePile.Pile.new(BoardModel.ROWS_TOTAL, BoardModel.COLS)
	_ok(not pile.invades_top(BoardModel.BUFFER), "pila vacía no invade el buffer")
	pile.merge_piece([Vector2i(0, 0)] as Array[Vector2i], "I")
	_ok(pile.invades_top(BoardModel.BUFFER), "ocupar la fila 0 invade el buffer -> fin de partida")
	# Grid de 22 = 2 buffer + 20 visibles.
	_ok(BoardModel.ROWS_TOTAL == 22 and BoardModel.BUFFER == 2, "grid = 22 filas (20 visibles + 2 buffer)")
