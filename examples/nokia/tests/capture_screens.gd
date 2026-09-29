extends SceneTree
const Main = preload("res://scripts/main.gd")
const StartScreen = preload("res://scripts/screens/start_screen.gd")
const GameScreen = preload("res://scripts/screens/game_screen.gd")
const ScoresScreen = preload("res://scripts/screens/scores_screen.gd")
const Levels = preload("res://scripts/logic/levels.gd")

const OUT := "user://captures"

func _initialize() -> void: _run()

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var main = Main.new()
	root.add_child(main)
	await process_frame
	await process_frame
	await _cap("10_inicio")

	var start = _find(main, StartScreen)
	start.play_requested.emit()
	await process_frame
	var g = _find(main, GameScreen)
	await _cap("11_nivel1_wrap")

	# Nivel con obstaculos, borde atravesable
	g.game.load_level(2)
	g.game.level_eaten = 3
	g._update_hud()
	g._show_level_banner()
	await process_frame
	await _cap("12_nivel3_obstaculos")

	# Nivel mortal: borde dibujado como muro
	g.game.load_level(6)
	g.game.level_eaten = 2
	g._update_hud()
	g._show_level_banner()
	await process_frame
	await _cap("13_nivel7_mortal")

	# Nivel avanzado
	g.game.load_level(9)
	g._update_hud()
	g._show_level_banner()
	await process_frame
	await _cap("14_nivel10_colmena")

	# Pantalla final con nivel y victoria
	main._show_scores(64, 10, true)
	await process_frame
	await process_frame
	await _cap("15_victoria")

	print("captures: ", ProjectSettings.globalize_path(OUT))
	quit(0)

func _cap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/%s.png" % [OUT, name])

func _find(node: Node, script: Script) -> Node:
	for c in node.get_children():
		if c.get_script() == script: return c
		var n = _find(c, script)
		if n != null: return n
	return null
