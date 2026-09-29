## tests/integration_test.gd — Flujo completo de los 6 patrones.
## Ejecutar: godot --headless --path . --script res://tests/integration_test.gd
extends SceneTree

var _failures := 0
var _ran := false
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS  ", m)
	else:
		_failures += 1
		printerr("  FAIL  ", m)

## Receptor falso del COMMAND (simula el canvas).
class FakeCanvas extends RefCounted:
	var last_next := ""
	var calls := 0
	func set_next_piece(t: String) -> void:
		last_next = t
		calls += 1

func _initialize() -> void:
	print("=== Tetris Comic :: integration test ===")
	# [5][1][3][4][6] pipeline completo
	var orbol := Orbol.new(2024)
	var factory := PieceFactory.new(orbol)
	var builder := LineBuilder.new()
	var subject := LineSubject.new()
	var score := ScoreObserver.new()
	subject.attach(score)

	var model := BoardModel.new(factory, builder, subject)
	model.score_observer = score

	var canvas := FakeCanvas.new()
	model.attach_canvas(canvas)   # [6] Command -> canvas
	model.start()

	_ok(canvas.calls >= 1 and Tetromino.TYPES.has(canvas.last_next),
		"Command avisó al canvas de la pieza siguiente (%s)" % canvas.last_next)
	_ok(model.active != null and model.active.type != "",
		"hay pieza activa (%s)" % (model.active.type if model.active else "nil"))

	# [4] La caída se detiene al tocar el fondo.
	var spawn_y := model.active.pos.y
	var steps := 0
	while model.active != null and model.active.pos.y < BoardModel.ROWS_TOTAL - 1 and steps < 50:
		model.step()
		steps += 1
	_ok(spawn_y < (model.active.pos.y if model.active else BoardModel.ROWS_TOTAL),
		"la pieza cae desde el spawn hacia abajo")

	# Rellena a mano una fila casi completa y deja caer una pieza para limpiarla.
	var full_row := BoardModel.ROWS_TOTAL - 1
	var cells: Array[Vector2i] = []
	for x in range(BoardModel.COLS - 1):
		cells.append(Vector2i(x, full_row))
	model.pile.merge_piece(cells, "T")
	# Coloca la pieza activa en la columna libre y hard_drop.
	model.active.pos = Vector2i(BoardModel.COLS - 1, 5)
	model.active.matrix = [[1]]     # monocelda para garantizar el relleno
	var pre_score := score.score
	var pre_lines := score.lines
	model.hard_drop()
	_ok(score.lines == pre_lines + 1,
		"completar 1 fila incrementa el contador de líneas (%d -> %d)" % [pre_lines, score.lines])
	_ok(score.score > pre_score,
		"completar 1 fila incrementa el score (%d -> %d)" % [pre_score, score.score])

	# [8] Fin de partida cuando la pila invade el buffer.
	model = BoardModel.new(PieceFactory.new(Orbol.new(5)), LineBuilder.new(), LineSubject.new())
	model.score_observer = ScoreObserver.new()
	model.start()
	var over := [false]   # contenedor mutable: las lambdas capturan por valor.
	model.game_over.connect(func(): over[0] = true)
	# Ensuciar el buffer superior directamente y forzar el bloqueo.
	model.pile.grid[0][0] = CompositePile.Cell.new("I")
	model.pile.grid[1][7] = CompositePile.Cell.new("I")
	model.active.pos = Vector2i(4, 3)
	model.active.matrix = [[1, 1, 1, 1]]
	model.hard_drop()
	# Tras (A2) el modelo NO guarda flag de fin de partida: solo DETECTA y EMITE.
	# El estado "fin de partida" lo mantiene la máquina de estados (GameFlow).
	_ok(over[0], "la pila que invade el buffer emite game_over (el modelo detecta y avisa)")
	_ok(model.active == null, "tras el fin de partida no queda pieza activa (el modelo deja de mutar)")

	# El smoke de escena va en _process (frame 1): los nodos de Main.tscn no
	# ejecutan _ready hasta que el árbol procesa un frame.

## Instancia Main.tscn y comprueba que arranca en START (juego inerte) y que
## la acción `start` (Enter) transiciona a PLAYING. Es un smoke de cableado:
## el detalle de la gobernanza ya se prueba en tests/flow_test.gd.
func _test_scene_wiring() -> void:
	print("[wiring] Main.tscn gobernado por el FSM")
	var ps := load("res://scenes/Main.tscn") as PackedScene
	if ps == null:
		_ok(false, "no se pudo cargar Main.tscn")
		return
	var main := ps.instantiate()
	get_root().add_child(main)
	_ok(main.flow != null, "Main instancia su GameFlow")
	_ok(main.flow.state() == GameStateMachine.State.START, "la escena arranca en START")
	_ok(main.flow.model == null, "START: el juego no ha empezado (model == null)")
	_ok(main.view.show_board == false, "START: el tablero está oculto (S1)")
	_ok(main.hud.screen == ComicHud.Screen.TITLE, "START: el HUD muestra el título")

	# Pulsación sintética de `start` (Enter) -> PLAYING.
	var ev := InputEventAction.new()
	ev.action = "start"
	ev.pressed = true
	main._unhandled_input(ev)
	_ok(main.flow.state() == GameStateMachine.State.PLAYING, "Enter -> PLAYING")
	_ok(main.flow.model != null and main.flow.model.active != null, "PLAYING: partida en marcha")
	_ok(main.view.show_board == true, "PLAYING: el tablero se muestra")
	_ok(main.hud.screen == ComicHud.Screen.PLAYING, "PLAYING: el HUD muestra el marcador")
	# Regresión: el tablero debe redibujarse con cada cambio del modelo.
	_ok(main.flow.model.state_changed.is_connected(main.view.queue_redraw),
		"PLAYING: model.state_changed está conectado a view.queue_redraw (el tablero se redibuja)")
	main.queue_free()

func _process(_delta: float) -> bool:
	if _ran:
		return true
	_ran = true
	_test_scene_wiring()
	print("=== ", ("ALL PASS" if _failures == 0 else str(_failures) + " FAILURE(S)"), " ===")
	quit(1 if _failures > 0 else 0)
	return true
