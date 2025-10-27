extends Node2D

#constantes
const COLLISION_MASK_CARD = 1
const ENEMY_COLLISION_MASK = 1

#chargement de la base de données des cartes
@onready var card_db_ref = preload("res://scripts/resources/CardDB.gd")

#variables de référence vers un autre Node
@onready var player_hand_ref: Node2D = $"../PlayerHand"
@onready var action_zone_ref: Node2D = $"../ActionZone"
@onready var deck_pile_ref: Node2D = $"../Piles/DeckPile"
@onready var wound_pile_ref: Node2D = $"../Piles/WoundPile"
@onready var discard_pile_ref: Node2D = $"../Piles/DiscardPile"
@onready var exhaust_pile_ref: Node2D = $"../Piles/ExhaustPile"

#variables du script
var screen_size
var card_being_dragged
var is_hovering_on_card : bool = false
var is_end_of_turn : bool = false
var destination_pile : String = "discard"

func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	EventBus.left_mouse_released.connect(_on_left_mouse_released)
	EventBus.hovered.connect(_on_hovered_over_card)
	EventBus.hovered_off.connect(_on_hovered_off_card)

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x,0,screen_size.x),
			clamp(mouse_pos.y,0,screen_size.y))
	else:
		pass

###########################################################################
#                          ACTION ZONE MOVEMENT                           #
###########################################################################

func return_card_to_hand(card):
	card.target = null
	player_hand_ref.add_card_to_hand(card, Global.DEFAULT_CARD_MOVE_SPEED)
	action_zone_ref.remove_card_from_action_zone(card)

func send_card_to_action_zone(card, opponent):
	card.target = opponent
	action_zone_ref.add_card_to_action_zone(card, Global.DEFAULT_CARD_MOVE_SPEED)
	player_hand_ref.remove_card_from_hand(card)

###########################################################################
#                             TURN MANAGEMENT                             #
###########################################################################

func new_turn(max_hand_size):
	if action_zone_ref.action_zone.size() > 0:
		for card in action_zone_ref.action_zone.duplicate():
			check_destination_pile(card)

	if player_hand_ref.player_hand.size() > 0:
		for card in player_hand_ref.player_hand.duplicate():
			send_card_to_discard(card)
			card.queue_free()

	deck_pile_ref.new_turn(max_hand_size)

###########################################################################
#                             PILE MANAGEMENT                             #
###########################################################################

func check_destination_pile(card):
	if card.is_flipped:
		var card_side_effect = card.flip_effect["e_side_effect"]
		if card_side_effect == "exhaust":
			send_card_to_exhaust(card)
		elif card_side_effect == "wound":
			send_card_to_wound(card)
		else:
			send_card_to_discard(card)
	else:
		send_card_to_discard(card)

func send_card_to_discard(card):
	card.target = null
	discard_pile_ref.add_card_to_pile(card)

	if card.card_current_area == 1:
		player_hand_ref.remove_card_from_hand(card)
	else:
		action_zone_ref.remove_card_from_action_zone(card)

	card.card_current_area = card.card_area.IN_DISCARD

func send_card_to_exhaust(card):
	card.target = null
	exhaust_pile_ref.add_card_to_pile(card)

	if card.card_current_area == 1:
		player_hand_ref.remove_card_from_hand(card)
	else:
		action_zone_ref.remove_card_from_action_zone(card)
		
	card.card_current_area = card.card_area.IN_EXHAUST

func send_card_to_wound(card):
	card.target = null
	wound_pile_ref.add_card_to_pile(card)

	if card.card_current_area == 1:
		player_hand_ref.remove_card_from_hand(card)
	else:
		action_zone_ref.remove_card_from_action_zone(card)
	
	card.card_current_area = card.card_area.IN_WOUND

func deck_size():
	return deck_pile_ref.deck_size

func show_pile(pile):
	if pile == "DeckPile":
		deck_pile_ref.show_pile()
	elif pile == "DiscardPile":
		discard_pile_ref.show_pile()
	elif pile == "WoundPile":
		wound_pile_ref.show_pile()
	elif pile == "ExhaustPile":
		exhaust_pile_ref.show_pile()

###########################################################################
#                            CARDS MANAGEMENT                             #
###########################################################################

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1.0,1.0)
	EventBus.aim_started.emit(card)

func finish_drag():
	card_being_dragged.scale = Vector2(1.05,1.05)
	EventBus.aim_ended.emit(card_being_dragged)

	var opponent_targeted = is_a_card_played(card_being_dragged)
	var player_hand_min_zone = Vector2(player_hand_ref.hand_x_position_min, 775)
	var player_hand_max_zone = Vector2(player_hand_ref.hand_x_position_max, player_hand_ref.HAND_Y_POSITION)
	
	if opponent_targeted:
		send_card_to_action_zone(card_being_dragged, opponent_targeted)
	elif is_in_bounds(card_being_dragged.position, player_hand_min_zone, player_hand_max_zone):
		var mouse_x = get_global_mouse_position().x
		var new_index = player_hand_ref.get_drop_index(mouse_x)
		player_hand_ref.move_card_to_index(card_being_dragged, new_index)
	elif !is_in_bounds(card_being_dragged.position, player_hand_min_zone, player_hand_max_zone):
		return_card_to_hand(card_being_dragged)
	
	card_being_dragged = null

func flip_card_in_hand(card):
	if !card["flip_effect"]:
		print("carte sans effet")
		card.get_node("CardErrorAnimation").play("tilt_error")
		return
	
	card.rotation_degrees += 180
	if !card.is_flipped && card["flip_effect"]:
		card.is_flipped = true
	else:
		card.is_flipped = false

func highlight_card(card, hovered):
	if card.card_current_area == 1 && hovered: # 1 = IN_HAND
		card.scale = Vector2(1.1,1.1)
		card.z_index = 2
	elif card.card_current_area == 2 : # 2 = IN_ACTION_ZONE
		return
	else:
		update_card_size(card,true)

func update_card_size(card, standard_size):
	if card.card_current_area == 2:
		card.scale = Vector2(0.5, 0.5)
		card.z_index = 1
	elif standard_size:
		card.scale = Vector2(1, 1)
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
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	
	parameters.position = card.get_global_position() # CHANGEMENT ICI
	parameters.collide_with_areas = true
	
	var results = space_state.intersect_point(parameters)

	for result in results:
		if result.collider.is_in_group("Opponent") && !card.is_flipped:
			return result.collider
		elif result.collider.is_in_group("Player") && card.is_flipped:
			return result.collider
	return null

#On récupère la taille dynamique de la main du joueur
func is_in_bounds(pos: Vector2, pos_min: Vector2, pos_max: Vector2) -> bool:
	var offset_x_left = pos_min.x - 100
	var offset_x_right = pos_max.x + 75
	var offset_x_up = pos_min.y+ - 75
	var offset_x_down = pos_max.y + 75

	return pos.x >= offset_x_left and pos.x <= offset_x_right and pos.y >= offset_x_up  and pos.y <= offset_x_down

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
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_left_mouse_released():
	if card_being_dragged:
		finish_drag()
	
func _on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card,true)
	
func _on_hovered_off_card(card):
	if !card_being_dragged:
		highlight_card(card,false)
	
	var new_card_hovered = is_a_card_selected()
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_on_card = false
