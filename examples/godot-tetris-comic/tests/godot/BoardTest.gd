## BoardTest.gd — Tablero: encaje, aterrizaje, fijado, lineas, fin de partida,
## puntuacion y velocidad (tareas 2.5 a 2.10).
## Ejecutar: godot --headless --script tests/godot/BoardTest.gd
extends SceneTree

var _fallos := 0

func _initialize() -> void:
	_test_encaje()
	_test_ghost()
	_test_fijado()
	_test_lineas()
	_test_multi_linea()
	_test_sin_lineas()
	_test_fin_de_partida()
	_test_puntuacion()
	_test_velocidad()
	if _fallos == 0:
		print("BoardTest OK")
	else:
		print("BoardTest FALLOS: ", _fallos)
	quit(_fallos)

func _err(msg: String) -> void:
	push_error(msg)
	_fallos += 1

func _board(seed_val: int = 1) -> BoardBuilder:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	return BoardBuilder.new(PieceFactory.new(rng))

# --- 2.5 encaje -------------------------------------------------------------
func _test_encaje() -> void:
	var b := _board()
	if b.active == null:
		_err("el tablero deberia tener pieza activa al empezar")
		return
	var shape := [[1, 1], [1, 1]]
	if b.fits(shape, Vector2i(-1, 0)):
		_err("no deberia encajar fuera de las columnas por la izquierda")
	if b.fits(shape, Vector2i(b.COLS - 1, 0)):
		_err("no deberia encajar fuera de las columnas por la derecha")
	if b.fits(shape, Vector2i(0, b.ROWS_TOTAL - 1)):
		_err("no deberia encajar bajo el suelo")
	if not b.fits(shape, Vector2i(0, 0)):
		_err("deberia encajar en un tablero vacio")
	b.grid[5][0] = "T"
	if b.fits(shape, Vector2i(0, 4)):
		_err("no deberia encajar solapando una celda ocupada")
	if _fallos == 0:
		print("  2.5 encaje: fuera de columnas, bajo el suelo y solape rechazados")

# --- 2.5 ghost --------------------------------------------------------------
func _test_ghost() -> void:
	var b := _board()
	var gy := b.ghost_y()
	if gy < b.active.pos.y:
		_err("el ghost no puede estar por encima de la pieza")
		return
	if b.fits(b.active.shape, Vector2i(b.active.pos.x, gy + 1)):
		_err("el ghost deberia ser la fila mas baja alcanzable")
		return
	print("  2.5 ghost: la previsualizacion aterriza en la fila %d" % gy)

# --- 2.6 fijado -------------------------------------------------------------
func _test_fijado() -> void:
	var b := _board()
	var tipo := b.active.type
	while b.try_move(0, 1):
		pass
	b.lock_piece()
	var ocupadas := 0
	var de_tipo := 0
	for y in range(b.ROWS_TOTAL):
		for x in range(b.COLS):
			if b.grid[y][x] != "":
				ocupadas += 1
				if b.grid[y][x] == tipo:
					de_tipo += 1
	if ocupadas == 0:
		_err("tras fijar, las celdas deberian quedar en el grid")
		return
	if de_tipo != ocupadas:
		_err("las celdas fijadas deberian llevar el tipo %s" % tipo)
		return
	if b.active == null:
		_err("tras fijar deberia aparecer una pieza nueva")
		return
	print("  2.6 fijado: la pieza se une al grid y aparece una nueva")

# --- 2.7 lineas -------------------------------------------------------------
func _test_lineas() -> void:
	var b := _board()
	# completa la fila visible inferior y deja una sola celda suelta encima
	var fila := b.ROWS_TOTAL - 1
	for x in range(b.COLS):
		b.grid[fila][x] = "I"
	b.grid[fila - 1][0] = "Z"
	var n := b._clear_lines()
	if n != 1:
		_err("deberia eliminar 1 linea, elimino %d" % n)
		return
	if b.grid[b.ROWS_TOTAL - 1][0] != "Z":
		_err("tras compactar, lo de arriba deberia bajar")
		return
	print("  2.7 lineas: una fila completa desaparece y compacta")

