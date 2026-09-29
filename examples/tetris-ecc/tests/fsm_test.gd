## tests/fsm_test.gd — PATRÓN 7 (State/FSM): tabla de transiciones.
##
## Ejecutar: godot --headless --path . --script res://tests/fsm_test.gd
## Prueba la máquina de estados PURA, sin escena ni modelo.
extends SceneTree

var _failures := 0
var _events: Array = []

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS  ", msg)
	else:
		_failures += 1
		printerr("  FAIL  ", msg)

func _initialize() -> void:
	print("=== Tetris Comic :: FSM test (Pattern 7) ===")

	var S := GameStateMachine.State

	# --- estado inicial ---
	var fsm := GameStateMachine.new()
	_ok(fsm.current == S.START, "estado inicial = START")

	# Observa las transiciones para comprobar emisiones.
	fsm.state_changed.connect(func(from, to): _events.append(["changed", from, to]))
	var entered: Array = []
	var exited: Array = []
	fsm.state_entered.connect(func(s): entered.append(s))
	fsm.state_exited.connect(func(s): exited.append(s))

	# --- transición ilegal: START -> GAME_OVER ---
	_ok(fsm.transition_to(S.GAME_OVER) == false, "START -> GAME_OVER es ilegal (devuelve false)")
	_ok(fsm.current == S.START, "estado sigue START tras transición ilegal")
	_ok(_events.is_empty(), "transición ilegal no emite state_changed")

	# --- idempotencia: START -> START ---
	_ok(fsm.transition_to(S.START) == false, "START -> START es no-op (devuelve false)")
	_ok(_events.is_empty(), "transición idempotente no emite state_changed")

	# --- legal: START -> PLAYING ---
	_ok(fsm.transition_to(S.PLAYING) == true, "START -> PLAYING es legal")
	_ok(fsm.current == S.PLAYING, "estado = PLAYING")
	_ok(_events.size() == 1 and _events[0] == ["changed", S.START, S.PLAYING],
		"emite state_changed(START, PLAYING) exactamente una vez")
	_ok(exited == [S.START], "emite state_exited(START)")
	_ok(entered == [S.PLAYING], "emite state_entered(PLAYING)")

	# --- ilegal: PLAYING -> START ---
	_ok(fsm.transition_to(S.START) == false, "PLAYING -> START es ilegal (sin abortar a mitad)")
	_ok(fsm.current == S.PLAYING, "estado sigue PLAYING")

	# --- legal: PLAYING -> GAME_OVER ---
	_ok(fsm.transition_to(S.GAME_OVER) == true, "PLAYING -> GAME_OVER es legal")
	_ok(fsm.current == S.GAME_OVER, "estado = GAME_OVER")

	# --- legal: GAME_OVER -> PLAYING (reiniciar) ---
	_ok(fsm.transition_to(S.PLAYING) == true, "GAME_OVER -> PLAYING (reiniciar) es legal")

	# --- legal: GAME_OVER -> START (volver al título) ---
	fsm.transition_to(S.GAME_OVER)
	_ok(fsm.transition_to(S.START) == true, "GAME_OVER -> START (volver al título) es legal")
	_ok(fsm.current == S.START, "estado = START tras volver al título")

	# --- contabilidad enter/exit: 5 transiciones legales ejecutadas ---
	# START->PLAYING, PLAYING->GAME_OVER, GAME_OVER->PLAYING, PLAYING->GAME_OVER, GAME_OVER->START
	_ok(entered.size() == 5 and exited.size() == 5,
		"enter y exit equilibrados (%d/%d)" % [entered.size(), exited.size()])
	_ok(_events.size() == 5, "5 state_changed emitidos en total (%d)" % _events.size())

	# --- can_transition_to no muta ---
	var fsm2 := GameStateMachine.new()
	_ok(fsm2.can_transition_to(S.PLAYING) and not fsm2.can_transition_to(S.GAME_OVER),
		"can_transition_to refleja la tabla sin mutar")
	_ok(fsm2.current == S.START, "can_transition_to no cambia el estado")

	print("=== ", ("ALL PASS" if _failures == 0 else str(_failures) + " FAILURE(S)"), " ===")
	quit(1 if _failures > 0 else 0)
