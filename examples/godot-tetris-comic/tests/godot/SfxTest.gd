## SfxTest.gd — Zoom dinamico y reutilizacion de la onomatopeya (5.3, 5.4).
## Ejecutar: godot --headless --script tests/godot/SfxTest.gd
extends SceneTree

var _fallos := 0

func _initialize() -> void:
	_test_un_solo_sprite()
	_test_zoom_crece_y_se_asienta()
	_test_recorrido_pronunciado()
	_test_pico_no_recorta()
	_test_desvanece()
	_test_reinicia_al_repetir()
	_test_claves()
	if _fallos == 0:
		print("SfxTest OK")
	else:
		print("SfxTest FALLOS: ", _fallos)
	quit(_fallos)

func _err(m: String) -> void:
	push_error(m)
	_fallos += 1

func _nuevo() -> SfxPopup:
	var s := SfxPopup.new()
	root.add_child(s)
	return s

func _avanzar(s: SfxPopup, seg: float) -> void:
	var paso := 1.0 / 60.0
	var t := 0.0
	while t < seg:
		s._process(paso)
		t += paso

func _escala(s: SfxPopup) -> float:
	return s._sprite.scale.x

func _alpha(s: SfxPopup) -> float:
	return s._sprite.modulate.a

func _test_un_solo_sprite() -> void:
	var s := _nuevo()
	s.pop("bam")
	s.pop("wham")
	s.pop("tetris")
	var sprites := 0
	for c in s.get_children():
		if c is Sprite2D:
			sprites += 1
	if sprites != 1:
		_err("deberia haber 1 solo sprite reutilizado, hay %d" % sprites)
		return
	print("  5.3 un solo sprite reutilizado")

func _test_zoom_crece_y_se_asienta() -> void:
	var s := _nuevo()
	s.pop("bam")
	var inicio := _escala(s)
	_avanzar(s, SfxPopup.DURACION * 0.24)
	var pico := _escala(s)
	if pico <= inicio:
		_err("el zoom deberia crecer (inicio %f, pico %f)" % [inicio, pico])
		return
	if absf(pico - SfxPopup.ZOOM_PICO) > 0.02:
		_err("el pico deberia acercarse a ZOOM_PICO, es %f" % pico)
		return
	_avanzar(s, SfxPopup.DURACION * 0.15)
	var asentado := _escala(s)
	if absf(asentado - SfxPopup.ZOOM_FINAL) > 0.02:
		_err("deberia asentarse en ZOOM_FINAL, es %f" % asentado)
		return
	print("  5.3 zoom: %0.2f -> %0.2f -> %0.2f" % [inicio, pico, asentado])

## El recorrido debe ser pronunciado, no un cambio sutil.
func _test_recorrido_pronunciado() -> void:
	var ratio := SfxPopup.ZOOM_PICO / SfxPopup.ZOOM_MIN
	if ratio < 3.0:
		_err("el zoom deberia multiplicar el tamano inicial por 3 o mas, es %0.2f" % ratio)
		return
	print("  5.3 recorrido del zoom: x%0.1f" % ratio)

## Las onomatopeyas de 512 px de tinta (wham, boom) no deben recortarse.
func _test_pico_no_recorta() -> void:
	const TINTA_MAX := 512.0
	const PANTALLA := 480.0
	var ancho_pico := TINTA_MAX * SfxPopup.ZOOM_PICO
	if ancho_pico > PANTALLA:
		_err("a pico la tinta mediria %0.1f px y la pantalla es %0.0f" % [ancho_pico, PANTALLA])
		return
	print("  5.3 a pico la tinta mayor mide %0.0f de %0.0f px" % [ancho_pico, PANTALLA])

func _test_desvanece() -> void:
	var s := _nuevo()
	s.pop("bam")
	_avanzar(s, SfxPopup.DURACION * 0.5)
	var medio := _alpha(s)
	if medio >= 1.0:
		_err("a mitad de animacion ya deberia estar desvaneciendo")
		return
	_avanzar(s, SfxPopup.DURACION)
	if _alpha(s) != 0.0:
		_err("al terminar deberia quedar invisible")
		return
	print("  5.3 desvanece y desaparece")

func _test_reinicia_al_repetir() -> void:
	var s := _nuevo()
	s.pop("bam")
	_avanzar(s, SfxPopup.DURACION * 0.5)
	var antes := _alpha(s)
	s.pop("tetris")
	if _alpha(s) < antes or absf(_escala(s) - SfxPopup.ZOOM_MIN) > 0.001:
		_err("una onomatopeya nueva deberia reiniciar la animacion (alpha %f, escala %f)" % [_alpha(s), _escala(s)])
		return
	print("  5.3 limpiar lineas seguidas reinicia, no apila")

func _test_claves() -> void:
	var s := _nuevo()
	if not SfxPopup.TEX.has("tetris"):
		_err("deberia existir la clave tetris")
		return
	var claves := SfxPopup.TEX.keys()
	if claves.size() < 4:
		_err("deberia haber varias onomatopeyas para jugadas menores")
		return
	print("  5.4 %d onomatopeyas, tetris distinguido" % claves.size())
