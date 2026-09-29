extends RefCounted
## Fuente de pixeles 5x7 construida por codigo: es parte del proyecto, no
## un asset externo. Cada tamano usa una cache bitmap con escala entera,
## de modo que los bordes quedan nitidos como en una pantalla LCD.

const GLYPH_W := 5
const GLYPH_H := 7
const COLS := 16

## Tamanos que usa la interfaz. Cada uno tiene su propia cache.
const SIZES := [14, 16, 18, 20, 24, 32, 48]

const GLYPHS := {
	" ": ["00000", "00000", "00000", "00000", "00000", "00000", "00000"],
	"!": ["00100", "00100", "00100", "00100", "00100", "00000", "00100"],
	"%": ["11001", "11010", "00010", "00100", "01000", "01011", "10011"],
	"(": ["00010", "00100", "01000", "01000", "01000", "00100", "00010"],
	")": ["01000", "00100", "00010", "00010", "00010", "00100", "01000"],
	"*": ["00000", "10101", "01110", "11111", "01110", "10101", "00000"],
	"+": ["00000", "00100", "00100", "11111", "00100", "00100", "00000"],
	",": ["00000", "00000", "00000", "00000", "01100", "00100", "01000"],
	"-": ["00000", "00000", "00000", "11111", "00000", "00000", "00000"],
	".": ["00000", "00000", "00000", "00000", "00000", "01100", "01100"],
	"/": ["00001", "00010", "00010", "00100", "01000", "01000", "10000"],
	"0": ["01110", "10001", "10011", "10101", "11001", "10001", "01110"],
	"1": ["00100", "01100", "00100", "00100", "00100", "00100", "01110"],
	"2": ["01110", "10001", "00001", "00010", "00100", "01000", "11111"],
	"3": ["11111", "00010", "00100", "00010", "00001", "10001", "01110"],
	"4": ["00010", "00110", "01010", "10010", "11111", "00010", "00010"],
	"5": ["11111", "10000", "11110", "00001", "00001", "10001", "01110"],
	"6": ["00110", "01000", "10000", "11110", "10001", "10001", "01110"],
	"7": ["11111", "00001", "00010", "00100", "01000", "01000", "01000"],
	"8": ["01110", "10001", "10001", "01110", "10001", "10001", "01110"],
	"9": ["01110", "10001", "10001", "01111", "00001", "00010", "01100"],
	":": ["00000", "01100", "01100", "00000", "01100", "01100", "00000"],
	"=": ["00000", "00000", "11111", "00000", "11111", "00000", "00000"],
	"?": ["01110", "10001", "00001", "00010", "00100", "00000", "00100"],
	"A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
	"B": ["11110", "10001", "10001", "11110", "10001", "10001", "11110"],
	"C": ["01110", "10001", "10000", "10000", "10000", "10001", "01110"],
	"D": ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
	"E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
	"F": ["11111", "10000", "10000", "11110", "10000", "10000", "10000"],
	"G": ["01110", "10001", "10000", "10111", "10001", "10001", "01111"],
	"H": ["10001", "10001", "10001", "11111", "10001", "10001", "10001"],
	"I": ["01110", "00100", "00100", "00100", "00100", "00100", "01110"],
	"J": ["00111", "00010", "00010", "00010", "00010", "10010", "01100"],
	"K": ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
	"L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
	"M": ["10001", "11011", "10101", "10101", "10001", "10001", "10001"],
	"N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
	"O": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
	"P": ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
	"Q": ["01110", "10001", "10001", "10001", "10101", "10010", "01101"],
	"R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
	"S": ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
	"T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
	"U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
	"V": ["10001", "10001", "10001", "10001", "10001", "01010", "00100"],
	"W": ["10001", "10001", "10001", "10101", "10101", "11011", "10001"],
	"X": ["10001", "10001", "01010", "00100", "01010", "10001", "10001"],
	"Y": ["10001", "10001", "01010", "00100", "00100", "00100", "00100"],
	"Z": ["11111", "00001", "00010", "00100", "01000", "10000", "11111"],
	"_": ["00000", "00000", "00000", "00000", "00000", "00000", "11111"],
	"Ñ": ["01110", "00000", "10001", "11001", "10101", "10011", "10001"],
	"Á": ["00100", "01110", "10001", "11111", "10001", "10001", "10001"],
	"É": ["00100", "11111", "10000", "11110", "10000", "10000", "11111"],
	"Í": ["00100", "01110", "00100", "00100", "00100", "00100", "01110"],
	"Ó": ["00100", "01110", "10001", "10001", "10001", "10001", "01110"],
	"Ú": ["00100", "10001", "10001", "10001", "10001", "10001", "01110"],
}

static var _cached: FontFile = null


## Devuelve la fuente de pixeles, construida una sola vez.
static func get_font() -> FontFile:
	if _cached == null:
		_cached = build()
	return _cached


static func build() -> FontFile:
	var font := FontFile.new()
	font.set_antialiasing(TextServer.FONT_ANTIALIASING_NONE)
	font.set_allow_system_fallback(true)
	var chars: Array = GLYPHS.keys()
	chars.sort()
	var rows := ceili(float(chars.size()) / float(COLS))
	for size in SIZES:
		_build_cache(font, size, maxi(1, int(size / GLYPH_H)), chars, rows)
	return font


static func _build_cache(font: FontFile, size: int, scale: int, chars: Array, rows: int) -> void:
	var cell_w := (GLYPH_W + 1) * scale
	var cell_h := (GLYPH_H + 1) * scale
	var atlas := Image.create_empty(COLS * cell_w, rows * cell_h, false, Image.FORMAT_RGBA8)
	atlas.fill(Color(0, 0, 0, 0))
	var vector_size := Vector2i(size, 0)

	for i in chars.size():
		var glyph: String = chars[i]
		var col := i % COLS
		var row := floori(float(i) / float(COLS))
		var origin_x := col * cell_w
		var origin_y := row * cell_h
		var pattern: Array = GLYPHS[glyph]
		for py in GLYPH_H:
			var line: String = pattern[py]
			for px in GLYPH_W:
				if line[px] != "1":
					continue
				for dy in scale:
					for dx in scale:
						atlas.set_pixel(origin_x + px * scale + dx, origin_y + py * scale + dy, Color.WHITE)

		# La pantalla del Nokia mostraba todo en mayusculas: las minusculas
		# se mapean al mismo glifo, para que el texto no caiga al tipo del
		# sistema ni rompa el aspecto LCD.
		var codes: Array[int] = [glyph.unicode_at(0)]
		var lower := glyph.to_lower()
		if lower != glyph:
			codes.append(lower.unicode_at(0))
		for code in codes:
			font.set_glyph_texture_idx(0, vector_size, code, 0)
			font.set_glyph_uv_rect(0, vector_size, code, Rect2(origin_x, origin_y, GLYPH_W * scale, GLYPH_H * scale))
			font.set_glyph_size(0, vector_size, code, Vector2(GLYPH_W * scale, GLYPH_H * scale))
			# El glifo se dibuja sobre la baseline: su tope va a -ascent para
			# que quepa dentro de la caja de linea (si no, las lineas se solapan).
			font.set_glyph_offset(0, vector_size, code, Vector2(0, -GLYPH_H * scale))
			font.set_glyph_advance(0, size, code, Vector2(cell_w, 0))

	font.set_texture_image(0, vector_size, 0, atlas)
	font.set_cache_ascent(0, size, float(GLYPH_H * scale))
	font.set_cache_descent(0, size, 0.0)
