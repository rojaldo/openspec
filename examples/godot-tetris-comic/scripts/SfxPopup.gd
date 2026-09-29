## SfxPopup.gd — Onomatopeya comic con zoom dinamico.
## Un unico sprite reutilizado: una onomatopeya nueva reinicia la animacion.
extends Node2D
class_name SfxPopup

const TEX: Dictionary = {
	"blam": "res://textures/sfx_blam.png",
	"boom": "res://textures/sfx_boom.png",
	"wham": "res://textures/sfx_wham.png",
	"zap": "res://textures/sfx_zap.png",
	"krak": "res://textures/sfx_krak.png",
	"bam": "res://textures/sfx_bam.png",
	"tetris": "res://textures/sfx_tetris.png",
}

const DURACION := 0.7
## Zoom pronunciado: arranca muy pequeno, pica cerca del techo y se asienta.
## El pico no pasa de 0.9375, que es la escala a la que las onomatopeyas de
## 512 px de tinta (wham, boom) empezarian a recortarse en una pantalla de 480.
const ZOOM_MIN := 0.15
const ZOOM_PICO := 0.93
const ZOOM_FINAL := 0.88

var _sprite: Sprite2D
var _t := 0.0
var _active := false

func _ready() -> void:
	_asegurar_sprite()
	set_process(false)

## Crea el sprite bajo demanda: pop() puede llamarse antes de _ready().
func _asegurar_sprite() -> void:
	if _sprite != null and is_instance_valid(_sprite):
		return
	_sprite = Sprite2D.new()
	_sprite.centered = true
	add_child(_sprite)

## Lanza la onomatopeya indicada. Si ya habia una, la sustituye.
func pop(key: String, at: Vector2 = Vector2.ZERO) -> void:
	_asegurar_sprite()
	var t: String = key if TEX.has(key) else "bam"
	_sprite.texture = load(TEX[t]) as Texture2D
	_sprite.position = at
	_sprite.modulate = Color.WHITE
	_sprite.scale = Vector2.ONE * ZOOM_MIN
	_t = 0.0
	_active = true
	set_process(true)

func _process(delta: float) -> void:
	if not _active:
		return
	_t += delta
	var k := _t / DURACION
	if k >= 1.0:
		_active = false
		_sprite.modulate.a = 0.0
		set_process(false)
		return
	# zoom: entra creciendo rapido hasta pasarse, se asienta, luego se desvanece
	var s: float
	if k < 0.25:
		s = lerp(ZOOM_MIN, ZOOM_PICO, k / 0.25)
	elif k < 0.45:
		s = lerp(ZOOM_PICO, ZOOM_FINAL, (k - 0.25) / 0.20)
	else:
		s = ZOOM_FINAL
	_sprite.scale = Vector2(s, s)
	_sprite.modulate.a = 1.0 - pow(k, 2.0)
