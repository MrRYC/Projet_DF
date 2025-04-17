extends Node2D

#constantes
const COLLISION_MASK_CARD = 1
const ENEMY_COLLISION_MASK = 1

#variables de référence vers un autre Node
@onready var player_hand_ref = $"../PlayerHand"
@onready var action_zone_ref = $"../ActionZone"
@onready var discard_pile_ref = $"../DiscardPile"
@onready var input_manager_ref = $"../InputManager"
@onready var battle_manager_ref = $"../BattleManager"

#variables du script
var screen_size
var card_being_dragged = false
var is_hovering_on_card = false
var is_defense_phase = false

func _ready() -> void:
	screen_size = get_viewport_rect().size
	input_manager_ref.connect("left_mouse_released", connect_left_mouse_released_signal)
	battle_manager_ref.connect("defense_phase_signal",connect_defense_phase_signal)
	battle_manager_ref.connect("attack_phase_signal",connect_attack_phase_signal)

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x,0,screen_size.x),
			clamp(mouse_pos.y,0,screen_size.y))

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1,1) 

func finish_drag():
	card_being_dragged.scale = Vector2(1.05,1.05)

	var opponent_targeted = is_a_card_played(card_being_dragged)
	var player_hand_min_zone = Vector2(player_hand_ref.hand_x_position_min, 775)
	var player_hand_max_zone = Vector2(player_hand_ref.hand_x_position_max, player_hand_ref.HAND_Y_POSITION)
	
	if opponent_targeted && !is_defense_phase:
		send_card_to_action_zone(card_being_dragged, opponent_targeted)
	elif is_in_bounds(card_being_dragged.position, player_hand_min_zone, player_hand_max_zone):
		var mouse_x = get_global_mouse_position().x
		var new_index = player_hand_ref.get_drop_index(mouse_x)
		player_hand_ref.move_card_to_index(card_being_dragged, new_index)
	elif !is_in_bounds(card_being_dragged.position, player_hand_min_zone, player_hand_max_zone):
		return_card_to_hand(card_being_dragged)
	
	card_being_dragged = null

###########################################################################
#                              CARDS MOVEMENT                             #
###########################################################################

func return_card_to_hand(card):
	card.is_in_action_zone = false
	card.target = null
	action_zone_ref.remove_card_from_action_zone(card)
	player_hand_ref.add_card_to_hand(card, Global.DEFAULT_CARD_MOVE_SPEED)

func send_card_to_action_zone(card, opponent):
	card.target = opponent
	card.is_in_action_zone = true
	player_hand_ref.remove_card_from_hand(card)
	action_zone_ref.add_card_to_action_zone(card, Global.DEFAULT_CARD_MOVE_SPEED)
	
func send_card_to_discard(card):
	card.is_in_action_zone = false
	card.target = null
	player_hand_ref.remove_card_from_hand(card)
	discard_pile_ref.add_card_to_discard(card)

###########################################################################
#                            CARDS MANAGEMENT                             #
###########################################################################

func highlight_card(card, hovered):
	if card.is_in_action_zone:
		return
	elif hovered:
		card.scale = Vector2(1.05,1.05)
		card.z_index = 2
	else:
		update_card_size(card,true)

func update_card_size(card, standard_size):
	if standard_size:
		card.scale = Vector2(1, 1)
		card.z_index = 1
	else:
		card.scale = Vector2(0.5, 0.5)
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

func is_a_card_played(card):
	#var play_zone_y = 600 # par exemple si la carte est relâchée assez haut dans l’écran
	#return card.position.y < play_zone_y
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	
	parameters.position = card.get_global_position() # CHANGEMENT ICI
	parameters.collide_with_areas = true
	
	var results = space_state.intersect_point(parameters)

	for result in results:
		if result.collider.is_in_group("Opponent"):
			return result.collider
	return null

#On récupère la taille dynamique de la main du joueur
func is_in_bounds(pos: Vector2, pos_min: Vector2, pos_max: Vector2) -> bool:
	var offset_x_left = pos_min.x - 100
	var offset_x_right = pos_max.x + 75
	var offset_x_up = pos_min.y+ - 75
	var offset_x_down = pos_max.y + 75

	return pos.x >= offset_x_left and pos.x <= offset_x_right and pos.y >= offset_x_up  and pos.y <= offset_x_down

func get_card_under_cursor():
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true

	var results = space_state.intersect_point(params)
	for result in results:
		var collider = result.collider
		if collider.is_in_group("HandofCards") and collider != card_being_dragged:
			return collider.get_parent()
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
	
func force_global_hover_check():
	var new_card_hovered = is_a_card_selected()
	if new_card_hovered:
		on_hovered_over_card(new_card_hovered)

###########################################################################
#                             SIGNAL CONNEXION                            #
###########################################################################

#coonexion via get_parent().connect_card_signals(self) de Card
func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func connect_defense_phase_signal():
	is_defense_phase = true

func connect_attack_phase_signal():
	is_defense_phase = false

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
