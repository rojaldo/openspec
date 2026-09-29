extends SceneTree
## Runner de tests headless: godot --headless -s tests/run_tests.gd
## Comprueba la logica pura (niveles, rejilla, render, scores) sin abrir el juego.

const GridConfig = preload("res://scripts/logic/grid_config.gd")
const Level = preload("res://scripts/logic/level.gd")
const Levels = preload("res://scripts/logic/levels.gd")
const SnakeGame = preload("res://scripts/logic/snake_game.gd")
const BoardRender = preload("res://scripts/logic/board_render.gd")
const Scores = preload("res://scripts/logic/scores.gd")
const PixelFont = preload("res://scripts/ui/pixel_font.gd")

var _failed := 0
var _passed := 0


func _init() -> void:
	_test_level_format()
	_test_levels_curve()
	_test_start_safety()
	_test_wrap_por_nivel()
	_test_solidos()
	_test_tick_advance()
	_test_direction()
	_test_food()
	_test_growth()
	_test_speed()
	_test_collision()
	_test_score()
	_test_level_progression()
	_test_render_math()
	_test_scores()
	_test_pixel_font()
	print("")
	print("RESULT: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		printerr("FAIL: " + label)


## 1.3 formato de un nivel
func _test_level_format() -> void:
	var lvl = Levels.at(0)
	check(lvl.format_problems().is_empty(), "el nivel 1 tiene formato valido")
	check(lvl.height == 20 and lvl.width == 20, "el nivel 1 es 20x20")
	check(lvl.start_head == Vector2i(10, 9), "el nivel 1 empieza en (10,9)")

	var malo = Level.new()
	malo.parse({
		"id": "malo",
		"border": "wrap",
		"target": 5,
		"dir": [1, 0],
		"map": ["@..@", ".."],
	}, 0)
	check(malo.format_problems().size() > 0, "un mapa mal formado se rechaza")


## 2.5 y 2.6 diez niveles, dificultad no decreciente y paso creciente
func _test_levels_curve() -> void:
	check(Levels.count() == 10, "hay exactamente diez niveles")
	var prev_solids := -1
	var prev_target := -1
	var prev_step := -1.0
	for i in Levels.count():
		var lvl = Levels.at(i)
		check(lvl.solid_count() >= prev_solids, "solidos no decrecen en el nivel %d" % (i + 1))
		check(lvl.target >= prev_target, "objetivo no decrece en el nivel %d" % (i + 1))
		check(lvl.step >= prev_step, "el paso de velocidad crece en el nivel %d" % (i + 1))
		prev_solids = lvl.solid_count()
		prev_target = lvl.target
		prev_step = lvl.step
	check(Levels.at(0).border == Level.BORDER_WRAP, "el nivel 1 usa borde atravesable")
	check(Levels.at(9).border == Level.BORDER_DEADLY, "el nivel 10 usa borde mortal")


## 2.6 invariante de inicio seguro en los diez niveles
func _test_start_safety() -> void:
	for i in Levels.count():
		var lvl = Levels.at(i)
		check(lvl.start_problems().is_empty(), "inicio seguro en el nivel %d" % (i + 1))
		check(not lvl.is_solid(lvl.start_head), "cabeza inicial libre en el nivel %d" % (i + 1))
		check(lvl.is_free(lvl.start_head + lvl.start_dir), "frente libre en el nivel %d" % (i + 1))


## 3.3 borde como propiedad del nivel
func _test_wrap_por_nivel() -> void:
	var g = SnakeGame.new()
	g.start(11, 0)
	check(g.level.border == Level.BORDER_WRAP, "el nivel 1 es atravesable")
	g.cells = [Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5)] as Array[Vector2i]
	g.direction = Vector2i.LEFT
	g.tick()
	check(g.cells[0] == Vector2i(g.level.width - 1, 5), "en wrap la cabeza entra por el lado opuesto")
	check(g.alive, "el wrap no mata")

	g.start(11, 4)
	check(g.level.border == Level.BORDER_DEADLY, "el nivel 5 es mortal")
	g.cells = [Vector2i(g.level.width - 1, 5)] as Array[Vector2i]
	g.direction = Vector2i.RIGHT
	g.tick()
	check(not g.alive, "el borde mortal mata")


