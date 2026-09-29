## StatsPanel.gd — Indicadores del rail derecho pintados con valores vivos
## (opcion 3: marcos estilo comic + texto real, no los PNG con cifras).
## Las tarjetas van en coordenadas locales; la fila base las centra en pantalla.
class_name StatsPanel
extends Control

const RAIL_X := 354.0
const RAIL_W := 104.0
const PAD := 8.0
const INK := Color("#14110f")
const CARD := Color("#fdf6e3")
const ACCENT := Color("#e8432f")

## Fila base: 328 px de alto, desplazada para centrarse en y=360 de la pantalla.
const RAIL_Y := 196.0
const SCORE_RECT := Rect2(0, 0, RAIL_W, 92)
const LINES_RECT := Rect2(0, 108, RAIL_W, 72)
const NEXT_RECT := Rect2(0, 196, RAIL_W, 132)

var score := 0
var lines := 0
var next_type := ""

var _score_label: Label
var _lines_label: Label
var _next_sprite: TextureRect

func _ready() -> void:
	position = Vector2(RAIL_X, RAIL_Y)
	size = Vector2(RAIL_W, NEXT_RECT.end.y)

	_score_label = _make_label(SCORE_RECT, 26)
	_lines_label = _make_label(LINES_RECT, 26)

	_next_sprite = TextureRect.new()
	_next_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_next_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_next_sprite.position = NEXT_RECT.position + Vector2(PAD, 34)
	_next_sprite.size = Vector2(RAIL_W - PAD * 2, NEXT_RECT.size.y - 42)
	add_child(_next_sprite)

func _make_label(r: Rect2, size_px: int) -> Label:
	var l := Label.new()
	l.position = r.position + Vector2(PAD, 34)
	l.size = Vector2(r.size.x - PAD * 2, 40)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", INK)
	l.add_theme_color_override("font_outline_color", Color.WHITE)
	l.add_theme_constant_override("outline_size", 3)
	add_child(l)
	return l

func refresh(p_score: int, p_lines: int, p_next: String) -> void:
	score = p_score
	lines = p_lines
	next_type = p_next
	if _score_label != null:
		_score_label.text = str(score).pad_zeros(6)
	if _lines_label != null:
		_lines_label.text = str(lines)
	if _next_sprite != null and _next_sprite.texture == null:
		_next_sprite.texture = Tetromino.piece_texture(next_type)
	elif _next_sprite != null and next_type != "":
		_next_sprite.texture = Tetromino.piece_texture(next_type)

func _draw() -> void:
	_card(SCORE_RECT, "SCORE")
	_card(LINES_RECT, "LINES")
	_card(NEXT_RECT, "NEXT")

## Vineta comic: sombra desfasada, relleno claro, borde de tinta grueso.
func _card(r: Rect2, title: String) -> void:
	var shadow := Rect2(r.position + Vector2(4, 4), r.size)
	draw_rect(shadow, INK, true)
	draw_rect(r, CARD, true)
	draw_rect(r, INK, false, 3.0)
	draw_string(
		ThemeDB.fallback_font,
		r.position + Vector2(PAD, 24),
		title,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		15,
		ACCENT
	)
