extends Node2D

signal left_mouse_clicked
signal left_mouse_released

#constantes
const COLLISION_MASK_CARD = 1
const COLLISION_MASK_PILE = 4 #Masque de collision du deck et de la discard

#variables de référence vers autre Node
@onready var card_manager_ref = $"../CardManager"
@onready var player_hand_ref = $"../PlayerHand"

#variables du script
var left_mouse
var right_mouse
var is_defensive_phase = false

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
		var collider = result[0].collider
		var card_found = collider.get_parent()

		# CLIC GAUCHE
		if collider.collision_mask == COLLISION_MASK_CARD and left_mouse:
			if card_found:
				card_manager_ref.start_drag(card_found)

		# CLIC DROIT
		elif collider.collision_mask == COLLISION_MASK_CARD and right_mouse:
			if card_found.is_in_combat:
				card_manager_ref.return_card_to_hand(card_found)
			elif is_defensive_phase:
				player_hand_ref.add_card_to_discard(card_found)

		# CLIC GAUCHE sur pile = détail
		elif collider.collision_mask == COLLISION_MASK_PILE and left_mouse:
			print("J'affiche le détail des cartes dans cette pile")

###########################################################################
#                             SIGNAL CONNEXION                            #
###########################################################################

func _on_battle_manager_attack_phase_signal():
	is_defensive_phase = false

func _on_battle_manager_defense_phase_signal():
	is_defensive_phase = true
	
func _on_battle_manager_end_phase_signal():
	is_defensive_phase = false
