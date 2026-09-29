## line_subject.gd — PATRÓN 4: OBSERVER (sujeto observable).
##
## Responsabilidad ÚNICA e intransferible:
##   "Se notifica cuando hay una línea eliminada y actualiza el score y el
##    contador de líneas."
##
## Este script es el SUJETO (Subject): mantiene la lista de observadores y les
## notifica el hecho "se eliminó una línea". Los observadores son quienes
## reaccionan (el score, el HUD, los efectos). El sujeto NO calcula puntos:
## solo avisa. Ver score_observer.gd para el observador concreto de puntuación.
class_name LineSubject
extends RefCounted

## Observadores registrados. Duck-typing: cualquier objeto con
## `on_lines_cleared(count, is_tetris)` vale como observador.
var observers: Array = []

func attach(observer: Object) -> void:
	if observer != null and not observers.has(observer):
		observers.append(observer)

func detach(observer: Object) -> void:
	observers.erase(observer)

## Notifica a todos los observadores del hecho "se eliminaron N filas".
func notify_lines_cleared(count: int, is_tetris: bool) -> void:
	for o in observers.duplicate():
		if o == null or not is_instance_valid(o):
			observers.erase(o)
			continue
		if o.has_method("on_lines_cleared"):
			o.on_lines_cleared(count, is_tetris)
