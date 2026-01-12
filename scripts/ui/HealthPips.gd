extends Control
class_name HealthPips

@onready var defensive_pips = $DefensivePips

#variables des points de vie
var max_hp: int = 0
var current_hp: int = 0
var pip_height: float = 10.0
var min_pip_width: float = 4.0
var max_pip_width: float = 20.0
var pip_gap: float = 1.0
var outline: bool = true
var color_full: Color = Color(0, 0.7, 0.7, 1.0)
var color_empty: Color = Color(1, 1, 1, 0.2)

#variables des dégats
var pending_damage: int = 0
var color_damage: Color = Color(0.8, 0.1, 0, 1)
var blink_speed: float = 2.0      # plus grand = clignote plus vite
var blink_min_alpha: float = 0.25 # intensité minimale
var blink: float = 0.0

func _process(delta: float) -> void:
	#Animation de blink si on a une preview
	if pending_damage > 0:
		blink += delta * blink_speed
		queue_redraw()

func set_health(new_current: int, new_max: int = -1) -> void:
	if new_max >= 0:
		max_hp = max(0, new_max)
	#current_hp = clampi(new_current, 0, max_hp)
	current_hp = new_current
	queue_redraw()

###########################################################################
#                                DRAW PIPS                                #
###########################################################################

func _draw() -> void:
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
	var base_hp: int = clampi(current_hp, 0, max_hp)
	var damage_preview = clampi(pending_damage, 0, base_hp)
	var preview_start: int = base_hp - damage_preview
	var preview_end: int = base_hp - 1

	#Scientillement des dégats
	var preview_alpha: float = 1.0
	if pending_damage > 0:
		var s: float = (sin(blink) + 1.0) * 0.5
		preview_alpha = blink_min_alpha + (1.0 - blink_min_alpha) * s

	for i in range(max_hp):
		var x: float = start_x + float(i) * (pip_w + pip_gap)
		var rect := Rect2(x, y, pip_w, pip_height)

		var c: Color 
		if i < base_hp:
			c = color_full
		else :
			c = color_empty

		if damage_preview > 0 and i >= preview_start and i <= preview_end and i < base_hp:
			c = Color(color_damage.r, color_damage.g, color_damage.b, preview_alpha)

		draw_rect(rect, c, true)

		if outline:
			draw_rect(rect, Color(0, 0, 0, 0.35), false)

###########################################################################
#                          HEALTH PIPS MANAGEMENT                         #
###########################################################################

func set_preview_damage(damage: int) -> void:
	pending_damage = max(0, damage)
	blink = 0.0
	queue_redraw()

func consume_damage_preview(damage: int, has_block: bool) -> void:
	if pending_damage <= 0:
		return

	if has_block:
		blink = 0.0
	else:
		var hp_damage :int = max(0, damage)
		if hp_damage <= 0:
			return
		
		pending_damage = max(0, pending_damage - hp_damage)

	queue_redraw()

###########################################################################
#                          BLOCK PIPS MANAGEMENT                         #
###########################################################################

func set_block_charges(charges: int) -> void:
	defensive_pips.set_charges(charges)

func set_block_preview_broken(count: int) -> void:
	defensive_pips.set_broken_block(count)

###########################################################################
#                          CLEAR PREVIEWED PIPS                           #
###########################################################################

func clear_previewed_damage() -> void:
		defensive_pips.set_broken_block(0)
		pending_damage = 0
		blink = 0.0
		queue_redraw()
