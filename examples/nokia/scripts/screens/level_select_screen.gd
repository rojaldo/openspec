extends Control
## Selector de nivel: los diez niveles como botones, todos disponibles, y
## una opcion para volver al inicio. Se llega desde la pantalla de inicio.

signal level_chosen(index: int)
signal back_requested

const Levels = preload("res://scripts/logic/levels.gd")
const Layout = preload("res://scripts/screens/screen_layout.gd")

const COLUMNS := 5

var level_buttons: Array[Button] = []


func _ready() -> void:
	var column := Layout.build(self)
	column.add_child(Layout.label("ELIGE NIVEL", 40))

	var grid := GridContainer.new()
	grid.columns = COLUMNS
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(grid)

	for i in Levels.count():
		var lvl = Levels.at(i)
		var btn := Layout.button("%d · %d" % [i + 1, lvl.target])
		btn.custom_minimum_size = Vector2(84, 0)
		btn.pressed.connect(func(): level_chosen.emit(i))
		grid.add_child(btn)
		level_buttons.append(btn)

	var row := Layout.center_row()
	var back := Layout.button("VOLVER")
	back.pressed.connect(func(): back_requested.emit())
	row.add_child(back)
	column.add_child(row)
