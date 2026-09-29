extends RefCounted
## Matematica de dibujado: posicion de cada segmento entre dos ticks.
## Puro y testeable: no toca nodos ni dibuja nada.
##
## Un segmento avanza de `from` a `to`. Si el salto es mayor que una celda,
## es un cruce de borde y se devuelven DOS posiciones (la que sale y la que
## entra), que juntas dan la continuidad visual sin trazar nada por encima
## del tablero.

const GridConfig = preload("res://scripts/logic/grid_config.gd")


## Posiciones en celdas (sin escalar por CELL) de un segmento con progreso t.
static func segment_positions(from: Vector2i, to: Vector2i, t: float) -> Array[Vector2]:
	var delta := to - from
	if absi(delta.x) <= 1 and absi(delta.y) <= 1:
		return [Vector2(from).lerp(Vector2(to), t)]

	var step := Vector2i.ZERO
	if delta.x != 0:
		step.x = -1 if from.x == 0 else 1
	if delta.y != 0:
		step.y = -1 if from.y == 0 else 1

	var leaving := Vector2(from.x + step.x * t, from.y + step.y * t)
	var entering := Vector2(
		to.x - step.x * (1.0 - t),
		to.y - step.y * (1.0 - t)
	)
	return [leaving, entering]


## Posiciones de todos los segmentos del cuerpo en el tick actual.
## El segmento i va de donde estaba (misma posicion en `prev`) a donde esta.
static func snake_positions(prev: Array[Vector2i], cells: Array[Vector2i], t: float) -> Array:
	var out: Array = []
	for i in cells.size():
		var from: Vector2i = prev[i] if i < prev.size() else cells[i]
		out.append(segment_positions(from, cells[i], t))
	return out