## 3.2 colision con celdas solidas
func _test_solidos() -> void:
	var g = SnakeGame.new()
	g.start(11, 4)
	var sol: Vector2i = g.level.solids.keys()[0]
	check(g.level.is_solid(sol), "la celda del mapa es solida")
	g.cells = [sol - Vector2i.RIGHT, sol - Vector2i.RIGHT * 2] as Array[Vector2i]
	g.direction = Vector2i.RIGHT
	g.tick()
	check(not g.alive, "entrar en una celda solida mata")


## 3.4 la cabeza avanza una celda por tick
func _test_tick_advance() -> void:
	var g = SnakeGame.new()
	g.start(1234, 0)
	var head_before: Vector2i = g.cells[0]
	g.tick()
	check(g.cells[0] == head_before + Vector2i.RIGHT, "avance de una celda por tick")
	check(absi(g.cells[0].x - head_before.x) + absi(g.cells[0].y - head_before.y) == 1, "distancia Manhattan de 1")


## control de direccion
func _test_direction() -> void:
	var g = SnakeGame.new()
	g.start(1, 0)
	g.set_direction(Vector2i.LEFT)
	g.tick()
	check(g.direction == Vector2i.RIGHT, "giro de 180 grados ignorado")

	var g2 = SnakeGame.new()
	g2.start(1, 0)
	g2.set_direction(Vector2i.UP)
	g2.tick()
	check(g2.direction == Vector2i.UP, "cambio de direccion valido aplicado")

	var g3 = SnakeGame.new()
	g3.start(1, 0)
	g3.set_direction(Vector2i.UP)
	g3.set_direction(Vector2i.LEFT)
	g3.tick()
	check(g3.direction == Vector2i.LEFT, "la ultima intencion antes del tick es la que aplica")


## 3.6 la comida nunca cae en una celda solida, el cuerpo ni un bolsillo sellado
func _test_food() -> void:
	for idx in [0, 4, 9]:
		var g = SnakeGame.new()
		g.start(99, idx)
		for i in 60:
			check(not g.cells.has(g.food), "coco fuera del cuerpo (nivel %d iter %d)" % [idx + 1, i])
			check(not g.level.is_solid(g.food), "coco fuera de solida (nivel %d iter %d)" % [idx + 1, i])
			g.tick()
			if not g.alive:
				break

	# Bolsillo de 2x2 sellado por muros: el coco nunca debe caer dentro.
	var p = SnakeGame.new()
	p.level = Level.new()
	p.level.parse({
		"id": "bolsillo", "border": "wrap", "target": 5, "dir": [1, 0],
		"map": [
			"..........",
			"..........",
			"..####....",
			"..#..#....",
			"..#..#....",
			"..####....",
			"..........",
			"..........",
			"..........",
			"....@.....",
		],
	}, 0)
	p.alive = true
	p.cells = p.level.start_body()
	var pocket := [Vector2i(3, 3), Vector2i(4, 3), Vector2i(3, 4), Vector2i(4, 4)]
	var inside := 0
	for i in 100:
		p._spawn_food()
		if pocket.has(p.food):
			inside += 1
	check(inside == 0, "el coco nunca aparece dentro de un bolsillo sellado")


## crecimiento = no liberar la cola
func _test_growth() -> void:
	var g = SnakeGame.new()
	g.start(7, 0)
	var head: Vector2i = g.cells[0]
	g.food = head + g.direction
	var tail_before: Vector2i = g.cells[g.cells.size() - 1]
	var len_before: int = g.cells.size()
	g.tick()
	check(g.cells.size() == len_before + 1, "longitud aumenta exactamente una celda")
	check(g.cells.has(tail_before), "la cola no se libera el tick de comer")

	var g2 = SnakeGame.new()
	g2.start(7, 0)
	var len2: int = g2.cells.size()
	g2.tick()
	check(g2.cells.size() == len2, "sin comer, la longitud no cambia")


