## ActivePiece.gd — Pieza en juego: tipo, forma actual y posicion.
## La forma se rota en el sitio; no conoce el tablero ni el dibujado.
class_name ActivePiece
extends RefCounted

var type: String
var shape: Array
var pos: Vector2i

func _init(p_type: String, p_pos: Vector2i = Vector2i.ZERO) -> void:
	type = p_type
	shape = Tetromino.shape(p_type)
	pos = p_pos

func width() -> int:
	return shape[0].size()

func height() -> int:
	return shape.size()

## Rota en sentido horario. Devuelve la forma rotada sin aplicarla.
func rotated(clockwise: bool = true) -> Array:
	return Tetromino.rotate_matrix(shape, clockwise)

func apply_rotation(clockwise: bool = true) -> void:
	shape = rotated(clockwise)

## Celdas ocupadas en coordenadas absolutas del tablero.
func cells(origin: Vector2i = Vector2i(-1, -1)) -> Array[Vector2i]:
	var base := pos if origin == Vector2i(-1, -1) else origin
	var out: Array[Vector2i] = []
	for r in range(shape.size()):
		for c in range(shape[r].size()):
			if shape[r][c] != 0:
				out.append(base + Vector2i(c, r))
	return out
