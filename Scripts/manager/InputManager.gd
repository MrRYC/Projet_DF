extends Node2D

#constantes
const COLLISION_MASK_CARD = 1 #Masque de collision des intentions des cartes
const COLLISION_MASK_MARKER = 2 #Masque de collision des intentions des opponents
const COLLISION_MASK_PILE = 4 #Masque de collision des piles (deck, discard, wound et banished)
const COLLISION_MASK_ENTITY = 5 #Masque de collision du joueur et des opponents

#variables de référence vers autre Node
@onready var card_manager_ref = $"../CardManager"
@onready var player_hand_ref = $"../PlayerHand"

#variables du script
var left_mouse : bool = false
var right_mouse : bool = false
var is_game_processing : bool = false
var action_timer_timeout : bool = false

func _ready() -> void:
	EventBus.processing.connect(_on_processing)
	EventBus.action_timer_timeout.connect(_on_action_timer_timeout)

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
		
		#Seule les piles sont sélectionnables si le timer action est à 0
		if action_timer_timeout:
			if collider.collision_mask == COLLISION_MASK_PILE and left_mouse:
				card_manager_ref.show_pile(collider.get_parent().name)
			return
		
		# CLIC GAUCHE
		if collider.collision_mask == COLLISION_MASK_MARKER and left_mouse:
			return
		elif collider.collision_mask == COLLISION_MASK_ENTITY and left_mouse:
			return
		elif collider.collision_mask == COLLISION_MASK_CARD and left_mouse:
			if card_found.current_area == 2:
				card_manager_ref.remove_card_from_action_zone(card_found)
			elif card_found:
				card_manager_ref.start_drag(card_found)
		elif collider.collision_mask == COLLISION_MASK_PILE and left_mouse:
			if !is_game_processing:
				card_manager_ref.show_pile(collider.get_parent().name)

		# CLIC DROIT
		elif collider.collision_mask == COLLISION_MASK_CARD and right_mouse:
			if card_found.current_area == 1:
				card_manager_ref.flip_card_in_hand(card_found)

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_processing(processing):
	if processing:
		is_game_processing = true
	else:
		is_game_processing = false

func _on_action_timer_timeout(locked):
	action_timer_timeout = locked
