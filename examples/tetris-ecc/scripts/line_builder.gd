## line_builder.gd — PATRÓN 3: BUILDER (detección y eliminación de filas).
##
## Responsabilidad ÚNICA e intransferible:
##   "Calcula si se ha formado una fila nueva y, en ese caso, elimina la o las
##    filas completas."
##
## El Builder es el único sitio que decide qué filas desaparecen y cómo colapsa
## la pila tras el borrado. Trabaja SOBRE el composite (Pile) como unidad. No sabe
## nada de puntuación: solo devuelve cuántas filas eliminó (patrón 4 reacciona).
class_name LineBuilder
extends RefCounted

## "Calcula si se ha formado una fila nueva y las elimina."
## Devuelve el número de filas eliminadas (0 si no había ninguna completa).
## `is_tetris` se decide aquí (4 filas de golpe) y se expone como último cálculo.
var last_was_tetris := false

func process_rows(pile: CompositePile.Pile) -> int:
	var full := pile.full_rows()
	last_was_tetris = full.size() >= 4
	return pile.remove_rows(full)
