## tests/layout_test.gd — INVARIANTES DE MAQUETACIÓN (regresión).
##
## Ejecutar: godot --headless --path . --script res://tests/layout_test.gd
##
## Prueba invariantes geométricos sobre la geometría DECLARADA de vista y HUD,
## sin render (headless). Los números salen de MEDIR los frames reales
## (480x720): antes el tablero quedaba a 16 px del borde izquierdo y el HUD a
## ~11 del derecho -> asimétrico; y el HUD empezaba 16 px por ENCIMA del tablero.
extends SceneTree

var _failures := 0
var _main: Node2D
var _ran := false

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS  ", msg)
	else:
		_failures += 1
		printerr("  FAIL  ", msg)

func _initialize() -> void:
	print("=== Tetris Comic :: layout invariants ===")
	_main = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	get_root().add_child(_main)

func _process(_delta: float) -> bool:
	if _ran:
		return true
	_ran = true
	var main := _main
	var view: BoardView = main.get_node("BoardView")
	var hud: ComicHud = main.get_node("Hud")

	var board := Rect2(view.position, view.board_size())
	# Extensión real del HUD (unión de sus paneles visibles).
	var hud_box := hud.hud_bounds()

	# --- 1. El CONJUNTO (tablero + separación + HUD) está centrado en la ventana ---
	# No basta con centrar el tablero: la composición completa es lo que se ve.
	var comp_left := board.position.x
	var comp_right := 480.0 - hud_box.end.x
	_ok(absf(comp_left - comp_right) <= 1.0,
		"composición centrada: margen izq %.0f == margen der %.0f" % [comp_left, comp_right])
	_ok(hud_box.position.x - board.end.x >= 0.0,
		"hay separación entre tablero y HUD (gap %.0f px)" % (hud_box.position.x - board.end.x))

	# --- 2. HUD alineado ARRIBA con el tablero (estética Tetris clásico) ---
	_ok(absf(hud_box.position.y - board.position.y) <= 1.0,
		"el HUD arranca a la misma altura que el tablero (top %.0f vs %.0f)"
			% [hud_box.position.y, board.position.y])

	# --- 3. El HUD no pisa el tablero ---
	_ok(not board.intersects(hud_box),
		"tablero y HUD no se solapan (board.end.x=%.0f, hud.x=%.0f)"
			% [board.end.x, hud_box.position.x])

	# --- 4. Todo dentro de la ventana ---
	var vp := Rect2(0, 0, 480, 720)
	_ok(vp.encloses(board), "el tablero cabe en la ventana")
	_ok(vp.encloses(hud_box), "el HUD cabe en la ventana")

	# --- 5. El HUD no se pasa por abajo ---
	_ok(hud_box.end.y <= 720.0, "el HUD no desborda por abajo (%.0f)" % hud_box.end.y)

	# --- 6. El tablero está verticalmente equilibrado ---
	var top := board.position.y
	var bottom := 720.0 - board.end.y
	_ok(absf(top - bottom) <= 1.0,
		"tablero verticalmente equilibrado (top %.0f vs bottom %.0f)" % [top, bottom])

	# --- 7. La pantalla de título tiene título + prompt + menú ---
	hud.show_title()
	_ok(hud.title_label != null and hud.title_label.visible, "TITLE: título visible")
	_ok(hud.prompt_label != null and hud.prompt_label.visible, "TITLE: prompt visible")
	_ok(hud.menu_options().size() >= 1, "TITLE: hay al menos una opción de menú (%d)" % hud.menu_options().size())

	# --- 8. La pantalla de game over tiene cartel + menú ---
	hud.show_game_over()
	_ok(hud.gameover_label != null and hud.gameover_label.visible, "GAME_OVER: cartel visible")
	_ok(hud.menu_options().size() >= 1, "GAME_OVER: hay al menos una opción de menú (%d)" % hud.menu_options().size())

	print("=== ", ("ALL PASS" if _failures == 0 else str(_failures) + " FAILURE(S)"), " ===")
	quit(1 if _failures > 0 else 0)
	return true
