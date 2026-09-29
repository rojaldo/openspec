extends Control
## Pantalla de puntuaciones: resultado de la partida (con victoria si se
## completo), nombre editable, tabla de mejores con nivel alcanzado y las
## opciones de reintentar o volver al menu.

signal play_requested
signal menu_requested

const Scores = preload("res://scripts/logic/scores.gd")
const Layout = preload("res://scripts/screens/screen_layout.gd")

const MAX_ROWS := 10

var scores = Scores.new()
var entries: Array = []
var entry_id := 0
var final_score := 0
var final_level := 0
var victory := false

var final_label: Label
var name_edit: LineEdit
var table: VBoxContainer


func _ready() -> void:
	var column := Layout.build(self)

	final_label = Layout.label("", 32)
	column.add_child(final_label)

	var name_row := Layout.center_row()
	name_row.add_child(Layout.label("TU NOMBRE:", 18))
	name_edit = LineEdit.new()
	name_edit.max_length = 12
	name_edit.custom_minimum_size = Vector2(200, 0)
	name_edit.text_submitted.connect(_on_name_submitted)
	name_row.add_child(name_edit)
	column.add_child(name_row)

	column.add_child(Layout.label("MEJORES PUNTUACIONES", 20))

	table = VBoxContainer.new()
	table.alignment = BoxContainer.ALIGNMENT_CENTER
	table.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(table)

	var buttons := Layout.center_row()
	var retry := Layout.button("JUGAR OTRA")
	retry.pressed.connect(func(): _commit(); play_requested.emit())
	buttons.add_child(retry)
	var menu := Layout.button("MENU")
	menu.pressed.connect(func(): _commit(); menu_requested.emit())
	buttons.add_child(menu)
	column.add_child(buttons)


## Recibe el resultado de la partida. `completed` indica victoria (los 10).
func show_result(score: int, level_reached: int = 0, completed: bool = false) -> void:
	final_score = score
	final_level = level_reached
	victory = completed
	if victory:
		final_label.text = "VICTORIA! PUNTOS: %d" % score
	else:
		final_label.text = "PUNTOS: %d - NIVEL %d" % [score, level_reached]
	var result: Dictionary = scores.submit("", score, level_reached)
	entry_id = int(result["entry"]["id"])
	entries = result["entries"]
	_refresh_table()


func _on_name_submitted(_text: String) -> void:
	_commit()


func _commit() -> void:
	if entry_id == 0:
		return
	entries = scores.rename(entry_id, name_edit.text)
	_refresh_table()


func _refresh_table() -> void:
	for child in table.get_children():
		child.queue_free()
	if entries.is_empty():
		table.add_child(Layout.label("Todavia no hay puntuaciones", 18))
		return
	for i in mini(entries.size(), MAX_ROWS):
		var e: Dictionary = entries[i]
		var lvl := int(e.get("level", 0))
		var suffix := "  N%d" % lvl if lvl > 0 else ""
		table.add_child(Layout.label("%d. %s .... %d%s" % [i + 1, str(e["name"]), int(e["score"]), suffix], 18))
