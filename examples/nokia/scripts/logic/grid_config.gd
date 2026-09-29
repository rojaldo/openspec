extends RefCounted
## Constantes globales del motor y valores por defecto del tablero.
## Las dimensiones reales las aporta el nivel; estas son el respaldo
## para cualquier uso sin nivel cargado.

const CELL := 32
const WIDTH := 20
const HEIGHT := 20


static func board_size_px(width: int = WIDTH, height: int = HEIGHT) -> Vector2:
	return Vector2(width * CELL, height * CELL)
