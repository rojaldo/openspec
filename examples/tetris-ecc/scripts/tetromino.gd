## tetromino.gd — Catálogo de datos de las 7 piezas (NO es un patrón).
##
## Aquí solo viven los datos compartidos: tipos, formas, colores y texturas.
## El patrón Factory (piece_factory.gd) es quien CONSTRUYE la pieza con estos datos.
## Mantener los datos separados de la creación evita que Factory conozca detalles
## de dibujo y que la vista conozca reglas de juego.
class_name Tetromino
extends RefCounted

## Orden clásico de las 7 piezas.
const TYPES: Array[String] = ["I", "O", "T", "S", "Z", "J", "L"]

## Color de tinta/comic por pieza (coincide con los PNG del pack).
const COLOR: Dictionary = {
	"I": Color("#3ec9f0"),
	"O": Color("#ffd93d"),
	"T": Color("#b06cff"),
	"S": Color("#4fd06a"),
	"Z": Color("#e8432f"),
	"J": Color("#2f7de8"),
	"L": Color("#ff9f2f"),
}

## Textura de bloque a 32 px (tamaño nativo del pack = tamaño de celda del juego).
## Se usa el PNG *_32.png del pack porque la celda mide 32 px: nítido y sin escalar.
const BLOCK_TEX: Dictionary = {
	"I": "res://textures/block_I_32.png",
	"O": "res://textures/block_O_32.png",
	"T": "res://textures/block_T_32.png",
	"S": "res://textures/block_S_32.png",
	"Z": "res://textures/block_Z_32.png",
	"J": "res://textures/block_J_32.png",
	"L": "res://textures/block_L_32.png",
}

## Icono de la pieza ensamblada (para el panel NEXT del HUD).
const PIECE_TEX: Dictionary = {
	"I": "res://textures/piece_I.png",
	"O": "res://textures/piece_O.png",
	"T": "res://textures/piece_T.png",
	"S": "res://textures/piece_S.png",
	"Z": "res://textures/piece_Z.png",
	"J": "res://textures/piece_J.png",
	"L": "res://textures/piece_L.png",
}

## Matrices de spawn (SRS-lite). La rotación gira la matriz completa NxN.
const SHAPES: Dictionary = {
	"I": [[0,0,0,0],[1,1,1,1],[0,0,0,0],[0,0,0,0]],
	"O": [[1,1],[1,1]],
	"T": [[0,1,0],[1,1,1],[0,0,0]],
	"S": [[0,1,1],[1,1,0],[0,0,0]],
	"Z": [[1,1,0],[0,1,1],[0,0,0]],
	"J": [[1,0,0],[1,1,1],[0,0,0]],
	"L": [[0,0,1],[1,1,1],[0,0,0]],
}

## Copia de la matriz de spawn de un tipo.
static func shape(type: String) -> Array:
	return _clone(SHAPES[type])

## Rota una matriz NxN 90° (horario por defecto).
static func rotate_matrix(m: Array, clockwise: bool = true) -> Array:
	var n := m.size()
	var out := []
	for r in range(n):
		var row := []
		for c in range(n):
			row.append(0)
		out.append(row)
	for r in range(n):
		for c in range(n):
			if clockwise:
				out[c][n - 1 - r] = m[r][c]
			else:
				out[n - 1 - c][r] = m[r][c]
	return out

static func color_of(type: String) -> Color:
	return COLOR[type]

## Textura de bloque cacheada por tipo.
static func block_texture(type: String) -> Texture2D:
	return load(BLOCK_TEX[type]) as Texture2D

static func piece_texture(type: String) -> Texture2D:
	return load(PIECE_TEX[type]) as Texture2D

static func _clone(m: Array) -> Array:
	var o := []
	for row in m:
		o.append(row.duplicate())
	return o
