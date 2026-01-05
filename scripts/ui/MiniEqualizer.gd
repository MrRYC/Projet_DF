extends Control

#variables du script
var bus_name: StringName = &"Music"
var effect_index: int = 0
var bars: int = 8
var min_freq_hz: float = 60.0
var max_freq_hz: float = 8000.0
var min_db: float = -60.0  # plus bas = barres plus sensibles
var smooth: float = 12.0   # vitesse de lissage
var bar_gap: float = 1.0
var bar_radius: float = 0.5
var _inst: AudioEffectSpectrumAnalyzerInstance
var bar_levels: PackedFloat32Array

@export var color_green: Color = Color(0.2, 1.0, 0.2, 1.0)
@export var color_yellow: Color = Color(1.0, 1.0, 0.2, 1.0)
@export var color_orange: Color = Color(1.0, 0.6, 0.2, 1.0)
@export var color_red: Color = Color(1.0, 0.2, 0.2, 1.0)

func _ready() -> void:
	custom_minimum_size = Vector2(24, 16)
	bar_levels = PackedFloat32Array()
	bar_levels.resize(max(1, bars))
	
	try_bind()

func _process(delta: float) -> void:
	if _inst == null:
		try_bind()
		return

	update_bar_levels(delta)
	queue_redraw()

func try_bind() -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		push_warning("MiniEqualizer: bus introuvable: %s" % bus_name)
		return

	var ei :int = clamp(effect_index, 0, AudioServer.get_bus_effect_count(bus_idx) - 1)
	_inst = AudioServer.get_bus_effect_instance(bus_idx, ei) as AudioEffectSpectrumAnalyzerInstance
	if _inst == null:
		push_warning("MiniEqualizer: pas de SpectrumAnalyzerInstance sur bus %s à l'index %d" % [bus_name, ei])

func update_bar_levels(delta: float) -> void:
	var freq_range := max_freq_hz - min_freq_hz
	for i in range(bars):
		var t0 := float(i) / float(bars)
		var t1 := float(i + 1) / float(bars)
		var f0 := min_freq_hz + freq_range * t0
		var f1 := min_freq_hz + freq_range * t1

		# magnitude (Vector2) : x = left, y = right
		var mag := _inst.get_magnitude_for_frequency_range(f0, f1)
		var amp :float = max(mag.x, mag.y)

		# Convertit amplitude -> dB
		var db := linear_to_db(max(amp, 0.000001))
		# Normalise 0..1
		var target : float = clamp((db - min_db) / (0.0 - min_db), 0.0, 1.0)

		# Lissage (plus smooth est grand, plus c’est “nerveux” mais stable)
		bar_levels[i] = lerp(bar_levels[i], target, clamp(delta * smooth, 0.0, 1.0))

func color_transition(a: Color, b: Color, t: float) -> Color:
	return Color(
		a.r + (b.r - a.r) * t,
		a.g + (b.g - a.g) * t,
		a.b + (b.b - a.b) * t,
		a.a + (b.a - a.a) * t
	)
	
func palette(t: float) -> Color:
	# t attendu 0..1
	var x: float = t
	if x < 0.0:
		x = 0.0
	elif x > 1.0:
		x = 1.0

	# 0.00-0.33: vert->jaune
	if x < 0.33:
		return color_transition(color_green, color_yellow, x / 0.33)
	# 0.33-0.66: jaune->orange
	elif x < 0.66:
		return color_transition(color_yellow, color_orange, (x - 0.33) / 0.33)
	# 0.66-1.00: orange->rouge
	else:
		return color_transition(color_orange, color_red, (x - 0.66) / 0.34)

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if bars <= 0:
		return

	if _inst == null:
		draw_rect(Rect2(0, 0, w, h), Color(1,1,1,0.25), false)
		return
		
	var total_gap: float = bar_gap * float(bars - 1)
	var bar_w: float = (w - total_gap) / float(bars)
	if bar_w <= 1.0:
		return

	for i in range(bars):
		var level: float = bar_levels[i]
		var bar_h: float = max(2.0, h * level)
		var x: float = float(i) * (bar_w + bar_gap)
		var y: float = h - bar_h
		
		var c: Color = palette(level)
		
		draw_rect(Rect2(x, y, bar_w, bar_h), c, true)

func draw_round_rect(rect: Rect2, _rx: float, _ry: float, color: Color) -> void:
	# draw_style_box est plus “theme friendly” mais ici on garde minimal:
	draw_rect(rect, color, true)
