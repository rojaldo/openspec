extends SceneTree
## Test de integracion headless: recorrido inicio -> juego -> puntuaciones,
## progresion de niveles, muerte por solido y borde, y persistencia.
##   godot --headless -s tests/run_integration.gd

const Main = preload("res://scripts/main.gd")
const StartScreen = preload("res://scripts/screens/start_screen.gd")
const LevelSelectScreen = preload("res://scripts/screens/level_select_screen.gd")
const GameScreen = preload("res://scripts/screens/game_screen.gd")
const ScoresScreen = preload("res://scripts/screens/scores_screen.gd")
const Scores = preload("res://scripts/logic/scores.gd")
const Levels = preload("res://scripts/logic/levels.gd")
const Level = preload("res://scripts/logic/level.gd")

var _failed := 0
var _passed := 0


func _initialize() -> void:
	_run()


func check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		printerr("FAIL: " + label)


func _run() -> void:
	await process_frame

	var scores := Scores.new()
	if FileAccess.file_exists(scores.path):
		DirAccess.remove_absolute(scores.path)

	# Al abrir, se muestra la pantalla de inicio.
	var main = Main.new()
	root.add_child(main)
	await process_frame
	var start := _find(main, StartScreen)
	check(start != null, "al abrir se muestra la pantalla de inicio")

	# 4.1 La pantalla de inicio ofrece las dos opciones.
	check(_find_button(start, "EMPEZAR PARTIDA") != null, "el inicio ofrece empezar partida")
	check(_find_button(start, "ELEGIR NIVEL") != null, "el inicio ofrece elegir nivel")

	# 5.1 y 4.2 Inicio -> selector de nivel.
	start.select_level_requested.emit()
	await process_frame
	var selector := _find(main, LevelSelectScreen)
	check(selector != null, "elegir nivel lleva al selector")

	# 2.2 y 2.3 El selector muestra los diez niveles y la vuelta al inicio.
	check(selector.level_buttons.size() == Levels.count(), "el selector muestra los diez niveles")
	check(selector.level_buttons[0].text == "1 · %d" % Levels.at(0).target, "la etiqueta lleva numero y objetivo")
	check(selector.level_buttons[6].text == "7 · %d" % Levels.at(6).target, "el septimo boton lleva su numero y objetivo")
	check(not selector.level_buttons[9].disabled, "el nivel 10 no esta bloqueado")
	check(_find_button(selector, "VOLVER") != null, "el selector ofrece volver al inicio")

	# 3.3 Volver al inicio desde el selector.
	selector.back_requested.emit()
	await process_frame
	check(_find(main, StartScreen) != null, "volver desde el selector regresa al inicio")

	# 5.1 Elegir el nivel 7 arranca la partida en el nivel 7.
	var start2 := _find(main, StartScreen)
	start2.select_level_requested.emit()
	await process_frame
	var selector2 := _find(main, LevelSelectScreen)
	selector2.level_buttons[6].pressed.emit()
	await process_frame
	var game7 := _find(main, GameScreen)
	check(game7 != null, "elegir un nivel lleva a la pantalla de juego")
	check(game7.game.level_index == 6, "la partida arranca en el nivel elegido (7)")
	check(game7.game.cells.size() == 3, "arranca con la serpiente de 3 celdas")
	check(game7.level_label.text.contains("NIVEL 7"), "el HUD muestra el nivel elegido")

	# 5.2 La progresion sigue desde el nivel elegido.
	var target7: int = game7.game.level.target
	for i in target7:
		game7.game.food = game7.game.cells[0] + game7.game.direction
		game7.step_tick()
	check(game7.game.level_index == 7, "completar el nivel 7 lleva al 8")

	# 5.3 Empezar partida sigue arrancando en el nivel 1.
	main._show_game()
	await process_frame
	var game1 := _find(main, GameScreen)
	check(game1.game.level_index == 0, "empezar partida arranca en el nivel 1")
	var game_screen = game1

	# 5.1 El HUD muestra nivel y objetivo.
	check(game_screen.level_label.text.contains("NIVEL 1"), "se muestra el nivel actual")
	check(game_screen.goal_label.text.contains("COCOS 0/"), "se muestra el progreso del objetivo")
	check(game_screen.game.level.border == Level.BORDER_WRAP, "la partida empieza en un nivel atravesable")

	# 5.2 Al empezar el nivel se anuncia su numero y objetivo.
	check(game_screen.banner.text.contains("NIVEL 1"), "se anuncia el nivel al empezar")

	# 5.3 y 3.8 Completar el objetivo pasa al nivel siguiente con estado reiniciado.
	var target: int = game_screen.game.level.target
	for i in target:
		game_screen.game.food = game_screen.game.cells[0] + game_screen.game.direction
		game_screen.step_tick()
	check(game_screen.game.level_index == 1, "completar el objetivo avanza al nivel 2")
	check(game_screen.game.cells.size() == 3, "la serpiente reinicia a 3 celdas al cambiar de nivel")
	check(game_screen.game.score == target, "la puntuacion se conserva entre niveles")
	check(game_screen.banner.text.contains("NIVEL 2"), "se anuncia el nivel nuevo")
	check(game_screen.level_label.text.contains("NIVEL 2"), "el HUD actualiza el nivel")

	# Morir contra una celda solida en un nivel mortal.
	game_screen.game.load_level(4)
	check(game_screen.game.level.border == Level.BORDER_DEADLY, "el nivel 5 es mortal")
	var sol: Vector2i = game_screen.game.level.solids.keys()[0]
	game_screen.game.cells = [sol - Vector2i.RIGHT, sol - Vector2i.RIGHT * 2] as Array[Vector2i]
	game_screen.game.direction = Vector2i.RIGHT
	game_screen.step_tick()
	await process_frame
	var scores_screen = _find(main, ScoresScreen)
	check(scores_screen != null, "morir contra un solido lleva a la pantalla de puntuaciones")
	check(scores_screen.final_label.text.contains("NIVEL 5"), "se muestra el nivel alcanzado")

	# 6.3 El nivel alcanzado queda registrado.
	scores_screen.name_edit.text = ""
	scores_screen._commit()
	await process_frame
	var saved: Array = Scores.new().load_entries()
	check(saved.size() == 1, "la partida queda registrada")
	check(int(saved[0]["level"]) == 5, "el nivel alcanzado se registra con la partida")

	scores_screen.name_edit.text = "ROJALDO"
	scores_screen._commit()
	await process_frame
	check(str(Scores.new().load_entries()[0]["name"]) == "ROJALDO", "el nombre introducido se guarda")

	# Jugar otra partida desde el primer nivel.
	scores_screen.play_requested.emit()
	await process_frame
	var again = _find(main, GameScreen)
	check(again != null and again.game.level_index == 0, "jugar otra empieza de nuevo en el nivel 1")

	# 5.4 Victoria al completar el nivel 10.
	again.game.load_level(Levels.count() - 1)
	check(again.game.level_index == 9, "se carga el ultimo nivel")
	# Se aisla la victoria de la navegacion: falta un solo coco del objetivo.
	again.game.level_eaten = again.game.level.target - 1
	again.game.food = again.game.cells[0] + again.game.direction
	again.step_tick()
	await process_frame
	var victory_screen = _find(main, ScoresScreen)
	check(victory_screen != null, "completar el nivel 10 lleva a la pantalla final")
	check(victory_screen.victory, "la partida se marca como victoria")
	check(victory_screen.final_label.text.contains("VICTORIA"), "se muestra el texto de victoria")

	# Las cuatro acciones de direccion existen.
	for action in ["move_up", "move_down", "move_left", "move_right"]:
		check(InputMap.has_action(action), "existe la accion %s" % action)
		check(InputMap.action_get_events(action).size() >= 2, "la accion %s responde a flecha y WASD" % action)

	# Sin entradas se indica que no hay puntuaciones.
	var empty_screen = ScoresScreen.new()
	root.add_child(empty_screen)
	await process_frame
	empty_screen.entries = []
	empty_screen._refresh_table()
	check(empty_screen.table.get_child_count() == 1, "sin entradas se muestra un aviso en la tabla")
	empty_screen.queue_free()
	await process_frame

	main.queue_free()
	await process_frame

	# "Reabrir" el juego: la tabla conserva las entradas.
	var reopened = Main.new()
	root.add_child(reopened)
	await process_frame
	reopened._show_scores(7, 4, false)
	await process_frame
	var reopened_scores = _find(reopened, ScoresScreen)
	check(reopened_scores != null, "tras reabrir existe la pantalla de puntuaciones")
	check(reopened_scores.entries.size() >= 2, "tras reabrir la tabla conserva las entradas previas")
	var names: Array = []
	for e in reopened_scores.entries:
		names.append(str(e["name"]))
	check(names.has("ROJALDO"), "tras reabrir sigue el nombre registrado")
	reopened.queue_free()
	await process_frame

	print("")
	print("INTEGRATION: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func _find(node: Node, script: Script) -> Node:
	for child in node.get_children():
		if child.get_script() == script:
			return child
		var nested := _find(child, script)
		if nested != null:
			return nested
	return null


## Busca un boton por su texto en el arbol de la pantalla.
func _find_button(node: Node, text: String) -> Button:
	for child in node.get_children():
		if child is Button and child.text == text:
			return child
		var nested := _find_button(child, text)
		if nested != null:
			return nested
	return null
