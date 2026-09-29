extends SceneTree
## 8.4 Encadena los diez niveles hasta la victoria y comprueba que la
## progresion se completa y que el final es victoria.
##   godot --headless -s tests/run_all_levels.gd
##
## En cada nivel se deja el objetivo a un coco y se come ese ultimo coco,
## que es lo que dispara el paso de nivel. Asi se verifica la cadena entera
## de forma determinista, sin depender de un bot que navegue el mapa.

const SnakeGame = preload("res://scripts/logic/snake_game.gd")
const Levels = preload("res://scripts/logic/levels.gd")

var _failed := 0
var _passed := 0

func _initialize() -> void: _run()

func check(c: bool, label: String) -> void:
	if c: _passed += 1
	else:
		_failed += 1
		printerr("FAIL: " + label)

func _run() -> void:
	var g = SnakeGame.new()
	g.start(7, 0)

	for i in Levels.count():
		check(g.level_index == i, "la partida esta en el nivel %d" % (i + 1))
		check(g.cells.size() == 3, "nivel %d: la serpiente mide 3 celdas al empezar" % (i + 1))
		check(g.direction == g.level.start_dir, "nivel %d: la direccion es la del nivel" % (i + 1))

		# El ultimo coco del objetivo, delante de la cabeza (invariante de inicio).
		var last_food: Vector2i = g.cells[0] + g.direction
		check(g.level.is_free(last_food), "nivel %d: el coco final cabe delante" % (i + 1))
		g.level_eaten = g.level.target - 1
		g.food = last_food
		var before: int = g.level_index
		g.tick()

		if i < Levels.count() - 1:
			check(g.alive, "nivel %d: superarlo no mata" % (i + 1))
			check(g.level_index == before + 1, "nivel %d: se pasa al siguiente" % (i + 1))
		else:
			check(g.finished, "nivel 10: completarlo marca la partida como terminada")
			check(not g.alive, "nivel 10: la partida termina")

	# Cada nivel aporta un coco (el ultimo de su objetivo): el score acumula.
	check(g.score == Levels.count(), "el score acumula un coco por nivel completado (score=%d)" % g.score)

	print("")
	print("ALL LEVELS: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
