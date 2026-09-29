## StartScreen.gd — Pantalla de inicio: fondo sky pop + titulo + empezar.
class_name StartScreen
extends Control

signal start_requested

const BACKGROUND := "res://textures/bg_sky_pop.png"
const TITULO := "res://textures/hud_tetris.png"
const TAMANO := Vector2(480, 720)

func _ready() -> void:
	# la raiz es un Node2D: el Control no hereda tamano, hay que fijarlo
	position = Vector2.ZERO
	size = TAMANO

	var bg := TextureRect.new()
	bg.texture = load(BACKGROUND)
	bg.position = Vector2.ZERO
	bg.size = TAMANO
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(bg)

	var titulo := TextureRect.new()
	titulo.texture = load(TITULO)
	titulo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	titulo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	titulo.position = Vector2(40, 150)
	titulo.size = Vector2(400, 164)
	add_child(titulo)

	var indicacion := Label.new()
	indicacion.text = "PULSA ESPACIO PARA EMPEZAR"
	indicacion.position = Vector2(0, 620)
	indicacion.size = Vector2(480, 40)
	indicacion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	indicacion.add_theme_font_size_override("font_size", 22)
	indicacion.add_theme_color_override("font_color", Color("#14110f"))
	indicacion.add_theme_color_override("font_outline_color", Color.WHITE)
	indicacion.add_theme_constant_override("outline_size", 6)
	add_child(indicacion)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			get_viewport().set_input_as_handled()
			start_requested.emit()