func _test_multi_linea() -> void:
	var b := _board()
	for y in [b.ROWS_TOTAL - 1, b.ROWS_TOTAL - 2, b.ROWS_TOTAL - 3]:
		for x in range(b.COLS):
			b.grid[y][x] = "S"
	b.grid[b.ROWS_TOTAL - 4][0] = "Z"
	var n := b._clear_lines()
	if n != 3:
		_err("deberian eliminarse 3 lineas, elimino %d" % n)
		return
	if b.grid[b.ROWS_TOTAL - 1][0] != "Z":
		_err("la compactacion de varias lineas a la vez fallo")
		return
	if b.lines != 3:
		_err("el contador de lineas deberia ser 3, es %d" % b.lines)
		return
	print("  2.7 lineas: 3 filas a la vez, una sola compactacion")

func _test_sin_lineas() -> void:
	var b := _board()
	var antes := b.lines
	b.grid[b.ROWS_TOTAL - 1][0] = "T"
	var n := b._clear_lines()
	if n != 0:
		_err("no deberia eliminar lineas, elimino %d" % n)
		return
	if b.lines != antes:
		_err("el contador no deberia cambiar sin lineas")
		return
	print("  2.7 lineas: sin fila completa no cambia nada")

# --- 2.9 fin de partida ----------------------------------------------------
func _test_fin_de_partida() -> void:
	var b := _board()
	var disparos := [0]
	b.game_over.connect(func(): disparos[0] += 1)
	# ocupa toda la zona oculta menos donde caera la pieza
	for x in range(b.COLS):
		for y in range(0, b.ROWS_HIDDEN):
			b.grid[y][x] = "I"
	var activa := b.active
	b.active = ActivePiece.new("O", Vector2i(0, b.ROWS_HIDDEN - 2))
	b.lock_piece()
	if not b.over:
		_err("deberia declarar fin de partida al fijar en la zona oculta")
		return
	if b.active != null:
		_err("tras el fin de partida no deberia quedar pieza activa")
		return
	if disparos[0] != 1:
		_err("la senal de fin de partida deberia emitirse una vez")
		return
	print("  2.9 fin de partida: celda fijada en la zona oculta lo declara")

# --- 2.8 / hud puntuacion ---------------------------------------------------
func _test_puntuacion() -> void:
	var casos := {1: 100, 2: 300, 3: 500, 4: 800}
	for n in casos:
		if Scoring.points(n) != casos[n]:
			_err("%d lineas deberian dar %d, dan %d" % [n, casos[n], Scoring.points(n)])
			return
	if Scoring.points(0) != 0:
		_err("fijar sin lineas no deberia dar puntos")
		return
	print("  2.8 puntuacion: 100/300/500/800 y 0 sin lineas")

# --- 2.10 velocidad ---------------------------------------------------------
func _test_velocidad() -> void:
	if absf(FallSpeed.interval(0) - 0.8) > 0.0001:
		_err("a 0 lineas el intervalo deberia ser 0.8")
		return
	var prev := FallSpeed.interval(0)
	for l in range(1, 200):
		var v := FallSpeed.interval(l)
		if v > prev + 0.000001:
			_err("el intervalo deberia decrecer, subio en %d lineas" % l)
			return
		if v < FallSpeed.MIN - 0.000001:
			_err("el intervalo no puede bajar de %f en %d lineas" % [FallSpeed.MIN, l])
			return
		prev = v
	if absf(FallSpeed.interval(400) - FallSpeed.MIN) > 0.0001:
		_err("con muchas lineas deberia clavarse en el minimo")
		return
	print("  2.10 velocidad: 0.8 inicial, monótona, suelo 0.08")
