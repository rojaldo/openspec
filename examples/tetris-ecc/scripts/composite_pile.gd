## composite_pile.gd — PATRÓN 2: COMPOSITE (unidad cohesiva).
##
## Responsabilidad ÚNICA e intransferible:
##   "Representa el objeto formado cuando una pieza se posa (las piezas
##    depositadas + la nueva), tratándolo como una unidad cohesiva."
##
## Estructura del composite:
##   - CELL (hoja/leaf): una celda ocupada del grid, guarda qué tipo de pieza la
##     depositó (para dibujarla con su textura).
##   - PILE (compuesto/composite): la rejilla completa de celdas. Expone las
##     operaciones de la UNIDAD: ¿está ocupada esta celda?, fusiona una pieza,
##     ¿esta fila está llena?, ¿qué altura tiene la pila?, colapsa filas.
##
## Todas las comprobaciones del juego (colisión, gravedad, fila completa, fin de
## partida) se hacen contra la PILA como un todo, nunca contra piezas sueltas.
## Esa es exactamente la semántica de Composite.
class_name CompositePile
extends RefCounted

## ---- Leaf: una celda del composite ----
class Cell:
	extends RefCounted
	var filled := false
	var type := ""   ## Tipo de tetrominó que depositó esta celda.

	func _init(t: String = "") -> void:
		type = t
		filled = t != ""

## ---- Composite: la pila como unidad ----
class Pile:
	extends RefCounted

	var rows: int
	var cols: int
	## grid[y][x] = Cell (y=0 es la fila superior del buffer).
	var grid: Array = []

	func _init(p_rows: int, p_cols: int) -> void:
		rows = p_rows
		cols = p_cols
		for y in range(rows):
			var row := []
			for x in range(cols):
				row.append(Cell.new())
			grid.append(row)

	## ¿La celda (x, y) está fuera del área jugable o ya ocupada?
	## x/y pueden ser negativos en y (arriba) y se tratan como libres.
	func blocks(x: int, y: int) -> bool:
		if x < 0 or x >= cols or y >= rows:
			return true           # paredes y suelo = bloqueado
		if y < 0:
			return false          # por encima del grid: libre
		return grid[y][x].filled

	## Fusiona las celdas de una pieza en la pila (la pieza "se posa").
	## Ignora celdas en filas y<0 (no deberían existir gracias al buffer).
	func merge_piece(cells: Array[Vector2i], type: String) -> void:
		for c in cells:
			if c.y >= 0 and c.y < rows and c.x >= 0 and c.x < cols:
				grid[c.y][c.x] = Cell.new(type)

	## ¿Está la fila y completamente ocupada? (unidad cohesiva)
	func is_row_full(y: int) -> bool:
		if y < 0 or y >= rows:
			return false
		for x in range(cols):
			if not grid[y][x].filled:
				return false
		return true

	## Todas las filas completas (puede haber varias a la vez).
	func full_rows() -> Array[int]:
		var out: Array[int] = []
		for y in range(rows):
			if is_row_full(y):
				out.append(y)
		return out

	## Elimina las filas indicadas y colapsa la pila hacia abajo.
	## Devuelve cuántas filas se han eliminado realmente.
	func remove_rows(rows_to_remove: Array[int]) -> int:
		if rows_to_remove.is_empty():
			return 0
		var kept: Array = []
		for y in range(rows):
			if y in rows_to_remove:
				continue
			kept.append(grid[y])
		# Rellena por arriba con filas vacías para mantener la altura.
		while kept.size() < rows:
			var empty_row := []
			for x in range(cols):
				empty_row.append(Cell.new())
			kept.push_front(empty_row)
		grid = kept
		return rows_to_remove.size()

	## Altura de la pila = filas desde la primera celda ocupada hasta el suelo.
	func height() -> int:
		for y in range(rows):
			for x in range(cols):
				if grid[y][x].filled:
					return rows - y
		return 0

	## ¿Hay alguna celda ocupada dentro de las `n` primeras filas (el buffer)?
	## Si la pila invade el buffer, la partida ha terminado.
	func invades_top(n: int) -> bool:
		for y in range(mini(n, rows)):
			for x in range(cols):
				if grid[y][x].filled:
					return true
		return false

	## Celda en (x, y) o null si está fuera de rango.
	func cell_at(x: int, y: int) -> Cell:
		if x < 0 or x >= cols or y < 0 or y >= rows:
			return null
		return grid[y][x]
