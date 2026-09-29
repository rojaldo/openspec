## hud.gd — Marcador comic. Es un OBSERVADOR más (patrón 4) y el panel NEXT.
##
## Responsabilidades (ninguna es una regla de juego):
##  1. OBSERVER (patrón 4): implementa `on_lines_cleared()` para reaccionar a las
##     líneas eliminadas refrescando el marcador. NO calcula puntos: los lee ya
##     calculados por ScoreObserver.
##  2. Panel NEXT: muestra la pieza que el COMMAND (patrón 6) comunica al canvas
##     mediante `set_next_piece()`.
##
## Todo el HUD se dibuja en `_draw()` con las texturas del pack, escaladas a la
## columna de 160 px de la derecha. Se dibuja a mano (draw_texture_rect) en lugar
## de usar TextureRect porque estos se expanden al tamaño nativo de la textura
## (p.ej. hud_score es 232 px) y desbordarían la pantalla.
extends Control
class_name ComicHud

const TEX := {
	"score": "res://textures/hud_score.png",
	"level": "res://textures/hud_level.png",
	"lines": "res://textures/hud_lines.png",
	"next": "res://textures/hud_next.png",
	"bar": "res://textures/hud_bar.png",
	"tetris": "res://textures/hud_tetris.png",
	"gameover": "res://textures/hud_gameover.png",
}

var model: BoardModel

## Pantallas del juego (gobernadas por el FSM, patrón 7).
enum Screen { TITLE, PLAYING, GAME_OVER }

const START_PROMPT := "PULSA ENTER"

## Pantalla actual. Por defecto TITLE.
var screen: Screen = Screen.TITLE

## Etiquetas de pantalla (hijos Label; lo visible se puede aseverar headless).
var title_label: Label
var prompt_label: Label
var gameover_label: Label

# ------------------------------------------------------------------ LAYOUT --
# Ventana y columna. TODO se deriva de aquí: así la simetría es por
# construcción y no depende de literales sueltos (causa del desalineado).
const VIEW := Vector2(480, 720)
const BOARD_W := float(BoardView.COLS * BoardView.CELL)          # 10 x 32
const BOARD_TOP := 40.0       # el tablero está equilibrado arriba/abajo
const HUD_W := 132.0          # ancho de la columna del HUD
const GAP := 6.0              # separación tablero <-> HUD
# El margen se DERIVA del reparto: así izq == der por construcción, no por suerte.
const MARGIN := (VIEW.x - BOARD_W - HUD_W - GAP) / 2.0   # = 11
const BOARD_X := MARGIN                                   # = 11
const HUD_X := MARGIN + BOARD_W + GAP                     # = 337
const HUD_TOP := BOARD_TOP    # HUD alineado ARRIBA con el tablero (Tetris clásico)
const PANEL_GAP := 12.0       # separación uniforme entre paneles del HUD

# Rectángulos del HUD apilados desde HUD_TOP con PANEL_GAP uniforme.
# La ALTURA de cada tarjeta se deriva de la relación de aspecto de su PNG:
# así "lo declarado" == "lo dibujado" (antes se estimaba a mano y la tapa del
# valor no coincidía con la tarjeta -> se filtraban los números del PNG).
func _layout() -> Dictionary:
	var r := {}
	var y := HUD_TOP
	for key in ["score", "lines", "level", "next"]:
		var h := _card_height(key)
		r[key] = Rect2(HUD_X, y, HUD_W, h)
		y += h + PANEL_GAP
	# La barra va pegada justo bajo el marco NEXT (con un leve margen lateral).
	var bh := _card_height("bar") if _panels.has("bar") else 22.0
	r["bar"] = Rect2(HUD_X + 4.0, y, HUD_W - 8.0, bh)
	return r

## Altura que ocupa una tarjeta al ajustarse a HUD_W conservando su aspecto.
func _card_height(key: String) -> float:
	var tex: Texture2D = _panels.get(key, null)
	if tex == null or tex.get_width() == 0:
		return 60.0
	return HUD_W * float(tex.get_height()) / float(tex.get_width())

var SCORE_RECT := Rect2()
var LINES_RECT := Rect2()
var LEVEL_RECT := Rect2()
var NEXT_RECT := Rect2()
var BAR_RECT := Rect2()

var _menu: Array[String] = []
var _menu_index := 0
var _menu_labels: Array[Label] = []
var _anim_t := 0.0
var _enter_t := 0.0

var _panels: Dictionary = {}
var _piece_tex: Dictionary = {}
var _next_type := ""
var _banner_tex: Texture2D = null
var _banner_t := 0.0
var _banner_active := false

