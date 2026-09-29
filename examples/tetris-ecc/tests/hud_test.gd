extends SceneTree

var _failures := 0
var _hud: ComicHud
var _ran := false

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS  ", msg)
	else:
		_failures += 1
		printerr("  FAIL  ", msg)

func _initialize() -> void:
	print("=== Tetris Comic :: HUD test ===")
	# ComicHud es un Control: se añade al árbol; su _ready corre antes del
	# primer frame, por eso las aserciones se hacen en _process (frame 1).
	_hud = ComicHud.new()
	get_root().add_child(_hud)

func _process(_delta: float) -> bool:
	if _ran:
		return true
	_ran = true
	var hud := _hud

	# --- estado por defecto: TITLE ---
	_ok(hud.screen == ComicHud.Screen.TITLE, "pantalla por defecto = TITLE")

	# --- show_title ---
	hud.show_title()
	_ok(hud.screen == ComicHud.Screen.TITLE, "show_title() -> TITLE")
	_ok(hud.title_label != null and hud.title_label.visible, "título visible en TITLE")
	_ok(hud.prompt_label != null and hud.prompt_label.visible, "prompt visible en TITLE")
	_ok(hud.prompt_label.text == ComicHud.START_PROMPT,
		"el prompt dice '%s' (%s)" % [ComicHud.START_PROMPT, hud.prompt_label.text])
	_ok(not hud.gameplay_visible(), "paneles de juego OCULTOS en TITLE")

	# --- show_gameplay ---
	hud.show_gameplay()
	_ok(hud.screen == ComicHud.Screen.PLAYING, "show_gameplay() -> PLAYING")
	_ok(hud.gameplay_visible(), "paneles de juego VISIBLES en PLAYING")
	_ok(not hud.title_label.visible, "título oculto en PLAYING")
	_ok(not hud.prompt_label.visible, "prompt oculto en PLAYING")

	# --- show_game_over (persistente) ---
	hud.show_game_over()
	_ok(hud.screen == ComicHud.Screen.GAME_OVER, "show_game_over() -> GAME_OVER")
	_ok(hud.gameover_label != null and hud.gameover_label.visible,
		"cartel GAME OVER visible y PERSISTENTE en GAME_OVER")
	# El menú comunica las acciones (ya no se duplica con un prompt).
	_ok(hud.menu_options() == ["REINTENTAR", "TÍTULO"],
		"GAME_OVER: menú con las acciones %s" % str(hud.menu_options()))
	_ok(not hud.prompt_label.visible,
		"GAME_OVER: el prompt no se duplica con el menú")
	_ok(not hud.gameplay_visible(), "paneles de juego ocultos en GAME_OVER")

	# --- volver a TITLE limpia el cartel persistente ---
	hud.show_title()
	_ok(not hud.gameover_label.visible, "al volver a TITLE el cartel de GAME OVER se oculta")

	# --- BoardView: gate show_board (S1) ---
	var view := BoardView.new()
	get_root().add_child(view)
	_ok(view.show_board == true, "board_view arranca con show_board = true")
	view.show_board = false
	_ok(view.visible_or_hidden_state() == "hidden", "show_board=false -> la vista queda oculta")
	view.show_board = true
	_ok(view.visible_or_hidden_state() == "shown", "show_board=true -> la vista se muestra")

	print("=== ", ("ALL PASS" if _failures == 0 else str(_failures) + " FAILURE(S)"), " ===")
	quit(1 if _failures > 0 else 0)
	return true
