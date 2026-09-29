## sfx_popup.gd — Onomatopeya comic animada (efecto visual, no es un patrón).
##
## Muestra un PNG `sfx_*.png` del pack con animación "squash & pop" cuando se
## eliminan líneas. Lo dispara el controlador al recibir la señal del modelo.
extends Node2D
class_name SfxPopup

const TEX := {
	"bam": "res://textures/sfx_bam.png",
	"blam": "res://textures/sfx_blam.png",
	"boom": "res://textures/sfx_boom.png",
	"krak": "res://textures/sfx_krak.png",
	"tetris": "res://textures/sfx_tetris.png",
	"wham": "res://textures/sfx_wham.png",
	"zap": "res://textures/sfx_zap.png",
}
const KEYS := ["bam", "blam", "boom", "krak", "wham", "zap"]

@export var duration := 0.7
@export var rise_px := 40.0

var _sprite: Sprite2D
var _t := 0.0
var _active := false
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_sprite = Sprite2D.new()
	_sprite.centered = true
	add_child(_sprite)
	set_process(false)

## Lanza la onomatopeya. Con `key`="tetris" usa la palabra TETRIS!;
## con "random" elige una de las 6 onomatopeyas al azar (estilo comic).
func pop(key: String, at: Vector2 = Vector2.ZERO) -> void:
	var t := key
	if key == "random":
		t = KEYS[_rng.randi_range(0, KEYS.size() - 1)]
	if not TEX.has(t):
		t = "bam"
	_sprite.texture = load(TEX[t]) as Texture2D
	_sprite.position = at
	_sprite.modulate = Color.WHITE
	_sprite.scale = Vector2(0.6, 0.6)
	_t = 0.0
	_active = true
	set_process(true)

func _process(delta: float) -> void:
	if not _active:
		return
	_t += delta
	var k := _t / duration
	if k >= 1.0:
		_active = false
		_sprite.modulate.a = 0.0
		set_process(false)
		return
	var s := 1.0
	if k < 0.25:
		s = lerp(0.6, 1.15, k / 0.25)
	elif k < 0.5:
		s = lerp(1.15, 1.0, (k - 0.25) / 0.25)
	_sprite.scale = Vector2(s, s)
	_sprite.position.y -= rise_px * delta
	_sprite.modulate.a = 1.0 - pow(k, 2.0)
