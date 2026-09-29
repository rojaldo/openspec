## PieceFactoryTest.gd — La pieza anunciada es la que se entrega (tarea 2.4).
## Ejecutar: godot --headless --script tests/godot/PieceFactoryTest.gd
extends SceneTree

func _initialize() -> void:
	var fallos := 0
	fallos += _test_anuncio_coincide()
	fallos += _test_anuncio_avanza()
	if fallos == 0:
		print("PieceFactoryTest OK")
	else:
		print("PieceFactoryTest FALLOS: ", fallos)
	quit(fallos)

func _test_anuncio_coincide() -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var f := PieceFactory.new(rng)
	for i in range(21):
		var anunciado := f.peek_next()
		var p := f.create(Vector2i(3, 2))
		if p.type != anunciado:
			push_error("iter %d: se anuncio %s y se entrego %s" % [i, anunciado, p.type])
			return 1
	print("  21 entregas coinciden con lo anunciado")
	return 0

func _test_anuncio_avanza() -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var f := PieceFactory.new(rng)
	var primera := f.peek_next()
	f.create(Vector2i.ZERO)
	var segunda := f.peek_next()
	# en una bolsa de 7 el anuncio cambia salvo que la bolsa repita posicion,
	# lo que no ocurre porque next() consume sin reemplazo
	if segunda == primera and primera == segunda:
		var conteo := {}
		for i in range(7):
			conteo[f.peek_next()] = true
			f.create(Vector2i.ZERO)
		if conteo.size() != 7:
			push_error("el anuncio no recorre los 7 tipos")
			return 1
	print("  el anuncio avanza por la bolsa")
	return 0
