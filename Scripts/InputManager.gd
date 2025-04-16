extends Node2D

signal left_mouse_clicked
signal left_mouse_released

#constantes
const COLLISION_MASK_CARD = 1
const COLLISION_MASK_PILE = 4 #Masque de collision du deck et de la discard

#variables de référence vers autre Node
@onready var card_manager_ref = $"../CardManager"

#variables du script
var left_mouse
var right_mouse

func _input(event):
	left_mouse = false
	right_mouse = false
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_clicked")
			left_mouse = true
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_released")
	
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
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD: #test le clic sur les cartes (COLLISION_MASK_CARD = 1)
			var card_found = result[0].collider.get_parent()
			if card_found.is_in_combat && right_mouse: 
				card_manager_ref.return_card_to_hand(card_found)
			elif card_found.is_in_combat && left_mouse: 
				return
			elif card_found && left_mouse:
				card_manager_ref.start_drag(card_found)
		elif result_collision_mask == COLLISION_MASK_PILE: #test le clic sur les cartes (COLLISION_MASK_PILE = 4)
			print("Je clique sur une pile")
