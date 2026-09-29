## tests/next_piece_test.gd — REGRESIÓN del indicador "NEXT".
##
## Ejecutar: godot --headless --path . --script res://tests/next_piece_test.gd
##
## Bug: el HUD anunciaba una pieza siguiente que NO era la que aparecía. Causa:
## el modelo consumía la pieza vista previa y la descartaba, creando otra nueva.
## Invariante: la pieza anunciada (NEXT / Command) debe ser EXACTAMENTE la que se
## deposita en el siguiente spawn.
extends SceneTree

var _failures := 0

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS  ", msg)
	else:
		_failures += 1
		printerr("  FAIL  ", msg)

## "Canvas" falso: registra la última pieza anunciada por el Command.
class Canvas:
	extends RefCounted
	var announced := ""
	var calls := 0
	func set_next_piece(t: String) -> void:
		announced = t
		calls += 1

func _initialize() -> void:
	print("=== Tetris Comic :: NEXT regression test ===")

	var canvas := Canvas.new()
	var model := BoardModel.new(PieceFactory.new(Orbol.new(2024)), LineBuilder.new(), LineSubject.new())
	model.attach_canvas(canvas)
	model.start()

	# Al arrancar, el canvas ya debe conocer la siguiente pieza.
	_ok(canvas.calls >= 1 and canvas.announced != "",
		"el Command anuncia una pieza siguiente al arrancar (%s)" % canvas.announced)
	# Y no es la activa.
	_ok(canvas.announced != model.active.type,
		"la pieza anunciada (%s) difiere de la activa (%s)" % [canvas.announced, model.active.type])

	# Invariante a lo largo de varias piezas: lo anunciado == lo que aparece luego.
	var mismatches := 0
	var checked := 0
	for i in range(12):
		var announced: String = canvas.announced
		var expected_next: String = model.next_type
		# Deposita la pieza actual: el modelo debe spawnear EXACTAMENTE la anunciada.
		model.hard_drop()
		if model.active == null:
			break  # game over por pila; no hay siguiente
		checked += 1
		if model.active.type != announced:
			mismatches += 1
			printerr("      iter %d: anunciada=%s, apareció=%s (next_type interno=%s)"
				% [i, announced, model.active.type, expected_next])
		if canvas.announced != model.next_type:
			mismatches += 1
			printerr("      iter %d: canvas=%s != model.next_type=%s" % [i, canvas.announced, model.next_type])

	_ok(checked >= 8, "se comprobaron varias piezas (%d)" % checked)
	_ok(mismatches == 0,
		"la pieza anunciada SIEMPRE es la que aparece (%d desajustes en %d piezas)" % [mismatches, checked])

	print("=== ", ("ALL PASS" if _failures == 0 else str(_failures) + " FAILURE(S)"), " ===")
	quit(1 if _failures > 0 else 0)
