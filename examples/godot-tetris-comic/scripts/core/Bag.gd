## Bag.gd — Bolsa de 7: reparte una de cada tipo por ciclo, en orden aleatorio.
## Garantiza distribucion uniforme (no azar independiente por pieza).
class_name Bag
extends RefCounted

var _rng: RandomNumberGenerator
var _queue: Array[String] = []

func _init(rng: RandomNumberGenerator = null) -> void:
	_rng = rng if rng != null else RandomNumberGenerator.new()
	if rng == null:
		_rng.randomize()

## Saca la siguiente pieza. Si la bolsa se vacia, la rebaraja.
func next() -> String:
	if _queue.is_empty():
		_refill()
	return _queue.pop_front()

func _refill() -> void:
	_queue = Tetromino.TYPES.duplicate()
	for i in range(_queue.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp := _queue[i]
		_queue[i] = _queue[j]
		_queue[j] = tmp
