## game_state_machine.gd — PATRÓN 7: STATE (Máquina de Estados Finitos).
##
## Responsabilidad ÚNICA e intransferible:
##   Gobernar el ciclo de vida del juego con tres estados — START (pantalla
##   inicial), PLAYING (partida) y GAME_OVER — validando las transiciones contra
##   una tabla explícita y notificando los cambios.
##
## Es un patrón DELIBERADO y añadido (el enunciado pedía 6 patrones; este 7º se
## añade por requisito explícito del usuario: "el juego debe estar gobernado por
## la Máquina de Estados"). Se documenta como "Pattern 7 — State (FSM)".
##
## Es lógica PURA (RefCounted): sin árbol de escena, sin _process, sin @export.
## Eso es lo que permite probarla de forma aislada en tests/fsm_test.gd.
##
## Nota: `state_changed` es una señal de Godot, NO el patrón Observer. El patrón
## Observer sigue siendo exclusivamente LineSubject -> ScoreObserver/HUD.
class_name GameStateMachine
extends RefCounted

enum State { START, PLAYING, GAME_OVER }

## Tabla de transiciones permitidas (la "variable que gobierna" el FSM).
## - START     -> PLAYING            (el jugador pulsa Enter)
## - PLAYING   -> GAME_OVER          (la pila invade el buffer)
## - GAME_OVER -> PLAYING            (reiniciar)
## - GAME_OVER -> START              (volver al título, Esc)
## Lo no listado es ilegal: p.ej. PLAYING -> START (no se aborta a mitad) y
## START -> GAME_OVER.
const ALLOWED := {
	State.START: [State.PLAYING],
	State.PLAYING: [State.GAME_OVER],
	State.GAME_OVER: [State.PLAYING, State.START],
}

## Estado actual que gobierna el juego.
var current: State = State.START

## Emitidas al completar una transición legal.
signal state_changed(from: State, to: State)
## Hooks enter/exit: efecto real de la transición (seam de extensión).
signal state_entered(state: State)
signal state_exited(state: State)

## ¿Es legal ir de `current` a `next`? No muta el estado.
func can_transition_to(next: State) -> bool:
	var allowed: Array = ALLOWED.get(current, [])
	return allowed.has(next)

## Intenta transicionar. Devuelve true solo si hubo cambio real.
## - Mismo estado  -> false, sin emisión (idempotente).
## - Transición ilegal -> false, sin emisión.
## Ruta legal: _exit(from) -> current = to -> _enter(to) -> state_changed.
func transition_to(next: State) -> bool:
	if next == current:
		return false
	if not can_transition_to(next):
		return false
	var from := current
	_exit_state(from)
	current = next
	_enter_state(next)
	state_changed.emit(from, next)
	return true

func _enter_state(state: State) -> void:
	state_entered.emit(state)

func _exit_state(state: State) -> void:
	state_exited.emit(state)
