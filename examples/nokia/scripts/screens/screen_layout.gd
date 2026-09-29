extends RefCounted
## Layout comun de las pantallas: fondo a pantalla completa y columna
## centrada. Evita repetir la misma configuracion en las tres pantallas.

const PixelFont = preload("res://scripts/ui/pixel_font.gd")

const BG := Color("#9bbc0f")
const INK := Color("#0f2a12")


## Monta el fondo, aplica la fuente de pixeles del proyecto a todos los
## controles y devuelve la columna centrada sobre la que anadir contenido.
static func build(screen: Control) -> VBoxContainer:
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var theme := Theme.new()
	theme.default_font = PixelFont.get_font()
	theme.default_font_size = 18
	screen.theme = theme

	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(bg)

	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 14)
	screen.add_child(column)
	return column


## Fila centrada horizontalmente para agrupar controles sin estirarlos.
static func center_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_theme_constant_override("separation", 12)
	return row


static func label(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", INK)
	return l


static func button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", 20)
	return b
