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
const RESTART_PROMPT := "ENTER: JUGAR   ESC: TÍTULO"

## Pantalla actual. Por defecto TITLE.
var screen: Screen = Screen.TITLE

## Etiquetas de pantalla (hijos Label; lo visible se puede aseverar headless).
var title_label: Label
var prompt_label: Label
var gameover_label: Label

# Rectángulos de destino (medidos para una vista de 480x720).
const SCORE_RECT  := Rect2(336, 24, 140, 65)
const LINES_RECT  := Rect2(336, 100, 140, 71)
const LEVEL_RECT  := Rect2(336, 182, 140, 93)
const NEXT_RECT   := Rect2(336, 288, 140, 155)
const BAR_RECT    := Rect2(340, 452, 132, 22)

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
	for t in Tetromino.TYPES:
		_piece_tex[t] = Tetromino.piece_texture(t)

	# Valores reales superpuestos a los paneles (cada uno con fondo opaco para
	# tapar los números de ejemplo horneados en los PNG del pack).
	_score_lbl = _make_label(Vector2(346, 52), 24, Color("#14110f"), Color("#ffffff"))
	_lines_lbl = _make_label(Vector2(346, 128), 24, Color("#e8432f"), Color("#ffffff"))
	_level_lbl = _make_label(Vector2(346, 210), 26, Color("#ffd93d"), Color("#14110f"))

	# --- Etiquetas de pantalla (TITLE / GAME_OVER) ---
	title_label = _make_label(Vector2(60, 250), 54, Color("#ffd93d"), Color("#14110f"))
	title_label.text = "TETRIS"
	prompt_label = _make_label(Vector2(70, 430), 24, Color("#fdf6e3"), Color("#14110f"))
	prompt_label.text = START_PROMPT
	gameover_label = _make_label(Vector2(30, 270), 46, Color("#ffd93d"), Color("#14110f"))
	gameover_label.text = "GAME OVER"
	# Arranca en TITLE.
	show_title()

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
	queue_redraw()

## Cambia a la pantalla de juego (PLAYING). Muestra los paneles.
func show_gameplay() -> void:
	screen = Screen.PLAYING
	_set_gameplay_visible(true)
	if title_label: title_label.visible = false
	if gameover_label: gameover_label.visible = false
	if prompt_label: prompt_label.visible = false
	queue_redraw()

## Cambia a la pantalla de fin de partida (GAME_OVER), PERSISTENTE (G1).
## El cartel GAME OVER se dibuja siempre, no como banner transitorio.
func show_game_over() -> void:
	screen = Screen.GAME_OVER
	_set_gameplay_visible(false)
	if title_label: title_label.visible = false
	if gameover_label: gameover_label.visible = true
	if prompt_label:
		prompt_label.visible = true
		prompt_label.text = RESTART_PROMPT
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
	if not _banner_active:
		return
	_banner_t += delta
	if _banner_t / 1.4 >= 1.0:
		_banner_active = false
		set_process(false)
	queue_redraw()

# ------------------------------------------------------------------- DRAW ----
func _draw() -> void:
	# GAME_OVER: fondo de explosión + cartel persistente (G1). No pinta paneles.
	if screen == Screen.GAME_OVER:
		_draw_game_over()
		return
	# TITLE: no pinta los paneles de juego (los dibuja show_title vía Labels).
	if screen == Screen.TITLE:
		return

	_draw_panel("score", SCORE_RECT)
	_draw_panel("lines", LINES_RECT)
	_draw_panel("level", LEVEL_RECT)
	_draw_panel("next", NEXT_RECT)
	_draw_panel("bar", BAR_RECT)

	# Los PNG del pack traen valores de ejemplo horneados (042750, 148, 07 y un
	# "3" en la barra). Se tapan dibujando el interior opaco del panel; encima
	# van las etiquetas reales (hijos Label, que se dibujan tras este _draw).
	draw_rect(Rect2(342, 50, 128, 34), Color("#ffffff"), true)   # SCORE
	draw_rect(Rect2(342, 124, 128, 36), Color("#ffffff"), true)  # LINES
	draw_rect(Rect2(342, 206, 128, 58), Color("#14110f"), true)  # LEVEL
	var bar_inner := BAR_RECT.grow(-5)
	draw_rect(bar_inner, Color("#ffffff"), true)                 # BAR

	# Relleno verde de progreso dentro de la barra (avance del nivel actual).
	if model != null and model.score_observer != null:
		var frac := float(model.score_observer.lines % 10) / 10.0
		if frac > 0.0:
			var fill := bar_inner
			fill.size.x *= frac
			draw_rect(fill, Color("#4fd06a"), true)

	# Pieza siguiente dentro del marco NEXT.
	if _next_type != "" and _piece_tex.has(_next_type):
		var tex: Texture2D = _piece_tex[_next_type]
		var max_dim := float(maxi(tex.get_width(), tex.get_height()))
		var s := 104.0 / max_dim
		var sz := Vector2(tex.get_width(), tex.get_height()) * s
		var center := Vector2(NEXT_RECT.position.x + NEXT_RECT.size.x / 2.0,
			NEXT_RECT.position.y + 100.0)
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
	var burst: Texture2D = _panels.get("burst", null)
	if burst != null:
		draw_texture_rect(burst, Rect2(Vector2.ZERO, Vector2(480, 720)), false)

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
