extends Node2D

#constantes
const COLLISION_MASK_CARD = 1
const COLLISION_MASK_PILE = 4 #Masque de collision du deck et de la discard

#variables de référence vers autre Node
@onready var card_manager_ref = $"../CardManager"
@onready var player_hand_ref = $"../PlayerHand"

#variables du script
var left_mouse
var right_mouse
var is_processing

func _ready() -> void:
	EventBus.processing.connect(_on_processing)

func _input(event):
	left_mouse = false
	right_mouse = false
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			EventBus.emit_signal("left_mouse_clicked")
			left_mouse = true
			raycast_at_cursor()
		else:
			EventBus.emit_signal("left_mouse_released")
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			right_mouse = true
			raycast_at_cursor()

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)

	if result.size() > 0:
		var collider = result[0].collider
		var card_found = collider.get_parent()

		# CLIC GAUCHE
		if collider.collision_mask == COLLISION_MASK_CARD and left_mouse:
			if card_found.current_area == 2:
				pass
			elif card_found:
				card_manager_ref.start_drag(card_found)

		# CLIC DROIT
		elif collider.collision_mask == COLLISION_MASK_CARD and right_mouse:
			if card_found.current_area == 1:
				card_manager_ref.flip_card_in_hand(card_found)

		# CLIC GAUCHE sur pile = détail
		elif collider.collision_mask == COLLISION_MASK_PILE and left_mouse:
			if !is_processing:
				card_manager_ref.show_pile(collider.get_parent().name)

func _on_processing(processing):
	if processing:
		is_processing = true
	else:
		is_processing = false
