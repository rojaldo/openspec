## GameOverOverlay.gd — Capa de fin de partida sobre el tablero congelado.
## Muestra la explosion, el cartel GAME OVER, la puntuacion y dos acciones.
class_name GameOverOverlay
extends Control

signal retry_requested
signal menu_requested

const BURST := "res://textures/bg_action_burst.png"
const CARTEL := "res://textures/hud_gameover.png"
const TAMANO := Vector2(480, 720)

var _score_label: Label

func _ready() -> void:
	position = Vector2.ZERO
	size = TAMANO

	var burst := ColorRect.new()
	burst.color = Color(0, 0, 0, 0.62)
	burst.position = Vector2.ZERO
	burst.size = TAMANO
	add_child(burst)

	var fondo := TextureRect.new()
	fondo.texture = load(BURST)
	fondo.position = Vector2.ZERO
	fondo.size = TAMANO
	fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo.stretch_mode = TextureRect.STRETCH_SCALE
	fondo.modulate = Color(1, 1, 1, 0.55)
	add_child(fondo)

	var cartel := TextureRect.new()
	cartel.texture = load(CARTEL)
	cartel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cartel.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cartel.position = Vector2(30, 250)
	cartel.size = Vector2(420, 180)
	add_child(cartel)

	_score_label = _make_label(Vector2(0, 440), 30)
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_score_label.size = Vector2(480, 40)

	_accion("REINTENTAR  [R]", Vector2(140, 500), func(): retry_requested.emit())
	_accion("MENU  [M]", Vector2(140, 550), func(): menu_requested.emit())

func _make_label(pos: Vector2, size_px: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = Vector2(480, 40)
	l.add_theme_font_size_override("font_size", size_px)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", Color("#14110f"))
	l.add_theme_constant_override("outline_size", 6)
	add_child(l)
	return l

func _accion(texto: String, pos: Vector2, cb: Callable) -> void:
	var b := Button.new()
	b.text = texto
	b.position = pos
	b.size = Vector2(200, 40)
	b.custom_minimum_size = Vector2(200, 40)
	b.add_theme_font_size_override("font_size", 18)
	b.add_theme_color_override("font_color", Color("#14110f"))
	b.add_theme_color_override("font_outline_color", Color.WHITE)
	b.add_theme_constant_override("outline_size", 3)
	b.pressed.connect(cb)
	add_child(b)

func set_score(v: int) -> void:
	_pending_score = v
	if _score_label != null:
		_score_label.text = "PUNTUACION  %06d" % v
	else:
		call_deferred("_apply_pending_score")

func _apply_pending_score() -> void:
	if _score_label != null:
		_score_label.text = "PUNTUACION  %06d" % _pending_score

var _pending_score := 0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_R:
				get_viewport().set_input_as_handled()
				retry_requested.emit()
			KEY_M:
				get_viewport().set_input_as_handled()
				menu_requested.emit()
