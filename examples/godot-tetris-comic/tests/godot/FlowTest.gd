## FlowTest.gd — Transiciones START -> PLAYING -> GAMEOVER (tareas 4.3, 4.5, 5.2).
## Ejecutar: godot --headless --script tests/godot/FlowTest.gd
extends SceneTree

var _fallos := 0

func _initialize() -> void:
	_root_ready()
	await _test_flujo()
	await _test_puntuacion_en_partida()
	if _fallos == 0:
		print("FlowTest OK")
	else:
		print("FlowTest FALLOS: ", _fallos)
	quit(_fallos)

func _err(m: String) -> void:
	push_error(m)
	_fallos += 1

func _root_ready() -> void:
	root.size = Vector2i(480, 720)
	var escena: PackedScene = load("res://scenes/Main.tscn")
	var main: Node = escena.instantiate()
	root.add_child(main)
	_game = main

var _game: Node

func _key(code: int) -> void:
	var ev := InputEventKey.new()
	ev.keycode = code
	ev.pressed = true
	root.push_input(ev)

func _frames(n: int) -> void:
	for i in range(n):
		await process_frame

func _play() -> Node:
	for c in _game.get_children():
		if c is PlayScreen:
			return c
	return null

func _overlay() -> Node:
	for c in _game.get_children():
		if c is GameOverOverlay:
			return c
	return null

func _forzar_game_over() -> void:
	var p := _play()
	var b: BoardBuilder = p.builder
	for x in range(b.COLS):
		for y in range(b.ROWS_HIDDEN):
			b.grid[y][x] = "I"
	b.active = ActivePiece.new("O", Vector2i(0, b.ROWS_HIDDEN - 2))
	b.lock_piece()
	await _frames(6)

func _test_flujo() -> void:
	await _frames(6)
	if _game.estado != 0:
		_err("deberia arrancar en START (estado 0), es %d" % _game.estado)
		return
	print("  arranca en START")

	_key(KEY_SPACE)
	await _frames(6)
	if _game.estado != 1 or _play() == null:
		_err("espacio deberia llevar a PLAYING")
		return
	print("  START -> PLAYING con espacio")
	if _play().final_score() != 0 or _play().builder.lines != 0:
		_err("la partida nueva deberia empezar a cero")
		return
	print("  4.5 partida nueva a cero")

	await _forzar_game_over()
	if _game.estado != 2 or _overlay() == null:
		_err("el fin de partida deberia llevar a GAMEOVER")
		return
	print("  fin de partida -> GAMEOVER con capa superpuesta")

	_key(KEY_R)
	await _frames(6)
	if _game.estado != 1 or _overlay() != null:
		_err("reintentar deberia volver a PLAYING y quitar la capa")
		return
	if _play().final_score() != 0:
		_err("reintentar deberia empezar a cero")
		return
	print("  GAMEOVER -> PLAYING con reintentar, marcador a cero")

	await _forzar_game_over()
	_key(KEY_M)
	await _frames(6)
	if _game.estado != 0 or _play() != null:
		_err("menu deberia volver a START")
		return
	print("  GAMEOVER -> START con menu")

## 3.4/5.4 puntuacion y onomatopeya en partida real.
func _test_puntuacion_en_partida() -> void:
	_key(KEY_SPACE)
	await _frames(6)
	var p := _play()
	var b: BoardBuilder = p.builder
	# deja la fila visible inferior a falta de una columna y limpiala a mano
	var fila := b.ROWS_TOTAL - 1
	for x in range(b.COLS - 1):
		b.grid[fila][x] = "I"
	b.grid[fila][b.COLS - 1] = "I"
	var antes: int = p.final_score()
	var n := b._clear_lines()
	b.lines_cleared.emit(n, false)
	await _frames(4)
	if p.final_score() != antes + 100:
		_err("una linea deberia sumar 100 (antes %d, ahora %d)" % [antes, p.final_score()])
		return
	if b.lines != 1:
		_err("el contador de lineas deberia ser 1")
		return
	print("  3.4 una linea suma 100 y el contador sube")