## 3.7 velocidad: base uniforme y rampa por nivel
func _test_speed() -> void:
	var g1 = SnakeGame.new()
	g1.start(5, 0)
	var g10 = SnakeGame.new()
	g10.start(5, 9)
	check(is_equal_approx(g1.current_interval(), g10.current_interval()), "los dos niveles arrancan a la misma velocidad")

	var before := g1.current_interval()
	g1.food = g1.cells[0] + g1.direction
	g1.tick()
	check(g1.current_interval() < before, "comer reduce el intervalo")

	var a = SnakeGame.new()
	a.start(5, 0)
	var a_before := a.current_interval()
	a.food = a.cells[0] + a.direction
	a.tick()
	var drop_n1: float = a_before - a.current_interval()

	var b = SnakeGame.new()
	b.start(5, 9)
	var b_before := b.current_interval()
	b.food = b.cells[0] + b.direction
	b.tick()
	var drop_n10: float = b_before - b.current_interval()
	check(drop_n10 > drop_n1, "comer en el nivel 10 acelera mas que en el 1")

	var gmin = SnakeGame.new()
	gmin.start(5, 9)
	gmin.level_eaten = 10000
	check(is_equal_approx(gmin.current_interval(), SnakeGame.MIN_TICK), "el intervalo no baja del minimo")


## fin de partida por auto-colision
func _test_collision() -> void:
	var g = SnakeGame.new()
	g.start(3, 0)
	g.cells = [Vector2i(5, 5), Vector2i(4, 5), Vector2i(4, 4), Vector2i(5, 4), Vector2i(5, 3)] as Array[Vector2i]
	g.direction = Vector2i.UP
	g.food = Vector2i(17, 17)
	g.tick()
	check(g.alive == false, "chocar contra el cuerpo mata")

	var g2 = SnakeGame.new()
	g2.start(3, 0)
	g2.cells = [Vector2i(5, 5), Vector2i(5, 6), Vector2i(6, 6), Vector2i(6, 5)] as Array[Vector2i]
	g2.direction = Vector2i.RIGHT
	g2.food = Vector2i(17, 17)
	g2.tick()
	check(g2.alive == true, "entrar en la celda que libera la cola es legal")


## 3.5 puntuacion acumulada
func _test_score() -> void:
	var g = SnakeGame.new()
	g.start(11, 0)
	check(g.score == 0, "puntuacion inicial a cero")
	check(g.level_eaten == 0, "progreso del nivel inicial a cero")
	var target: int = g.level.target
	for i in target:
		g.food = g.cells[0] + g.direction
		g.tick()
	check(g.score == target, "puntuacion igual a cocos comidos")


## 3.8 avance de nivel con reinicio de estado
func _test_level_progression() -> void:
	var g = SnakeGame.new()
	g.start(11, 0)
	var target: int = g.level.target
	for i in target:
		g.food = g.cells[0] + g.direction
		g.tick()
	check(g.level_index == 1, "al completar el objetivo se pasa al nivel siguiente")
	check(g.cells.size() == 3, "la serpiente reinicia a 3 celdas en el nivel nuevo")
	check(g.level_eaten == 0, "el progreso del nivel nuevo empieza a cero")
	check(g.score == target, "la puntuacion acumulada se conserva")
	check(is_equal_approx(g.current_interval(), SnakeGame.BASE_TICK), "la velocidad vuelve al intervalo base")
	check(g.cells == g.level.start_body(), "el cuerpo arranca en el inicio del nivel")


