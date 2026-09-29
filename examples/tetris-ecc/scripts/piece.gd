## piece.gd — Producto del patrón FACTORY (no es un patrón por sí mismo).
##
## Representa la pieza ACTIVA que está cayendo: tipo, matriz actual (puede haber
## rotado) y su posición (origen) en el grid. Es un objeto de datos puro; las
## reglas de juego viven en el tablero/composite.
class_name Piece
extends RefCounted

var type: String = ""
var matrix: Array = []        ## Matriz NxN de 0/1 (1 = celda ocupada).
var pos := Vector2i(0, 0)     ## Celda del grid donde está el origen (fila 0 = buffer).

## Celdas absolutas ocupadas por la pieza en el grid.
func cells() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for r in range(matrix.size()):
		for c in range(matrix[r].size()):
			if matrix[r][c] != 0:
				out.append(Vector2i(pos.x + c, pos.y + r))
	return out

## Devuelve una copia de la matriz rotada (no muta la pieza).
func rotated(clockwise: bool = true) -> Array:
	return Tetromino.rotate_matrix(matrix, clockwise)
