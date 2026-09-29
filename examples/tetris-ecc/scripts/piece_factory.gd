## piece_factory.gd — PATRÓN 1: FACTORY (creador de piezas).
##
## Responsabilidad ÚNICA e intransferible:
##   "Crea las piezas. Concretamente, elige la siguiente pieza a caer entre las
##    7 disponibles."
##
## Qué hace: toma el tipo que decide el Orbol y CONSTRUYE el producto `Piece`
## (tipo + matriz + posición de spawn). El resto del juego nunca hace
## `Tetromino.shape(...)` para una pieza nueva: siempre pasa por aquí. Así, si
## mañana cambia la forma de spawn o se añade una pieza, solo se toca este sitio.
class_name PieceFactory
extends RefCounted

const BUFFER_ROWS := 2   ## Buffer de seguridad: 2 filas invisibles arriba.
const COLS := 10

var _orbol: Orbol
var _spawn_index := 0    ## Contador interno para repartir el spawn en columnas.

func _init(orbol: Orbol) -> void:
	_orbol = orbol

## Crea la siguiente pieza: pide el tipo al Orbol (patrón 5) y la materializa.
func create_next() -> Piece:
	var type := _orbol.draw()
	return _make(type)

## Construye el producto Piece para un tipo concreto (usado también por tests).
func _make(type: String) -> Piece:
	var piece := Piece.new()
	piece.type = type
	piece.matrix = Tetromino.shape(type)
	# Spawn: centrado horizontalmente, en la primera fila VISIBLE (y=BUFFER).
	# El buffer de 2 filas queda por encima y lo usan los "wall kicks" al rotar,
	# de modo que una pieza nunca puede salir por arriba del tablero.
	var w: int = piece.matrix[0].size()
	piece.pos = Vector2i((COLS - w) / 2, BUFFER_ROWS)
	_spawn_index += 1
	return piece