# Etiquetas de valores (hijos Control, encima del dibujo de paneles).
var _score_lbl: Label
var _lines_lbl: Label
var _level_lbl: Label

func _ready() -> void:
	# Carga de texturas en _ready (nunca dentro de _draw: se dibujaría en blanco).
	for k in ["score", "lines", "level", "next", "bar", "tetris", "gameover"]:
		_panels[k] = load(TEX[k]) as Texture2D
	# Fondo de explosión para el GAME OVER persistente (G1).
	_panels["burst"] = load("res://textures/bg_action_burst.png") as Texture2D
	_panels["paper"] = load("res://textures/bg_paper.png") as Texture2D
	for t in Tetromino.TYPES:
		_piece_tex[t] = Tetromino.piece_texture(t)

	# Ahora que hay texturas, se calculan los rectángulos (alturas derivadas).
	var r := _layout()
	SCORE_RECT = r["score"]; LINES_RECT = r["lines"]; LEVEL_RECT = r["level"]
	NEXT_RECT = r["next"]; BAR_RECT = r["bar"]

	# Valores reales superpuestos a los paneles (cada uno con fondo opaco para
	# tapar los números de ejemplo horneados en los PNG del pack).
	# Posiciones derivadas de los paneles (nada de literales): así el valor cae
	# siempre dentro de su tarjeta aunque cambie la columna.
	_score_lbl = _make_label(_value_pos(SCORE_RECT), 24, Color("#14110f"), Color("#ffffff"))
	_lines_lbl = _make_label(_value_pos(LINES_RECT), 24, Color("#e8432f"), Color("#ffffff"))
	_level_lbl = _make_label(_value_pos(LEVEL_RECT), 26, Color("#ffd93d"), Color("#14110f"))

	# --- Etiquetas de pantalla (TITLE / GAME_OVER) ---
	# Carteles centrados horizontalmente (ancho completo + align), sin offsets mágicos.
	title_label = _sticker(238, 62, 300, Color("#ffd93d"), Color(0, 0, 0, 0.65))
	title_label.text = "TETRIS"
	prompt_label = _pill(START_PROMPT, MENU_Y - 34.0, 20, Color("#fdf6e3"), 0.0)
	gameover_label = _sticker(214, 52, 340, Color("#ffd93d"), Color(0, 0, 0, 0.55))
	gameover_label.text = "GAME OVER"
	# Arranca en TITLE.
	show_title()

## Cartel grande centrado y acotado (título / GAME OVER), estilo pegatina.
func _sticker(y: float, size: int, width: float, color: Color, bg: Color) -> Label:
	var l := _make_label(Vector2((VIEW.x - width) / 2.0, y), size, color, bg)
	l.size = Vector2(width, size + 24.0)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l

## Pastilla compacta y centrada (prompt y opciones de menú).
func _pill(text: String, y: float, size: int, color: Color, alpha: float) -> Label:
	var l := _make_label(Vector2((VIEW.x - MENU_W) / 2.0, y), size, color,
		Color(0, 0, 0, alpha))
	l.size = Vector2(MENU_W, 28)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.text = text
	return l

## Bandas medidas en los PNG: el número de ejemplo ocupa la parte baja de la
## tarjeta. Se tapa exactamente esa franja (antes se estimaba y se filtraba).
const VALUE_BAND_TOP := 0.36    # fracción de la altura donde empieza el número
const VALUE_BAND_BOT := 0.97

## Zona del valor dentro de una tarjeta (TODA la franja del número horneado).
func _value_cover(card: Rect2) -> Rect2:
	var y0 := card.position.y + card.size.y * VALUE_BAND_TOP
	var y1 := card.position.y + card.size.y * VALUE_BAND_BOT
	return Rect2(Vector2(card.position.x + 5.0, y0),
		Vector2(card.size.x - 10.0, y1 - y0))

## Esquina superior-izquierda del hueco de valor dentro de una tarjeta del HUD.
func _value_pos(card: Rect2) -> Vector2:
	return Vector2(card.position.x + 10.0,
		card.position.y + card.size.y * VALUE_BAND_TOP + 2.0)

