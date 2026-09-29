extends RefCounted
## Simulacion de Snake sobre rejilla de un nivel. No conoce el render: solo
## celdas. Un tick mueve la cabeza una celda y decide si come, crece o muere.
##
## El borde es una propiedad del nivel: atravesable (envuelve) o mortal
## (choca). Las celdas solidas del nivel (paredes y obstaculos) matan igual.

signal ate(score: int)
signal died(score: int)
signal level_completed(level_index: int)

const GridConfig = preload("res://scripts/logic/grid_config.gd")
const Levels = preload("res://scripts/logic/levels.gd")

## Todos los niveles arrancan al mismo intervalo: se reconoce el mapa con
## calma. La rampa por coco la aporta el nivel (`step`).
const BASE_TICK := 0.20
const MIN_TICK := 0.07
const START_LENGTH := 3

var level = null
var level_index := 0
var cells: Array[Vector2i] = []
var prev_cells: Array[Vector2i] = []
var direction := Vector2i.RIGHT
var food := Vector2i.ZERO
var score := 0
var level_eaten := 0
var alive := true
var finished := false
var rng := RandomNumberGenerator.new()

var _pending := Vector2i.ZERO


## Empieza la partida en el nivel indicado (por defecto, el primero).
func start(seed_value: int = 0, start_level: int = 0) -> void:
	if seed_value != 0:
		rng.seed = seed_value
	else:
		rng.randomize()
	score = 0
	finished = false
	load_level(start_level)


## Carga un nivel y reinicia su estado: cuerpo de 3 celdas en el inicio del
## nivel, direccion del nivel, velocidad base. La puntuacion NO se toca.
func load_level(index: int) -> void:
	level_index = index
	level = Levels.at(index)
	alive = true
	level_eaten = 0
	direction = level.start_dir
	_pending = Vector2i.ZERO
	cells = level.start_body()
	prev_cells = cells.duplicate()
	_spawn_food()


func set_direction(dir: Vector2i) -> void:
	if dir == Vector2i.ZERO:
		return
	var current := _pending if _pending != Vector2i.ZERO else direction
	if dir == current or dir == -current:
		return
	_pending = dir


## Intervalo actual: base menos la rampa del nivel por los cocos del nivel.
func current_interval() -> float:
	if level == null:
		return BASE_TICK
	return maxf(MIN_TICK, BASE_TICK - level.step * level_eaten)


func tick() -> void:
	if not alive or finished or level == null:
		return
	if _pending != Vector2i.ZERO:
		direction = _pending
		_pending = Vector2i.ZERO

	var raw := cells[0] + direction

	# Borde: en un nivel mortal, salir del tablero es chocar.
	if not level.in_bounds(raw):
		if level.border == level.BORDER_DEADLY:
			alive = false
			died.emit(score)
			return

	var new_head: Vector2i = level.wrapped(raw) if not level.in_bounds(raw) else raw

	var grew := new_head == food

	# Cuerpo tras liberar la cola: si come, la cola NO se libera (crece 1).
	var body: Array[Vector2i]
	if grew:
		body = cells.duplicate()
	else:
		body = cells.slice(0, cells.size() - 1)

	if body.has(new_head) or level.is_solid(new_head):
		alive = false
		died.emit(score)
		return

	prev_cells = cells.duplicate()
	var next_cells: Array[Vector2i] = [new_head]
	next_cells.append_array(body)
	cells = next_cells

	if grew:
		score += 1
		level_eaten += 1
		ate.emit(score)
		if level_eaten >= level.target:
			_finish_level()
			return
		_spawn_food()


func _finish_level() -> void:
	if level_index >= Levels.count() - 1:
		finished = true
		alive = false
		level_completed.emit(level_index)
		return
	load_level(level_index + 1)
	level_completed.emit(level_index - 1)


## El coco aparece entre las celdas alcanzables desde la cabeza: un bolsillo
## cerrado por muros nunca deja el nivel sin poder completarse.
func _spawn_food() -> void:
	var options: Array[Vector2i] = []
	for c in _reachable_cells():
		if c != cells[0]:
			options.append(c)
	if options.is_empty():
		return
	food = options[rng.randi_range(0, options.size() - 1)]


## Celdas transitables alcanzables desde la cabeza (BFS), sin contar solidas
## ni el cuerpo. Los bordes atravesables permiten pasar al lado opuesto.
func _reachable_cells() -> Array[Vector2i]:
	var occupied := {}
	for c in cells:
		occupied[c] = true

	var seen := {}
	var queue: Array[Vector2i] = [cells[0]]
	seen[cells[0]] = true
	var out: Array[Vector2i] = []

	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		out.append(c)
		for d in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			var raw: Vector2i = c + d
			if not level.is_free(raw):
				continue
			var n: Vector2i = level.wrapped(raw) if not level.in_bounds(raw) else raw
			if seen.has(n):
				continue
			if occupied.has(n):
				continue
			seen[n] = true
			queue.append(n)
	return out
