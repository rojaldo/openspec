## InputRouter.gd — Traduce teclas a ordenes del juego, con auto-repeat.
## Solo actua cuando PlayScreen le confirma que la partida esta activa.
class_name InputRouter
extends Node

const MOVE_DELAY := 0.17
const MOVE_REPEAT := 0.05
const SOFT_REPEAT := 0.05

var activo := false
var target: Node = null

var _move_dir := 0
var _move_timer := 0.0
var _soft_held := false
var _soft_timer := 0.0

func _process(delta: float) -> void:
	if not activo or target == null or not is_instance_valid(target):
		return
	if _move_dir != 0:
		_move_timer -= delta
		if _move_timer <= 0.0:
			target.move_active(_move_dir)
			_move_timer = MOVE_REPEAT
	if _soft_held:
		_soft_timer -= delta
		if _soft_timer <= 0.0:
			target.soft_drop()
			_soft_timer = SOFT_REPEAT

func _unhandled_input(event: InputEvent) -> void:
	if not activo or target == null or not is_instance_valid(target):
		return
	if event is InputEventKey:
		_handle_key(event)

func _handle_key(event: InputEventKey) -> void:
	if event.echo:
		return
	match event.keycode:
		KEY_LEFT:
			if event.pressed:
				target.move_active(-1)
				_move_dir = -1
				_move_timer = MOVE_DELAY
			elif _move_dir == -1:
				_stop_move()
		KEY_RIGHT:
			if event.pressed:
				target.move_active(1)
				_move_dir = 1
				_move_timer = MOVE_DELAY
			elif _move_dir == 1:
				_stop_move()
		KEY_DOWN:
			if event.pressed:
				target.soft_drop()
				_soft_held = true
				_soft_timer = SOFT_REPEAT
			else:
				_soft_held = false
		KEY_SPACE, KEY_UP:
			if event.pressed:
				target.rotate_active()

func _stop_move() -> void:
	_move_dir = 0
	_move_timer = 0.0

## Corta cualquier estado de teclas al salir de la partida.
func reset() -> void:
	_stop_move()
	_soft_held = false
	_soft_timer = 0.0