func _make_label(pos: Vector2, size: int, color: Color, bg: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	# Fondo opaco del propio Label (tapa el número de ejemplo del PNG).
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	l.add_theme_stylebox_override("normal", sb)
	add_child(l)
	return l

# --------------------------------------------------------------------- MENU --
## Construye las opciones de menú centradas horizontalmente bajo el cartel.
func _build_menu(options: Array, start_y: float = -1.0) -> void:
	for l in _menu_labels:
		# remove_child primero: queue_free() es diferido y, sin esto, el menú
		# saliente y el entrante se dibujarían superpuestos durante un frame.
		remove_child(l)
		l.queue_free()
	_menu_labels.clear()
	_menu.clear()
	for o in options:
		_menu.append(o)
	_menu_index = 0
	var y := start_y if start_y > 0.0 else MENU_Y
	for o in _menu:
		# Misma pastilla que el prompt (una sola forma de dibujar opciones).
		var l := _pill(o, y, 20, Color("#fdf6e3"), 0.55)
		_menu_labels.append(l)
		y += 34.0
	_refresh_menu()

const MENU_Y := 468.0        # menú del TÍTULO
const MENU_Y_OVER := 452.0   # menú del GAME OVER (bajo el cartel)
const MENU_W := 220.0

## Animación de entrada: el cartel crece y el fondo hace un fundido rápido.
func _play_entrance() -> void:
	_enter_t = 0.0
	set_process(true)

# ------------------------------------------------------------------ LAYOUT API
## Extensión real ocupada por el HUD (unión de sus paneles). La usan los tests
## de maquetación para comprobar simetría/alineación sin render.
func hud_bounds() -> Rect2:
	# Unión SIN recortar: si se recorta a la ventana, un desbordamiento real
	# queda oculto y los invariantes de "cabe en la ventana" no pueden fallar.
	return SCORE_RECT.merge(LINES_RECT).merge(LEVEL_RECT).merge(NEXT_RECT).merge(BAR_RECT)

## Opciones del menú de la pantalla actual (vacío durante PLAYING).
func menu_options() -> Array[String]:
	return _menu.duplicate() if screen != Screen.PLAYING else ([] as Array[String])

func menu_index() -> int:
	return _menu_index

## Mueve la selección del menú (wrap-around).
func menu_move(dir: int) -> void:
	if _menu.is_empty():
		return
	_menu_index = wrapi(_menu_index + dir, 0, _menu.size())
	_refresh_menu()
	queue_redraw()

func _refresh_menu() -> void:
	if _menu_labels.is_empty():
		return
	for i in _menu_labels.size():
		var selected := i == _menu_index
		_menu_labels[i].text = ("> " if selected else "  ") + _menu[i]
		_menu_labels[i].add_theme_color_override("font_color",
			Color("#ffd93d") if selected else Color("#fdf6e3"))
		# La opción seleccionada "late" (usa _anim_t, que si no era código muerto).
		_menu_labels[i].modulate.a = (0.72 + 0.28 * sin(_anim_t * 5.0)) if selected else 1.0

## Llamado desde _process mientras hay menú: reaplica el pulso.
func _tick_menu_pulse() -> void:
	if _menu_labels.size() > 0 and _menu_index >= 0 and _menu_index < _menu_labels.size():
		_menu_labels[_menu_index].modulate.a = 0.72 + 0.28 * sin(_anim_t * 5.0)

# ---------------------------------------------------------------- SCREENS ----
## Cambia a la pantalla de título (START). Oculta el juego.
func show_title() -> void:
	screen = Screen.TITLE
	_set_gameplay_visible(false)
	if title_label: title_label.visible = true
	if gameover_label: gameover_label.visible = false
	if prompt_label:
		prompt_label.visible = true
		prompt_label.text = START_PROMPT
	_build_menu(["JUGAR", "SALIR"])
	_play_entrance()
	queue_redraw()

## Cambia a la pantalla de juego (PLAYING). Muestra los paneles.
func show_gameplay() -> void:
	screen = Screen.PLAYING
	_set_gameplay_visible(true)
	if title_label: title_label.visible = false
	if gameover_label: gameover_label.visible = false
	if prompt_label: prompt_label.visible = false
	_build_menu([])
	queue_redraw()

## Cambia a la pantalla de fin de partida (GAME_OVER), PERSISTENTE (G1).
## El cartel GAME OVER se dibuja siempre, no como banner transitorio.
func show_game_over() -> void:
	screen = Screen.GAME_OVER
	_set_gameplay_visible(false)
	if title_label: title_label.visible = false
	if gameover_label: gameover_label.visible = true
	# El menú ya comunica las acciones: no se duplica con el prompt.
	if prompt_label: prompt_label.visible = false
	_build_menu(["REINTENTAR", "TÍTULO"], MENU_Y_OVER)
	_play_entrance()
	queue_redraw()

## ¿Están visibles los paneles de juego?
func gameplay_visible() -> bool:
	return _score_lbl != null and _score_lbl.visible

func _set_gameplay_visible(v: bool) -> void:
	for l in [_score_lbl, _lines_lbl, _level_lbl]:
		if l != null:
			l.visible = v

# ---------------------------------------------------------------- OBSERVER ---
## OBSERVER (patrón 4): se le notifica la línea eliminada y refresca el marcador.
func on_lines_cleared(_count: int, _is_tetris: bool) -> void:
	refresh()

func refresh() -> void:
	if model == null or model.score_observer == null:
		return
	var so := model.score_observer
	if _score_lbl:
		_score_lbl.text = "  " + str(so.score).pad_zeros(6)
	if _lines_lbl:
		_lines_lbl.text = "  " + str(so.lines)
	if _level_lbl:
		_level_lbl.text = "  " + str(so.level).pad_zeros(2)
	queue_redraw()

## Panel NEXT: lo invoca el COMMAND (patrón 6) a través del receptor del canvas.
func set_next_piece(type: String) -> void:
	_next_type = type
	queue_redraw()

## Lanza el banner (tetris o gameover) con animación pop.
func flash_banner(key: String) -> void:
	_banner_tex = _panels.get(key, null)
	_banner_t = 0.0
	_banner_active = true
	set_process(true)

func _process(delta: float) -> void:
	# Animación de entrada de TITLE/GAME_OVER (pop del cartel).
	if _enter_t < ENTER_DUR:
		_enter_t += delta
		if _enter_t >= ENTER_DUR:
			_enter_t = ENTER_DUR
		queue_redraw()
	# Pulso continuo del menú (latido suave de la opción seleccionada).
	if screen != Screen.PLAYING and not _menu_labels.is_empty():
		_anim_t += delta
		_tick_menu_pulse()
		queue_redraw()
	# Banner transitorio (TETRIS!).
	if _banner_active:
		_banner_t += delta
		if _banner_t / 1.4 >= 1.0:
			_banner_active = false
		queue_redraw()
	if _enter_t >= ENTER_DUR and not _banner_active and (screen == Screen.PLAYING or _menu_labels.is_empty()):
		set_process(false)

const ENTER_DUR := 0.35

## Escala/alfa de entrada del cartel (0..1 -> 1) con rebote suave.
func _enter_scale() -> float:
	var t := clampf(_enter_t / ENTER_DUR, 0.0, 1.0)
	if t <= 0.0:
		return 0.001
	# ease-out-back: se pasa un poco y vuelve.
	var c1 := 1.70158
	var c3 := c1 + 1.0
	var e := 1.0 + c3 * pow(t - 1.0, 3.0) + c1 * pow(t - 1.0, 2.0)
	return maxf(0.001, e)

func _enter_alpha() -> float:
	return clampf(_enter_t / (ENTER_DUR * 0.6), 0.0, 1.0)

# ------------------------------------------------------------------- DRAW ----
## Pantalla de título: fondo con viñeta, cartel que hace "pop" y panel de menú.
func _draw_title() -> void:
	# Viñeta de fondo (papel cómic), con leve fundido de entrada.
	var paper: Texture2D = _panels.get("paper", null)
	if paper != null:
		draw_texture_rect(paper, Rect2(Vector2.ZERO, VIEW), false, Color(1, 1, 1, _enter_alpha()))
	else:
		draw_rect(Rect2(Vector2.ZERO, VIEW), Color("#8fd7f2"), true)
	# Cartel TETRIS con "pop" de entrada (antes solo se fundía el fondo).
	if title_label != null:
		var sc := _enter_scale()
		title_label.pivot_offset = title_label.size / 2.0
		title_label.scale = Vector2(sc, sc)
		title_label.modulate.a = _enter_alpha()
	# Marco del menú (derivado de MENU_Y, sin literales sueltos).
	var panel := Rect2((VIEW.x - MENU_W - 40.0) / 2.0, MENU_Y - 40.0, MENU_W + 40.0, 116.0)
	draw_rect(panel, Color(0, 0, 0, 0.40), true)
	draw_rect(panel, Color("#14110f"), false, 3.0)

func _draw() -> void:
	# GAME_OVER: fondo de explosión + cartel persistente (G1). No pinta paneles.
	if screen == Screen.GAME_OVER:
		_draw_game_over()
		return
	# TITLE: fondo cómic + cartel animado + marco del menú.
	if screen == Screen.TITLE:
		_draw_title()
		return

	_draw_panel("score", SCORE_RECT)
	_draw_panel("lines", LINES_RECT)
	_draw_panel("level", LEVEL_RECT)
	_draw_panel("next", NEXT_RECT)
	_draw_panel("bar", BAR_RECT)

	# Los PNG del pack traen valores de ejemplo horneados (042750, 148, 07 y un
	# "3" en la barra). Se tapan dibujando el interior opaco del panel; encima
	# van las etiquetas reales (hijos Label, que se dibujan tras este _draw).
	# Tapas derivadas de las tarjetas (ocultan los valores de ejemplo del PNG).
	draw_rect(_value_cover(SCORE_RECT), Color("#ffffff"), true)  # SCORE
	draw_rect(_value_cover(LINES_RECT), Color("#ffffff"), true)  # LINES
	draw_rect(_value_cover(LEVEL_RECT), Color("#14110f"), true)  # LEVEL
	# Se cubre la barra entera (no solo el centro): el PNG trae un ~62% verde
	# horneado y, sin taparlo del todo, la barra parecía medio llena a 0 líneas.
	var bar_inner := BAR_RECT.grow(-4)
	draw_rect(bar_inner, Color("#ffffff"), true)                 # BAR

	# Relleno verde de progreso dentro de la barra (avance del nivel actual).
	if model != null and model.score_observer != null:
		var frac := float(model.score_observer.lines % 10) / 10.0
		if frac > 0.0:
			var fill := bar_inner
			fill.size.x *= frac
			draw_rect(fill, Color("#4fd06a"), true)

	# Pieza siguiente dentro del marco interior del panel NEXT. El marco medido
	# va del 22% al 86% de la altura de la tarjeta: se ajusta la pieza ahí para
	# que no se salga (antes se centraba a +100 px y desbordaba el marco).
	if _next_type != "" and _piece_tex.has(_next_type):
		var tex: Texture2D = _piece_tex[_next_type]
		var frame := Rect2(
			NEXT_RECT.position + Vector2(NEXT_RECT.size.x * 0.12, NEXT_RECT.size.y * 0.26),
			Vector2(NEXT_RECT.size.x * 0.76, NEXT_RECT.size.y * 0.56))
		var max_dim := float(maxi(tex.get_width(), tex.get_height()))
		var s := (frame.size.x * 0.86) / max_dim
		var sz := Vector2(tex.get_width(), tex.get_height()) * s
		var center := frame.position + frame.size / 2.0
		draw_texture_rect(tex, Rect2(center - sz / 2.0, sz), false)

	# Banner animado (TETRIS! / GAME OVER).
	if _banner_active and _banner_tex != null:
		var k := _banner_t / 1.4
		var a := 1.0 - pow(k, 3.0)
		var w := 440.0 * (1.0 + 0.12 * sin(k * PI))
		var h := w * float(_banner_tex.get_height()) / float(_banner_tex.get_width())
		var r := Rect2(Vector2(240 - w / 2.0, 300 - h / 2.0), Vector2(w, h))
		draw_texture_rect(_banner_tex, r, false, Color(1, 1, 1, a))

## Pantalla de GAME OVER persistente (G1): fondo de explosión. El cartel
## "GAME OVER" lo pinta `gameover_label` (persistente y aseverable); no se
## duplica con la textura hud_gameover.png para evitar el solapamiento.
func _draw_game_over() -> void:
	# Fondo de explosión con fundido de entrada.
	var burst: Texture2D = _panels.get("burst", null)
	if burst != null:
		draw_texture_rect(burst, Rect2(Vector2.ZERO, VIEW), false,
			Color(1, 1, 1, _enter_alpha()))
	# Cartel GAME OVER con "pop" (escala con rebote + fundido).
	if gameover_label != null:
		var sc := _enter_scale()
		gameover_label.pivot_offset = gameover_label.size / 2.0
		gameover_label.scale = Vector2(sc, sc)
		gameover_label.modulate.a = _enter_alpha()
	# Marco del menú, con el mismo tratamiento que en el título.
	var panel := Rect2((VIEW.x - MENU_W - 40.0) / 2.0, MENU_Y_OVER - 18.0, MENU_W + 40.0, 88.0)
	draw_rect(panel, Color(0, 0, 0, 0.55), true)
	draw_rect(panel, Color("#14110f"), false, 3.0)

## Dibuja un panel del pack ajustado a `dst` (sin deformar más de lo justo).
func _draw_panel(key: String, dst: Rect2) -> void:
	var tex: Texture2D = _panels.get(key, null)
	if tex == null:
		return
	var src_ratio := float(tex.get_width()) / float(tex.get_height())
	var dst_ratio := dst.size.x / dst.size.y
	var r := dst
	if dst_ratio > src_ratio:
		r.size.x = dst.size.y * src_ratio
		r.position.x += (dst.size.x - r.size.x) / 2.0
	else:
		r.size.y = dst.size.x / src_ratio
	draw_texture_rect(tex, r, false)