## matematica de interpolacion
func _test_render_math() -> void:
	var mid := BoardRender.segment_positions(Vector2i(4, 5), Vector2i(5, 5), 0.5)
	check(mid.size() == 1 and mid[0].is_equal_approx(Vector2(4.5, 5.0)), "a mitad de tick, a mitad de camino")

	var end := BoardRender.segment_positions(Vector2i(4, 5), Vector2i(5, 5), 1.0)
	check(end.size() == 1 and end[0].is_equal_approx(Vector2(5.0, 5.0)), "al final del intervalo, sobre su celda")

	var ghost := BoardRender.segment_positions(Vector2i(0, 5), Vector2i(19, 5), 0.5)
	check(ghost.size() == 2, "un cruce de borde se dibuja dos veces")
	check(ghost[0].x < 0.0, "la parte que sale queda fuera por la izquierda")
	check(ghost[1].x > 19.0, "la parte que entra llega desde fuera por la derecha")

	var single := BoardRender.segment_positions(Vector2i(2, 2), Vector2i(2, 3), 0.3)
	check(single.size() == 1, "sin cruce, una sola posicion")

	var body := BoardRender.snake_positions(
		[Vector2i(3, 4), Vector2i(2, 4)],
		[Vector2i(4, 4), Vector2i(3, 4)],
		0.5
	)
	check(body.size() == 2, "una entrada por segmento del cuerpo")


## 6.1 y 6.2 persistencia, orden, limite, nivel y compatibilidad
func _test_scores() -> void:
	var path := "user://test_scores_%d.json" % Time.get_ticks_usec()
	var s := Scores.new(path)
	check(s.load_entries().is_empty(), "archivo ausente -> tabla vacia")

	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("{ esto no es json valido")
	f.close()
	check(s.load_entries().is_empty(), "archivo invalido -> tabla vacia")

	# Entrada antigua sin campo nivel: se lee sin error.
	var f2 := FileAccess.open(path, FileAccess.WRITE)
	f2.store_string('[{"id":1,"name":"VIEJO","score":3}]')
	f2.close()
	var old := s.load_entries()
	check(old.size() == 1, "una entrada antigua sin nivel se lee")
	check(int(old[0].get("level", -1)) == 0, "la entrada antigua recibe nivel por defecto")

	DirAccess.remove_absolute(path)
	var s2 := Scores.new(path)
	s2.submit("ANA", 5, 3)
	s2.submit("", 9, 7)
	var entries := s2.load_entries()
	check(entries.size() == 2, "se registran las dos partidas")
	check(int(entries[0]["score"]) == 9, "orden descendente por puntuacion")
	check(int(entries[0]["level"]) == 7, "el nivel alcanzado se guarda")
	check(str(entries[1]["name"]) == "ANA", "nombre introducido se conserva")
	check(str(entries[0]["name"]) == Scores.DEFAULT_NAME, "nombre vacio usa el por defecto")

	for i in 20:
		s2.submit("P%d" % i, i, 1)
	var top := s2.load_entries()
	check(top.size() == Scores.MAX_ENTRIES, "la tabla se recorta al maximo")
	check(int(top[0]["score"]) >= int(top[top.size() - 1]["score"]), "sigue ordenada tras el recorte")

	DirAccess.remove_absolute(path)


## la fuente de pixeles es codigo del proyecto
func _test_pixel_font() -> void:
	var font := PixelFont.get_font()
	check(font != null, "la fuente de pixeles se construye")
	for ch in ["A", "Z", "a", "z", "0", "9", "Ñ", "ñ", "Á", "á", "Ó", "ó"]:
		check(font.has_char(ch.unicode_at(0)), "la fuente dibuja '%s'" % ch)
	for text in ["NIVEL 1/10", "COCOS 0/5", "VICTORIA! PUNTOS: 42"]:
		var size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24)
		check(size.x > 0.0 and size.y > 0.0, "la fuente mide '%s'" % text)
	check(font.get_antialiasing() == TextServer.FONT_ANTIALIASING_NONE, "la fuente es bitmap, sin suavizado")
