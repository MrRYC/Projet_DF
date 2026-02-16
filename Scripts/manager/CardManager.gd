extends Node2D

#constantes
const COLLISION_MASK_CARD = 1
const ENEMY_COLLISION_MASK = 1

#chargement de la base de données des cartes
@onready var card_db_ref = preload("res://scripts/resources/CardDB.gd")

#variables de référence vers un autre Node
@onready var player_hand_ref: Node2D = $"../PlayerHand"
@onready var action_zone_ref: Node = $"../ActionZone"
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
	EventBus.new_turn.connect(_on_new_turn)
	EventBus.fracture_a_random_card.connect(_on_card_used_as_defense)

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

func return_card_to_hand(card)-> void:
	card.target = null
	player_hand_ref.add_card_to_hand(card)
	update_card_size(card)
	
func remove_card_from_action_zone(card)-> void:
	action_zone_ref.return_card_to_hand(card)

func send_card_to_action_zone(card, opponent)-> void:
	card.target = opponent
	action_zone_ref.add_card_to_action_zone(card)
	player_hand_ref.remove_card_from_hand(card)

###########################################################################
#                             TURN MANAGEMENT                             #
###########################################################################

func new_turn(_max_hand_size)-> void:
	if action_zone_ref.action_zone.size() > 0:
		for card in action_zone_ref.action_zone.duplicate():
			check_destination_pile(card)
			card.queue_free()
		action_zone_ref.action_zone.clear()

	if player_hand_ref.player_hand.size() > 0:
		for card in player_hand_ref.player_hand.duplicate():
			send_card_to_discard(card)
			card.queue_free()
		player_hand_ref.player_hand.clear()

###########################################################################
#                             PILE MANAGEMENT                             #
###########################################################################

func check_destination_pile(card)-> void:
	var card_side_effect = card.effect_per_slot
	
	if !card_side_effect:
		send_card_to_discard(card)
	else:
		for slot_index in card_side_effect:
			if card_side_effect[slot_index]["uses"] == null:
				send_card_to_discard(card)
			elif card.is_flipped && card_side_effect[slot_index]["uses"] == 0:
				if card_side_effect[slot_index]["side_effect"] == "exhaust":
					send_card_to_exhaust(card)
				elif card_side_effect[slot_index]["side_effect"] == "wound":
					send_card_to_wound(card)
				else:
					send_card_to_discard(card)
			else:
				send_card_to_discard(card)
	
	card.current_area = card.board_area.IN_PILE

func send_card_to_discard(card)-> void:
	card.target = null
	discard_pile_ref.add_card_to_pile(card)
		
	if card.current_area == 1:
		player_hand_ref.remove_card_from_hand(card)
	else:
		action_zone_ref.remove_card_from_action_zone(card)

func send_card_to_exhaust(card)-> void:
	card.target = null
	exhaust_pile_ref.add_card_to_pile(card)

	if card.current_area == 1:
		player_hand_ref.remove_card_from_hand(card)
	else:
		action_zone_ref.remove_card_from_action_zone(card)

func send_card_to_wound(card)-> void:
	card.target = null
	wound_pile_ref.add_card_to_pile(card)

	if card.current_area == 1:
		player_hand_ref.remove_card_from_hand(card)
	else:
		action_zone_ref.remove_card_from_action_zone(card)

func deck_size()-> int:
	return deck_pile_ref.deck_size

func show_pile(pile)-> void:
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

func start_drag(card) -> void:
	card_being_dragged = card
	card.scale = Vector2(1.0,1.0)
	EventBus.aim_started.emit(card)

func finish_drag() -> void:
	card_being_dragged.scale = Vector2(1.05,1.05)
	EventBus.aim_ended.emit(card_being_dragged)

	var card_target = is_a_card_played(card_being_dragged)
	var player_hand_min_zone = Vector2(player_hand_ref.hand_x_position_min, 775)
	var player_hand_max_zone = Vector2(player_hand_ref.hand_x_position_max, player_hand_ref.HAND_Y_POSITION)
	
	if card_target:
		send_card_to_action_zone(card_being_dragged, card_target)
		EventBus.card_played.emit()
	elif is_in_bounds(card_being_dragged.position, player_hand_min_zone, player_hand_max_zone):
		var mouse_x = get_global_mouse_position().x
		var new_index = player_hand_ref.get_drop_index(mouse_x)
		player_hand_ref.move_card_to_index(card_being_dragged, new_index)
	elif !is_in_bounds(card_being_dragged.position, player_hand_min_zone, player_hand_max_zone):
		return_card_to_hand(card_being_dragged)
	
	card_being_dragged = null

func flip_card_in_hand(card) -> void:
	if !card.slot_number :
		print("carte sans effet")
		card.get_node("CardErrorAnimation").play("tilt_error")
		return

	if card.slot_number == 1:
		if card.effect_per_slot[0]["uses"] == 0 && card.effect_per_slot[0]["side_effect"] == "inactivate":
			card.get_node("CardErrorAnimation").play("tilt_error")
			return

	if !card.is_flipped && card.slot_number:
		card.is_flipped = true
		card.set_augment_text(card.effect_per_slot[0]["description"])
	else:
		card.is_flipped = false
	
	card.card_is_flipped()

func highlight_card(card, hovered) -> void:
	if not (card is CARD_DATA):
		return

	if card.current_area == 1 && hovered: # 1 = IN_HAND
		card.scale = Vector2(1.1,1.1)
		card.z_index = 2
	elif card.current_area == 2 : # 2 = IN_ACTION_ZONE
		return
	else:
		update_card_size(card)

func update_card_size(card) -> void:
	if card.current_area == 2:
		card.scale = Vector2(0.5, 0.5)
		card.z_index = 1
	else:
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
	
	var hits = space_state.intersect_point(parameters)

	for hit in hits:
		if hit.collider.is_in_group("Opponent") && !card.is_flipped:
			return hit.collider.get_parent()
		elif hit.collider.is_in_group("Player") && card.is_flipped:
			return hit.collider.get_parent()

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

func _on_left_mouse_released()-> void:
	if card_being_dragged:
		finish_drag()
	
func _on_hovered_over_card(card)-> void:
	if !card_being_dragged:
		is_hovering_on_card = true
		highlight_card(card,true)
	
func _on_hovered_off_card(card)-> void:
	if !card_being_dragged:
		highlight_card(card,false)
	
	var new_card_hovered = is_a_card_selected()
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_on_card = false

func _on_new_turn(new_hand_size, _is_first_turn)-> void:
	new_turn(new_hand_size)

func _on_card_used_as_defense()->void:
	var p_hand = player_hand_ref.player_hand
	var i := randi_range(0, p_hand.size() - 1)
	var removed_card = p_hand[i]
	
	if removed_card.status==0: #si statut intact
		removed_card.status = 1 #statut fractured
		removed_card.apply_status_visuals()
		send_card_to_discard(removed_card)
		removed_card.queue_free()
	elif removed_card.status==1: #si statut fractured
		removed_card.status = 2 #statut broken
		removed_card.apply_status_visuals()
		send_card_to_wound(removed_card)
		removed_card.queue_free()
