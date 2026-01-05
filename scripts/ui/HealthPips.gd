extends Control
class_name HealthPips

#variables du script
var max_hp: int = 10
var current_hp: int = 10
var pending_damage: int = 0
var pending_block: int = 0
var pip_height: float = 10.0
var min_pip_width: float = 4.0
var max_pip_width: float = 20.0
var pip_gap: float = 1.0
var outline: bool = true
var color_full: Color = Color(0, 0.7, 0.7, 1.0)
var color_empty: Color = Color(1, 1, 1, 0.2)
var color_preview: Color = Color(0.8, 0.1, 0, 1)
var color_block: Color = Color(0, 0.2, 0.9, 1)
var color_dodge: Color = Color(0.0, 0.7, 0.7, 0.4)
var blink_speed: float = 2.0      # plus grand = clignote plus vite
var blink_min_alpha: float = 0.55 # intensité minimale
var blink: float = 0.0

func _process(delta: float) -> void:
	#Animation de blinl si on a une preview
	if pending_damage > 0:
		blink += delta * blink_speed
		queue_redraw()

func set_health(new_current: int, new_max: int = -1) -> void:
	if new_max >= 0:
		max_hp = max(0, new_max)
	current_hp = clampi(new_current, 0, max_hp)
	queue_redraw()

func set_preview_damage(dmg: int) -> void:
	var old: int = pending_damage
	pending_damage = max(0, dmg)
	if old == 0 and pending_damage > 0:
		blink = 0.0
	if pending_damage == 0:
		blink = 0.0
	queue_redraw()

func set_preview_block(block):
	pending_block = max(0, block)
	queue_redraw()

func clear_preview() -> void:
	pending_damage = 0
	blink = 0.0
	queue_redraw()

func _draw() -> void:
	if max_hp <= 0:
		return
	
	#calcul dynamique de la taille des pips de point de vie
	var width : float = size.x
	var height : float = size.y
	
	if width <= 1.0 or height <= 1.0:
		return
	
	var total_gap: float = float(max_hp - 1) * pip_gap
	if width <= total_gap:
		return
	var pip_w: float = (width - total_gap) / float(max_hp)
	
	# Clamp pour rester lisible
	if pip_w < min_pip_width:
		pip_w = min_pip_width
	elif pip_w > max_pip_width:
		pip_w = max_pip_width
	
	# Recalcul de largeur réelle des pips et centrage
	var total_w: float = float(max_hp) * pip_w + total_gap
	var start_x: float = (width - total_w) * 0.5
	if start_x < 0.0:
		start_x = 0.0
	
	var y: float = (height - pip_height) * 0.5
	
	# Calcule combien de pips seront "marqués" en preview (sur les derniers HP)
	var damage_preview: int = pending_damage
	if damage_preview > current_hp:
		damage_preview = current_hp

	var block_preview: int = pending_block
	if block_preview > damage_preview:
		block_preview = damage_preview
	
	var preview_start: int = current_hp - damage_preview
	#var preview_end: int = current_hp - 1

	#Coloration des pips des dégâts bloqués
	var blocked_start: int = current_hp - block_preview
	var blocked_end: int = current_hp - 1
	
	#Coloration des pips des dégâts bloqués
	var damaged_start: int = preview_start
	var damaged_end: int = blocked_start - 1

	#Scientillement des dégats
	var preview_alpha: float = 1.0
	if pending_damage > 0:
		var s: float = (sin(blink) + 1.0) * 0.5
		preview_alpha = blink_min_alpha + (1.0 - blink_min_alpha) * s

	for i in range(max_hp):
		var x: float = start_x + float(i) * (pip_w + pip_gap)
		var rect := Rect2(x, y, pip_w, pip_height)

		var c: Color = color_full if i < current_hp else color_empty

		if i >= damaged_start and i <= damaged_end:
			c = Color(color_preview.r, color_preview.g, color_preview.b, preview_alpha)
		elif i >= blocked_start and i <= blocked_end:
			c = Color(color_block.r, color_block.g, color_block.b, preview_alpha)

		draw_rect(rect, c, true)

		if outline:
			draw_rect(rect, Color(0, 0, 0, 0.35), false)
