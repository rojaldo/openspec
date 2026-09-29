extends SceneTree
## Verifica que la interpolacion esta viva en juego y, sobre todo, que la
## posicion dibujada NUNCA retrocede (regresion del temblor).
##   godot --headless -s tests/run_motion.gd

const GameScreen = preload("res://scripts/screens/game_screen.gd")
const BoardRender = preload("res://scripts/logic/board_render.gd")

var _failed := 0
var _passed := 0


func _initialize() -> void:
	_run()


func check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		printerr("FAIL: " + label)


func _run() -> void:
	# 3.1 El progreso lo lleva el controlador, no un Timer.
	var screen = GameScreen.new()
	root.add_child(screen)
	await process_frame

	check(not _has_timer(screen), "la pantalla de juego ya no tiene nodo Timer")

	# La simulacion no avanza mientras no llega el tick, pero el dibujado si.
	# (Se salta el aviso de nivel, que pausa el movimiento a proposito.)
	screen._banner_left = 0.0
	screen._acc = 0.0
	var cells_before: Array = screen.game.cells.duplicate()
	var p0: float = screen.view.progress

	for i in 5:
		await process_frame
	var p1: float = screen.view.progress

	check(p1 >= p0, "el progreso no retrocede dentro del tick (%f -> %f)" % [p0, p1])
	check(p1 > p0, "el progreso avanza dentro del tick")
	check(p1 > 0.0 and p1 < 1.0, "el progreso esta dentro del intervalo, no en los extremos")
	check(screen.game.cells == cells_before, "el dibujado no altera la simulacion")

	# A mitad de tick, la posicion dibujada esta entre la celda previa y la actual.
	var mid := BoardRender.segment_positions(Vector2i(4, 5), Vector2i(5, 5), 0.49)
	check(mid.size() == 1 and int(mid[0].x) == 4, "a media interpolacion aun no ha llegado a la celda destino")

	# La cola se dibuja quieta el tick que come (crecimiento visible, no salto).
	screen.game.food = screen.game.cells[0] + screen.game.direction
	var tail: Vector2i = screen.game.cells[screen.game.cells.size() - 1]
	screen.step_tick()
	check(screen.game.cells.has(tail), "tras comer, la cola sigue dibujandose en su sitio")

	screen.queue_free()
	await process_frame

	# 4.1 Regresion de monotonía: cero retrocesos visuales con comidas.
	await _check_monotonic_motion()

	print("")
	print("MOTION: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


## Cuenta retrocesos de la posicion dibujada de la cabeza respecto a la
## direccion de avance. Fue la sonda que midio el temblor: el reloj antiguo
## daba ~21 retrocesos en 500 frames; el monótono debe dar cero.
func _check_monotonic_motion() -> void:
	var s = GameScreen.new()
	root.add_child(s)
	await process_frame
	s.game.start(1234)
	s._banner_left = 0.0
	s._interval = s.game.current_interval()
	s._acc = 0.0

	var last := Vector2(-9999, -9999)
	var last_cells: Array = s.game.cells.duplicate()
	var back := 0
	var frames := 0
	while frames < 600 and s.game.alive:
		await process_frame
		frames += 1
		var cells_now: Array = s.game.cells.duplicate()
		var drawn: Vector2 = BoardRender.segment_positions(
			s.game.prev_cells[0], s.game.cells[0], s.view.progress)[0]
		# Solo cuenta el retroceso DENTRO de un tick, con las celdas sin
		# cambiar. Un salto al cruzar el borde cambia de celda y es correcto.
		if last.x != -9999.0 and cells_now == last_cells \
				and (last - drawn).dot(Vector2(s.game.direction)) > 0.5:
			back += 1
		last = drawn
		last_cells = cells_now
		if frames % 50 == 0:
			s.game.food = s.game.cells[0] + s.game.direction

	check(frames > 60, "el test corre frames suficientes (%d)" % frames)
	check(back == 0, "cero retrocesos visuales en %d frames (medido: %d)" % [frames, back])

	s.queue_free()
	await process_frame


func _has_timer(node: Node) -> bool:
	for child in node.get_children():
		if child is Timer:
			return true
		if _has_timer(child):
			return true
	return false
