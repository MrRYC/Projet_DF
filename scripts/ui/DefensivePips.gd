extends Control
class_name DefensivePips

#variables des pips défensifs
var charges: int = 0
var pip_height: float = 6.0
var min_pip_width: float = 4.0
var max_pip_width: float = 20.0
var pip_gap: float = 1.0
var outline: bool = true
var color_block: Color = Color(0, 0.2, 0.9, 1)
var color_dodge: Color = Color(0.0, 0.7, 0.7, 0.4)

func _ready() -> void:
	custom_minimum_size = Vector2(0.0, pip_height)

func set_charges(value: int) -> void:
	charges = value
	queue_redraw()

func clear() -> void:
	charges = 0
	queue_redraw()

func _draw() -> void:
	if charges <= 0:
		return

	var width: float = size.x
	var height: float = size.y
	if width <= 1.0 or height <= 1.0:
		return

	var total_gap: float = float(charges - 1) * pip_gap
	if width <= total_gap:
		return

	var pip_w: float = (width - total_gap) / float(charges)
	if pip_w < min_pip_width:
		pip_w = min_pip_width
	elif pip_w > max_pip_width:
		pip_w = max_pip_width

	var total_w: float = float(charges) * pip_w + total_gap
	var start_x: float = (width - total_w) * 0.5
	if start_x < 0.0:
		start_x = 0.0

	var y: float = (height - pip_height) * 0.5

	for i in range(charges):
		var x: float = start_x + float(i) * (pip_w + pip_gap)
		var rect := Rect2(x, y, pip_w, pip_height)
		draw_rect(rect, color_block, true)
		if outline:
			draw_rect(rect, Color(0, 0, 0, 0.35), false)
