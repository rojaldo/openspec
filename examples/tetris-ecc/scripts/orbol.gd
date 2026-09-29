## orbol.gd — PATRÓN 5: ORBOL (generador y distribuidor de piezas).
##
## Responsabilidad ÚNICA e intransferible:
##   "Al inicio de la partida genera una colección de piezas y las distribuye
##    de forma aleatoria, garantizando una distribución uniforme: cada 70
##    piezas deben haber caído 10 de cada tipo."
##
## Decisión razonada — ¿cómo se garantiza "10 de cada tipo por cada 70"?
##   La forma exacta y justa es un BOLSA DE 7 (7-bag randomizer): se barajan las
##   7 piezas y se reparten una a una. Al terminar la bolsa se baraja otra.
##   Consecuencia matemática: cualquier bloque de 7 tiradas consecutivas contiene
##   exactamente una de cada tipo -> cualquier bloque de 70 contiene 10 de cada
##   tipo. Uniforme Y sin sequías (no puede salir la misma pieza 6 veces seguidas).
##   La alternativa ingenua (rng.randi() % 7 por tirada) NO garantiza la cuota,
##   por eso el código de referencia del pack no sirve para este requisito.
##
## El Orbol SOLO decide el orden de los tipos. No conoce formas, ni colores, ni
## el tablero: eso es del Factory y de la vista.
class_name Orbol
extends RefCounted

var _bag: Array[String] = []
var _rng := RandomNumberGenerator.new()

## Nº de piezas generadas en total (útil para HUD/tests).
var drawn_count := 0

func _init(seed_value: int = 0) -> void:
	if seed_value == 0:
		_rng.randomize()
	else:
		_rng.seed = seed_value
	_refill_bag()

## "Genera una colección de piezas": una bolsa con las 7 barajadas.
func _refill_bag() -> void:
	_bag = Tetromino.TYPES.duplicate()
	# Barajado Fisher-Yates con nuestro RNG (reproducible si se fija semilla).
	for i in range(_bag.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp := _bag[i]
		_bag[i] = _bag[j]
		_bag[j] = tmp

## "Distribuye de forma aleatoria": entrega el siguiente tipo y repuebla la bolsa
## cuando se agota. Garantiza la cuota uniforme de 10/70 por construcción.
func draw() -> String:
	if _bag.is_empty():
		_refill_bag()
	drawn_count += 1
	return _bag.pop_back()
