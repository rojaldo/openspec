## score_observer.gd — PATRÓN 4: OBSERVER (observador de puntuación).
##
## Responsabilidad ÚNICA e intransferible:
##   "Se notifica cuando hay una línea eliminada y actualiza el score y el
##    contador de líneas."
##
## Es un OBSERVADOR concreto: escucha al LineSubject y actualiza score/líneas/nivel.
##
## Puntuación (decisión razonada, estándar Tetris):
##   1 fila=100, 2=300, 3=500, 4 (tetris)=800, multiplicado por el nivel.
##   Nivel = 1 + líneas/10 (sube la velocidad en el controlador).
class_name ScoreObserver
extends RefCounted

const POINTS := {1: 100, 2: 300, 3: 500, 4: 800}

var score := 0
var lines := 0
var level := 1

## Callback del patrón Observer: lo invoca LineSubject.notify_lines_cleared().
func on_lines_cleared(count: int, _is_tetris: bool) -> void:
	if count <= 0:
		return
	# Puntuación: cubos de 4 (por si en el futuro entran 5+ filas de golpe).
	var remaining := count
	var gained := 0
	while remaining > 0:
		var chunk := mini(remaining, 4)
		gained += POINTS.get(chunk, 800)
		remaining -= chunk
	score += gained * level
	lines += count
	level = 1 + lines / 10
