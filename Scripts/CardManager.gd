extends Node2D

#constantes
const COLLISION_MASK_CARD = 1
const DEFAULT_CARD_MOVE_SPEED = 0.1

#variables de référence vers un autre Node
var player_hand_ref
var input_manager_ref

#variables du script
var screen_size
var card_being_dragged
var is_hovering_on_card

func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_ref = $"../PlayerHand"
	input_manager_ref = $"../InputManager"
	
	input_manager_ref.connect("left_mouse_released", connect_left_mouse_released_signal)

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x,0,screen_size.x),
			clamp(mouse_pos.y,0,screen_size.y))

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1,1)

func finish_drag():
	card_being_dragged.scale = Vector2(1.05,1.05)
	
	var was_played = is_card_played(card_being_dragged)
	
	#Zone pour Test if si une carte est jouée
	#if was_played:
		#player_hand_ref.remove_card_from_hand(card_being_dragged)
		#discard_pile_ref.add_to_discard(card_being_dragged)
	#elif is_defense_phase:
	#else:
	#Sinon la carte est reposée à son emplacement de départ
	#player_hand_ref.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	
	player_hand_ref.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05,1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1,1)
		card.z_index = 1

func is_a_card_selected():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	
	var result = space_state.intersect_point(parameters)
	
	if result.size() > 0:
		return get_upfront_card(result)
	return null

func is_card_played(card):
	var play_zone_y = 600 # par exemple si la carte est relâchée assez haut dans l’écran
	return card.position.y < play_zone_y
	
func get_upfront_card(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index

	for i in range (1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card

###########################################################################
#                           CONNEXION DES SIGNAUX                         #
###########################################################################

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	
func connect_left_mouse_released_signal():
	if card_being_dragged:
		finish_drag()
	
func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card,true)
	
func on_hovered_off_card(card):
	if !card_being_dragged:
		highlight_card(card,false)
		
		var new_card_hovered = is_a_card_selected()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false
