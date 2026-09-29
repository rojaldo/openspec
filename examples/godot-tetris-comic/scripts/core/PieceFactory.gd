## PieceFactory.gd — Unica puerta de entrada a la bolsa de 7.
## Fabrica piezas y anuncia la siguiente sin consumirla.
class_name PieceFactory
extends RefCounted

var _bag: Bag
var _next: String = ""

func _init(rng: RandomNumberGenerator = null) -> void:
	_bag = Bag.new(rng)
	_next = _bag.next()

## Tipo que se entregara en la proxima llamada a create().
func peek_next() -> String:
	return _next

## Fabrica la pieza anunciada y deja lista la siguiente.
func create(pos: Vector2i = Vector2i.ZERO) -> ActivePiece:
	var t := _next
	_next = _bag.next()
	return ActivePiece.new(t, pos)
