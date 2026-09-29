## game_flow.gd — Gobernanza pura del juego (T3). NO es un patrón: es el
## composition root que compone los 6 patrones + el FSM (patrón 7).
##
## Por qué existe: para que "el juego está gobernado por la Máquina de Estados"
## sea una propiedad PROBADA de un objeto real (RefCounted puro, sin escena), y
## no solo el comportamiento de un handler. El controlador (Node) queda como
## adaptador fino: traduce input -> métodos de este objeto.
##
## Es puro: no usa Input, ni _process, ni árbol de escena. El estado del teclado
## se le pasa: tick(delta, soft_drop_held).
##
## Responsabilidades:
##  - Ser el ÚNICO dueño del estado del juego (FSM autoritativo, A2). El modelo
##    NO guarda flag de fin de partida: cuando la pila desborda emite `game_over`
##    y este objeto transiciona a GAME_OVER.
##  - Construir la partida (Orbol/Factory/Builder/Composite/Observer/Command)
##    SOLO al entrar en PLAYING (START es realmente inerte).
##  - Reconstruir una partida limpia en cada entrada a PLAYING (reinicio real:
##    tablero Y marcador a cero).
class_name GameFlow
extends RefCounted

## Reemisión para el adaptador (Node). `state_changed` viene del FSM.
signal state_changed(from: int, to: int)
signal lines_cleared(count: int, is_tetris: bool)

const SOFT_DROP_INTERVAL := 0.05

var fsm: GameStateMachine
var model: BoardModel = null
var score_observer: ScoreObserver = null

var _canvas: Object = null                 ## Receptor del Command (HUD).
var _line_observers: Array = []            ## Observadores extra (HUD).
var _gravity_accum := 0.0

func _init() -> void:
	fsm = GameStateMachine.new()
	fsm.state_changed.connect(_on_fsm_state_changed)

## Estado actual del juego (autoridad única).
func state() -> int:
	return fsm.current

# ------------------------------------------------------------- COMMAND / OBS
## Seam del patrón Command: el "canvas" receptor de la pieza siguiente.
func attach_canvas(canvas: Object) -> void:
	_canvas = canvas
	if model != null:
		model.attach_canvas(canvas)

## Seam del patrón Observer: observadores que quieren los avisos de línea.
func attach_lines_observer(observer: Object) -> void:
	if observer != null and not _line_observers.has(observer):
		_line_observers.append(observer)
	if model != null and model.subject != null:
		model.subject.attach(observer)

# ------------------------------------------------------------------- FLUJO
## START -> PLAYING (o GAME_OVER -> PLAYING). En ambos casos: partida nueva.
func press_start() -> bool:
	return fsm.transition_to(GameStateMachine.State.PLAYING)

## GAME_OVER -> START (volver al título).
func return_to_title() -> bool:
	return fsm.transition_to(GameStateMachine.State.START)

## Acciones de juego (solo válidas en PLAYING; en otro estado son no-op).
func move(dx: int) -> bool:
	return model.try_move(dx, 0) if _playing() else false

func rotate() -> bool:
	return model.try_rotate(true) if _playing() else false

func hard_drop() -> bool:
	if not _playing():
		return false
	model.hard_drop()
	return true

## Un tick de simulación. `soft_drop_held` lo pasa el adaptador (la vista).
## Devuelve true si la pieza se movió/aterrizó. Inerte fuera de PLAYING.
func tick(delta: float, soft_drop_held: bool) -> bool:
	if not _playing():
		return false
	var interval := SOFT_DROP_INTERVAL if soft_drop_held else _level_interval()
	_gravity_accum += delta
	if _gravity_accum < interval:
		return false
	_gravity_accum = 0.0
	model.step()
	return true

func _playing() -> bool:
	return fsm.current == GameStateMachine.State.PLAYING and model != null and model.active != null

## Intervalo de gravedad según el nivel actual (baja con el nivel).
func _level_interval() -> float:
	if score_observer == null:
		return 0.8
	return maxf(0.12, 0.8 - 0.06 * (score_observer.level - 1))

# ------------------------------------------------------------------ INTERNO
func _on_fsm_state_changed(from: int, to: int) -> void:
	match to:
		GameStateMachine.State.PLAYING:
			_start_new_game()
		GameStateMachine.State.START:
			_release_game()
		GameStateMachine.State.GAME_OVER:
			pass  # la presentación la hace la vista reaccionando a state_changed
	state_changed.emit(from, to)

## Construye una partida COMPLETA y limpia (6 patrones + observadores).
func _start_new_game() -> void:
	_gravity_accum = 0.0
	var orbol := Orbol.new()                              # [5] ORBOL
	var factory := PieceFactory.new(orbol)                # [1] FACTORY
	var builder := LineBuilder.new()                      # [3] BUILDER
	var subject := LineSubject.new()                      # [4] OBSERVER (sujeto)
	score_observer = ScoreObserver.new()                  # [4] OBSERVER (score)
	subject.attach(score_observer)
	for o in _line_observers:
		subject.attach(o)

	model = BoardModel.new(factory, builder, subject)
	model.score_observer = score_observer
	model.game_over.connect(_on_model_game_over)
	model.lines_cleared.connect(_on_model_lines_cleared)

	# [6] COMMAND: informa al canvas antes de start() para que la PRIMERA pieza
	# también se comunique (start() ejecuta el comando). Una sola vez basta.
	model.attach_canvas(_canvas)
	# Arranca la partida dentro del modelo (Orbol->Factory->Command...).
	model.start()

## Suelta la partida al volver al título.
func _release_game() -> void:
	model = null
	score_observer = null
	_gravity_accum = 0.0

## El modelo detecta el fin de partida y avisa; el FSM (autoridad) transiciona.
func _on_model_game_over() -> void:
	fsm.transition_to(GameStateMachine.State.GAME_OVER)

func _on_model_lines_cleared(count: int, is_tetris: bool) -> void:
	lines_cleared.emit(count, is_tetris)
