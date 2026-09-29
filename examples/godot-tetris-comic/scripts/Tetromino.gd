## Tetromino.gd — Definición de las 7 piezas con estética comic.
## Úsalo como catálogo estático: colores, formas y texturas (bloques).
class_name Tetromino
extends RefCounted

## Orden clásico de spawn.
const TYPES: Array[String] = ["I", "O", "T", "S", "Z", "J", "L"]

## Color de tinta/comic por pieza (coincide con los PNG generados).
const COLOR: Dictionary = {
	"I": Color("#3ec9f0"),
	"O": Color("#ffd93d"),
	"T": Color("#b06cff"),
	"S": Color("#4fd06a"),
	"Z": Color("#e8432f"),
	"J": Color("#2f7de8"),
	"L": Color("#ff9f2f"),
}

## Ruta de la textura de bloque (64px) por pieza.
const BLOCK_TEX: Dictionary = {
	"I": "res://textures/block_I_64.png",
	"O": "res://textures/block_O_64.png",
	"T": "res://textures/block_T_64.png",
	"S": "res://textures/block_S_64.png",
	"Z": "res://textures/block_Z_64.png",
	"J": "res://textures/block_J_64.png",
	"L": "res://textures/block_L_64.png",
}

## Máscaras de rotación (SRS-lite): matriz 2D de cada pieza.
## Fila x columna. Usamos las matrices de spawn; la rotación se hace
## girando la matriz en código (ver rotate_matrix).
const SHAPES: Dictionary = {
	"I": [[0,0,0,0],[1,1,1,1],[0,0,0,0],[0,0,0,0]],
	"O": [[1,1],[1,1]],
	"T": [[0,1,0],[1,1,1],[0,0,0]],
	"S": [[0,1,1],[1,1,0],[0,0,0]],
	"Z": [[1,1,0],[0,1,1],[0,0,0]],
	"J": [[1,0,0],[1,1,1],[0,0,0]],
	"L": [[0,0,1],[1,1,1],[0,0,0]],
}

## Devuelve una copia de la matriz de la pieza.
static func shape(type: String) -> Array:
	return _clone(SHAPES[type])

## Rota una matriz NxN 90° en sentido horario.
static func rotate_matrix(m: Array, clockwise: bool = true) -> Array:
	var n := m.size()
	var out := []
	for r in range(n):
		out.append([])
		for c in range(n):
			out[r].append(0)
	for r in range(n):
		for c in range(n):
			if clockwise:
				out[c][n - 1 - r] = m[r][c]
			else:
				out[n - 1 - c][r] = m[r][c]
	return out

## Color de una pieza.
static func color_of(type: String) -> Color:
	return COLOR[type]

## Carga (cacheada por Godot) la textura de bloque de una pieza.
static func block_texture(type: String) -> Texture2D:
	return load(BLOCK_TEX[type]) as Texture2D

## Sprite del tetromino ya ensamblado (para el panel de siguiente pieza).
static func piece_texture(type: String) -> Texture2D:
	return load("res://textures/piece_%s.png" % type) as Texture2D

static func _clone(m: Array) -> Array:
	var o := []
	for row in m:
		o.append(row.duplicate())
	return o
