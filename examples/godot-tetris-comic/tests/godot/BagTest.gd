## BagTest.gd — Comprobacion de la bolsa de 7 (tareas 2.1 y 2.2).
## Ejecutar: godot --headless --script tests/godot/BagTest.gd
extends SceneTree

func _initialize() -> void:
	var fallos := 0
	fallos += _test_70_piezas()
	fallos += _test_ciclos_completos()
	fallos += _test_orden_varia()
	if fallos == 0:
		print("BagTest OK")
	else:
		print("BagTest FALLOS: ", fallos)
	quit(fallos)

func _nueva_bolsa(seed_val: int) -> Bag:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	return Bag.new(rng)

func _test_70_piezas() -> int:
	var bag := _nueva_bolsa(1)
	var conteo := {}
	for t in Tetromino.TYPES:
		conteo[t] = 0
	for i in range(70):
		var t := bag.next()
		if not conteo.has(t):
			push_error("tipo fuera del catalogo: " + t)
			return 1
		conteo[t] += 1
	for t in Tetromino.TYPES:
		if conteo[t] != 10:
			push_error("70 piezas: %s sale %d veces (esperado 10)" % [t, conteo[t]])
			return 1
	print("  70 piezas -> 10 de cada tipo")
	return 0

func _test_ciclos_completos() -> int:
	var bag := _nueva_bolsa(7)
	for ciclo in range(5):
		var vistos := {}
		for i in range(7):
			vistos[bag.next()] = true
		if vistos.size() != 7:
			push_error("ciclo %d: solo %d tipos distintos" % [ciclo, vistos.size()])
			return 1
	print("  5 ciclos -> 7 tipos distintos cada uno")
	return 0

func _test_orden_varia() -> int:
	var distintos := {}
	for s in range(20):
		var bag := _nueva_bolsa(s)
		var orden := []
		for i in range(7):
			orden.append(bag.next())
		distintos["|".join(orden)] = true
	if distintos.size() < 2:
		push_error("el orden no varia entre ciclos")
		return 1
	print("  20 ciclos -> %d ordenes distintos" % distintos.size())
	return 0
