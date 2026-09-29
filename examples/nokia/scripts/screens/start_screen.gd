extends Control
## Pantalla de inicio: titulo, empezar partida y elegir nivel.

signal play_requested
signal select_level_requested

const Layout = preload("res://scripts/screens/screen_layout.gd")


func _ready() -> void:
	var column := Layout.build(self)
	column.add_child(Layout.label("NOKIA SNAKE", 48))
	column.add_child(Layout.label("Comer cocos, crecer y no morderse", 16))

	var row := Layout.center_row()
	var play := Layout.button("EMPEZAR PARTIDA")
	play.pressed.connect(func(): play_requested.emit())
	row.add_child(play)
	var select := Layout.button("ELEGIR NIVEL")
	select.pressed.connect(func(): select_level_requested.emit())
	row.add_child(select)
	column.add_child(row)

	column.add_child(Layout.label("Flechas o WASD para moverte", 14))
