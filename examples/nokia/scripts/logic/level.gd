extends RefCounted
## Un nivel: su mapa, el comportamiento de su borde, su inicio, su objetivo
## de cocos y su rampa de velocidad. Los mapas son texto:
##   '.' celda libre   '#' celda solida (pared u obstaculo)   '@' inicio
## En un nivel de borde mortal el anillo exterior se anade solo.

const FREE := "."
const SOLID := "#"
const START := "@"

const BORDER_WRAP := "wrap"
const BORDER_DEADLY := "deadly"

const DEFAULT_TARGET := 5
const DEFAULT_STEP := 0.004


## Devuelve la celda equivalente envolviendo por los bordes.
## (No se llama `wrap` para no chocar con la funcion global de GDScript.)
func wrapped(c: Vector2i) -> Vector2i:
	return Vector2i(posmod(c.x, width), posmod(c.y, height))


func in_bounds(c: Vector2i) -> bool:
	return c.x >= 0 and c.x < width and c.y >= 0 and c.y < height


func is_solid(c: Vector2i) -> bool:
	return solids.has(c)


## Una celda es libre si no es solida. Fuera del tablero: en un nivel mortal
## no es libre (es el muro) y en uno atravesable se envuelve.
func is_free(raw: Vector2i) -> bool:
	var c := raw
	if not in_bounds(c):
		if border == BORDER_DEADLY:
			return false
		c = wrapped(c)
	return not solids.has(c)


func parse(data: Dictionary, level_index: int) -> void:
	index = level_index
	id = str(data.get("id", "nivel-%d" % (level_index + 1)))
	_rows = data.get("map", [])
	border = str(data.get("border", BORDER_WRAP))
	var d = data.get("dir", [1, 0])
	start_dir = Vector2i(int(d[0]), int(d[1]))
	target = int(data.get("target", DEFAULT_TARGET))
	step = float(data.get("step", DEFAULT_STEP))

	height = _rows.size()
	width = _rows[0].length() if height > 0 else 0

	solids.clear()
	for y in height:
		var row: String = _rows[y]
		for x in row.length():
			var ch := row[x]
			if ch == SOLID:
				solids[Vector2i(x, y)] = true
			elif ch == START:
				start_head = Vector2i(x, y)

	if border == BORDER_DEADLY:
		_add_ring()


## En un nivel mortal el anillo exterior es muro: no hace falta escribirlo.
func _add_ring() -> void:
	for x in width:
		solids[Vector2i(x, 0)] = true
		solids[Vector2i(x, height - 1)] = true
	for y in height:
		solids[Vector2i(0, y)] = true
		solids[Vector2i(width - 1, y)] = true


## Problemas de formato del mapa (filas, inicio, objetivo).
func format_problems() -> Array:
	var problems: Array = []
	if height == 0:
		problems.append("mapa vacio")
		return problems
	for y in height:
		var row: String = _rows[y]
		if row.length() != width:
			problems.append("fila %d mide %d, esperado %d" % [y, row.length(), width])
	var starts := 0
	for y in height:
		var row: String = _rows[y]
		for x in row.length():
			if row[x] == START:
				starts += 1
	if starts != 1:
		problems.append("numero de inicios: %d (esperado 1)" % starts)
	if target < 1:
		problems.append("objetivo invalido: %d" % target)
	return problems


## Invariante de inicio seguro: cuerpo libre, frente libre y escape.
func start_problems() -> Array:
	var problems: Array = []
	var body := [start_head, start_head - start_dir, start_head - start_dir * 2]
	for c in body:
		if not in_bounds(c) or is_solid(c):
			problems.append("cuerpo inicial en celda no libre: %s" % str(c))
	if not is_free(start_head + start_dir):
		problems.append("frente a la cabeza bloqueado")
	var perp := Vector2i(-start_dir.y, start_dir.x)
	var escape := false
	for d in [perp, -perp]:
		var c: Vector2i = start_head + d
		if in_bounds(c) and not is_solid(c):
			escape = true
	if not escape:
		problems.append("sin escape perpendicular")
	return problems


func solid_count() -> int:
	return solids.size()


func start_body() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for i in 3:
		out.append(start_head - start_dir * i)
	return out


var id := ""
var index := 0
var width := 0
var height := 0
var border := BORDER_WRAP
var start_head := Vector2i.ZERO
var start_dir := Vector2i.RIGHT
var target := DEFAULT_TARGET
var step := DEFAULT_STEP
var solids := {}

var _rows: Array = []
