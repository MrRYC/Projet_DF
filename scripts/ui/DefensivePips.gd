extends Control
class_name DefensivePips

#variables du script
var entity: Node = null
var is_new_card_in_action_zone: bool = false
var is_resolving_action_zone: bool = false
var charges: int = 0
var pip_height: float = 6.0
var min_pip_width: float = 4.0
var max_pip_width: float = 20.0
var pip_gap: float = 1.0
var outline: bool = true
var broken_pips_count: int = 0

var color_block_activated: Color = Color(0, 0.2, 0.9, 1)
var color_dodge_activated: Color = Color(0.5, 0.4, 0.8, 1.0)
var color_feint_activated: Color = Color(0.86, 0.312, 0.103, 1.0)
var color_broken_pip: Color = Color(0.5, 0.5, 0.5, 1.0)

var defensive_action_queue: Array[Dictionary] = []

func _ready() -> void:
	EventBus.processing.connect(_on_action_zone_resolving)
	EventBus.player_defensive_actions_preview.connect(_on_player_defensive_action_preview)

	custom_minimum_size = Vector2(0.0, pip_height)

func set_charges(value: int) -> void:
	charges = value
	queue_redraw()

func set_broken_block(count: int) -> void:
	broken_pips_count = max(count, 0)
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

	#gestion des pips grisés
	var broken:int = clamp(broken_pips_count, 0, charges)
	
	for i in range(charges):
		var x: float = start_x + float(i) * (pip_w + pip_gap)
		var rect := Rect2(x, y, pip_w, pip_height)

		# Si tu veux casser les pips "de gauche à droite"
		var c:Color = color_broken_pip if i < broken else color_block_activated
		
		draw_rect(rect, c, true)

		if outline:
			draw_rect(rect, Color(0, 0, 0, 0.35), false)

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_action_zone_resolving(processing)-> void:
	if processing:
		is_resolving_action_zone = true
	else:
		is_resolving_action_zone = false

func _on_player_defensive_action_preview(type, value)-> void:
	entity = self.get_parent().get_parent()
	if !(entity is PLAYER):
		return

	if type == "Block":
		charges += value
		queue_redraw()
