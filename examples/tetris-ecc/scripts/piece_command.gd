## piece_command.gd — PATRÓN 6: COMMAND (comunicación con el canvas).
##
## Responsabilidad ÚNICA e intransferible:
##   "Es el que comunica al canvas cuál es la siguiente pieza que va a caer."
##
## El controlador NO habla directamente con la vista para decirle la pieza
## siguiente: encapsula esa petición como un objeto Command con un receptor
## (el canvas/vista) y un argumento (el tipo de pieza). Ejecutarlo provoca la
## actualización del panel NEXT del canvas. Así, "informar de la siguiente pieza"
## es un objeto reutilizable y desacoplado.
class_name SetNextPieceCommand
extends RefCounted

var _receiver: Object   ## El "canvas" (BoardView) u otro receptor con set_next_piece().
var _piece_type: String

func _init(receiver: Object, piece_type: String) -> void:
	_receiver = receiver
	_piece_type = piece_type

## Ejecuta el comando: comunica al canvas la siguiente pieza.
func execute() -> void:
	if _receiver != null and is_instance_valid(_receiver) and _receiver.has_method("set_next_piece"):
		_receiver.set_next_piece(_piece_type)

func piece_type() -> String:
	return _piece_type
