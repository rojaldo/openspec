## Scoring.gd — Puntos por lineas eliminadas de una vez.
class_name Scoring
extends RefCounted

const POR_LINEAS := {1: 100, 2: 300, 3: 500, 4: 800}

static func points(n: int) -> int:
	return POR_LINEAS.get(n, 0)
