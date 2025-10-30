extends Node2D

#constantes
const CARD_WIDTH = 175 #espace entre les cartes
const HAND_Y_POSITION = 950 #hauteur de la zone des cartes en main

#variables de référence vers autre Node
@onready var discard_pile_ref: Node2D = $"../Piles/DiscardPile"

#variables du script
@onready var center_screen_x = get_viewport().size.x / 2
var player_hand = []
var speed = Global.DEFAULT_CARD_MOVE_SPEED
var new_turn : bool = false
var hand_size : int
var hand_x_position_min = 0.0
var hand_x_position_max = 0.0

func _ready() -> void:
	EventBus.new_turn.connect(_on_new_turn)

###########################################################################
#                              HAND MANAGEMENT                            #
###########################################################################

func add_card_to_hand(card, index):
	if !card.in_hand:
		card.in_hand = true
		player_hand.insert(0,card)
		update_hand_positions()
	elif card.in_hand:
		animate_card_to_position(card, index)

func remove_card_from_hand(card):
	if card.in_hand:
		card.in_hand = false
		player_hand.erase(card)
		card.queue_free()
		update_hand_positions()

###########################################################################
#                           PLAYER HAND POSITION                          #
###########################################################################

func calculate_hand_size():
	if player_hand.size() > 0:
		hand_x_position_min = float(player_hand.min())
		hand_x_position_max = float(player_hand.max())
	else:
		hand_x_position_min = 0.0
		hand_x_position_max = 0.0

###########################################################################
#                              CARDS POSITION                             #
###########################################################################

func update_hand_positions():
	if new_turn:
		new_turn = false

	#Position de la nouvelle carte en fonction de l'index
	for i in range(player_hand.size()):
		var card:Node2D = player_hand[i]
		var new_position = Vector2(calculate_card_position(i),HAND_Y_POSITION)
		card.starting_position = new_position
		animate_card_to_position(card, new_position)
		#calculate_hand_size()

func move_card_to_index(card, mouse_pos_x):
	var player_hand_min_zone = Vector2(hand_x_position_min, 775)
	var player_hand_max_zone = Vector2(hand_x_position_max, HAND_Y_POSITION)
	var new_index = get_drop_index(mouse_pos_x)
	
	if is_in_bounds(card.position, player_hand_min_zone, player_hand_max_zone):
		var old_index := player_hand.find(card)
		
		if old_index == -1:
			return
		player_hand.remove_at(old_index)

		if new_index > old_index:
			new_index -= 1
		player_hand.insert(new_index, card)

		update_hand_positions()
	elif !is_in_bounds(card.position, player_hand_min_zone, player_hand_max_zone):
		animate_card_to_position(card, card.starting_position)

func get_drop_index(mouse_pos_x):
	for i in range(hand_size):
		var card_x : float = calculate_card_position(i)
		if mouse_pos_x < card_x:
			return i

	return player_hand.size()

func calculate_card_position(index):
	var total_width = (hand_size - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2.0
	return x_offset

func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func is_in_bounds(pos: Vector2, pos_min: Vector2, pos_max: Vector2) -> bool:
	var offset_x_left = pos_min.x - 100
	var offset_x_right = pos_max.x + 75
	var offset_x_up = pos_min.y+ - 75
	var offset_x_down = pos_max.y + 75

	return pos.x >= offset_x_left and pos.x <= offset_x_right and pos.y >= offset_x_up  and pos.y <= offset_x_down

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_new_turn(new_hand_size):
	new_turn = true
	hand_x_position_min = 0.0
	hand_x_position_max = 0.0
	hand_size = new_hand_size
