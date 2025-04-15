extends Node2D

#constantes
const COLLISION_MASK_CARD = 1
const ENEMY_COLLISION_MASK = 1
const DEFAULT_CARD_MOVE_SPEED = 0.1

#variables de référence vers un autre Node
@onready var player_hand_ref = $"../PlayerHand"
@onready var combat_zone_ref = $"../CombatZone"
@onready var input_manager_ref = $"../InputManager"

#variables du script
var screen_size
var card_being_dragged
var is_hovering_on_card

func _ready() -> void:
	screen_size = get_viewport_rect().size
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
	
	var opponent_targeted = is_a_opponent_targeted(card_being_dragged)
	
	if card_being_dragged.is_in_combat:
		card_being_dragged.is_in_combat = false
		card_being_dragged.target = null
		standard_card_resize(card_being_dragged)
		combat_zone_ref.remove_card_from_combat_zone(card_being_dragged)
		player_hand_ref.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	elif opponent_targeted:
		card_being_dragged.target = opponent_targeted
		card_being_dragged.is_in_combat = true
		combat_zone_resize(card_being_dragged)
		player_hand_ref.remove_card_from_hand(card_being_dragged)
		combat_zone_ref.add_card_to_combat_zone(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	else:
		player_hand_ref.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	
	card_being_dragged = null

func highlight_card(card, hovered):
	if card.is_in_combat:
		return
	
	if hovered:
		card.scale = Vector2(1.05,1.05)
		card.z_index = 2
	else:
		standard_card_resize(card)

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

func is_a_opponent_targeted(card):
	#var play_zone_y = 600 # par exemple si la carte est relâchée assez haut dans l’écran
	#return card.position.y < play_zone_y
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	
	parameters.position = card.get_global_position() # CHANGEMENT ICI
	parameters.collide_with_areas = true
	
	var results = space_state.intersect_point(parameters)

	for result in results:
		if result.collider.is_in_group("Opponent"):
			#print(">>> Carte jouée sur ennemi détectée : ", result.collider.name)
			return result.collider
	return null

func get_upfront_card(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index

	for i in range (1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card

func combat_zone_resize(card):
	card.scale = Vector2(0.6, 0.6)
	card.z_index = 0 # en combat, tu veux qu’elles ne soient pas au-dessus des cartes en main

func standard_card_resize(card):
	card.scale = Vector2(1, 1)
	card.z_index = 1
	
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
