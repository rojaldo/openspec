## FallSpeed.gd — Intervalo de caida, funcion de las lineas completadas.
class_name FallSpeed
extends RefCounted

const BASE := 0.8
const MIN := 0.08
const DECAY_PER_10 := 0.85

static func interval(lineas: int) -> float:
	if lineas <= 0:
		return BASE
	return maxf(MIN, BASE * pow(DECAY_PER_10, float(lineas) / 10.0))
