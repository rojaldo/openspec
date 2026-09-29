## ActivePieceTest.gd — Forma y rotacion de la pieza activa (tarea 2.3).
## Ejecutar: godot --headless --script tests/godot/ActivePieceTest.gd
extends SceneTree

func _initialize() -> void:
	var fallos := 0
	fallos += _test_forma_conocida()
	fallos += _test_cuatro_rotaciones()
	fallos += _test_celdas_absolutas()
	if fallos == 0:
		print("ActivePieceTest OK")
	else:
		print("ActivePieceTest FALLOS: ", fallos)
	quit(fallos)

func _test_forma_conocida() -> int:
	var p := ActivePiece.new("T", Vector2i(3, 2))
	if p.width() != 3 or p.height() != 3:
		push_error("T deberia ser 3x3, es %dx%d" % [p.width(), p.height()])
		return 1
	p.apply_rotation(true)
	# [[0,1,0],[1,1,1],[0,0,0]] horario -> [[0,1,0],[0,1,1],[0,1,0]]
	if p.shape[1][2] != 1 or p.shape[0][0] != 0 or p.shape[2][0] != 0:
		push_error("rotacion de T incorrecta: %s" % [p.shape])
		return 1
	print("  T rota como se espera")
	return 0

func _test_cuatro_rotaciones() -> int:
	for t in Tetromino.TYPES:
		var p := ActivePiece.new(t)
		var original := p.shape.duplicate(true)
		for i in range(4):
			p.apply_rotation(true)
		if p.shape != original:
			push_error("%s: 4 rotaciones no vuelven a la forma original" % t)
			return 1
	print("  4 rotaciones restauran la forma en los 7 tipos")
	return 0

func _test_celdas_absolutas() -> int:
	var p := ActivePiece.new("O", Vector2i(4, 5))
	var celdas := p.cells()
	if celdas.size() != 4:
		push_error("O deberia tener 4 celdas, tiene %d" % celdas.size())
		return 1
	for c in celdas:
		if c.x < 4 or c.x > 5 or c.y < 5 or c.y > 6:
			push_error("celda fuera de lo esperado: %s" % [c])
			return 1
	print("  celdas absolutas correctas")
	return 0
