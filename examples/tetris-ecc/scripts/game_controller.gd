## game_controller.gd — ADAPTADOR FINO (T3).
##
## Ya no gobierna el juego: toda la gobernanza vive en `GameFlow` (RefCounted
## puro, testeable). Este nodo solo traduce el mundo del motor (input, frames,
## nodos) a llamadas sobre `GameFlow`, y refleja el estado en la vista.
##
## Flujo del enunciado, ahora gobernado por el FSM (patrón 7):
##   1-3. Orbol -> Factory -> Command  (dentro de GameFlow al entrar en PLAYING)
##   4.   Composite (la pieza se funde en la pila)
##   5.   Builder (detecta/elimina filas)
##   6.   Observer (score/líneas)
##   7.   siguiente pieza
##   8.   fin de partida -> el modelo avisa, el FSM pasa a GAME_OVER
extends Node2D

var flow: GameFlow
var view: BoardView
var hud: ComicHud
var sfx: SfxPopup

func _ready() -> void:
	view = $BoardView as BoardView
	hud = $Hud as ComicHud
	sfx = $SfxLayer as SfxPopup

	# GameFlow compone los 6 patrones + el FSM. Este adaptador solo lo alimenta.
	flow = GameFlow.new()
	# Seams: el HUD es el "canvas" del Command y además un Observer (patrón 4).
	flow.attach_canvas(hud)
	flow.attach_lines_observer(hud)
	flow.state_changed.connect(_on_flow_state_changed)
	flow.lines_cleared.connect(_on_flow_lines_cleared)

	# El tablero se coloca desde las constantes del HUD (única fuente de verdad):
	# así no hay literales sueltos en la escena que puedan desalinearse.
	view.position = Vector2(ComicHud.BOARD_X, ComicHud.BOARD_TOP)

	# Estado inicial: pantalla de título. El juego aún no existe (START inerte).
	_apply_state(flow.state())

func _process(delta: float) -> void:
	# La vista informa si se mantiene ↓; el GameFlow decide qué hacer.
	flow.tick(delta, Input.is_action_pressed("ui_down"))

func _unhandled_input(event: InputEvent) -> void:
	# Teclas separadas (I3): `start` (Enter) arranca/reinicia; Espacio = hard drop.
	match flow.state():
		GameStateMachine.State.START:
			# Menú: ↑/↓ mueve la selección; Enter ejecuta la opción.
			if event.is_action_pressed("ui_up"):
				hud.menu_move(-1)
			elif event.is_action_pressed("ui_down"):
				hud.menu_move(1)
			elif _is_press(event, "start"):
				if hud.menu_index() == 1:   # SALIR
					get_tree().quit()
				else:                        # JUGAR
					flow.press_start()
		GameStateMachine.State.GAME_OVER:
			if event.is_action_pressed("ui_up"):
				hud.menu_move(-1)
			elif event.is_action_pressed("ui_down"):
				hud.menu_move(1)
			elif _is_press(event, "start"):
				if hud.menu_index() == 1:   # TÍTULO
					flow.return_to_title()
				else:                        # REINTENTAR
					flow.press_start()
			elif event.is_action_pressed("ui_cancel"):
				flow.return_to_title()
		GameStateMachine.State.PLAYING:
			if event.is_action_pressed("ui_left"):
				flow.move(-1)
			elif event.is_action_pressed("ui_right"):
				flow.move(1)
			elif event.is_action_pressed("ui_up"):
				flow.rotate()
			elif event.is_action_pressed("ui_accept"):
				flow.hard_drop()

## Pulsación real (ignora el "echo" de una tecla mantenida -> evita repetir).
func _is_press(event: InputEvent, action: String) -> bool:
	if event is InputEventKey and event.is_echo():
		return false
	return event.is_action_pressed(action)

## Refleja el estado del FSM en la vista (pantallas + gate del tablero, S1).
func _on_flow_state_changed(_from: int, to: int) -> void:
	_apply_state(to)

func _apply_state(state: int) -> void:
	match state:
		GameStateMachine.State.START:
			hud.model = null
			hud.show_title()
			view.show_board = false
			view.model = null
		GameStateMachine.State.PLAYING:
			view.model = flow.model
			view.show_board = true
			# El tablero se redibuja con cada cambio del modelo (movimiento,
			# gravedad, aterrizaje). Regresión resuelta: la conexión se hace por
			# partida; muere con el modelo al reconstruirse.
			if not flow.model.state_changed.is_connected(view.queue_redraw):
				flow.model.state_changed.connect(view.queue_redraw)
			hud.model = flow.model
			hud.show_gameplay()
			hud.refresh()
		GameStateMachine.State.GAME_OVER:
			# Tablero muerto visible bajo la explosión (S1); cartel persistente (G1).
			view.show_board = true
			hud.show_game_over()
			sfx.pop("boom", Vector2(160, 300))
	view.queue_redraw()

## Efectos visuales de la línea eliminada (el score ya lo subió ScoreObserver).
func _on_flow_lines_cleared(count: int, is_tetris: bool) -> void:
	if is_tetris:
		sfx.pop("tetris", Vector2(160, 300))
		hud.flash_banner("tetris")
	elif count > 0:
		sfx.pop("random", Vector2(160, 300))
	hud.refresh()
