extends Node2D

#constantes
const CARD_WIDTH = 175 #espace entre les cartes
const HAND_Y_POSITION = 950 #hauteur de la zone des cartes en main

#variables de référence vers autre Node
@onready var discard_pile_ref: Node2D = $"../Piles/DiscardPile"

#variables du script
@onready var center_screen_x = get_viewport().size.x / 2
var cards_in_hand = []
var cards_position_in_hand = []
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
		cards_in_hand.insert(0,card)
		update_hand_positions(card, index)
	elif card.in_hand:
		animate_card_to_position(card, card.starting_position)

func remove_card_from_hand(card):
	if card.in_hand:
		card.in_hand = false
		cards_in_hand.erase(card)
		update_hand_positions(card, 1)

###########################################################################
#                           PLAYER HAND POSITION                          #
###########################################################################

func calculate_hand_size():
	if cards_position_in_hand.size() > 0:
		hand_x_position_min = float(cards_position_in_hand.min())
		hand_x_position_max = float(cards_position_in_hand.max())
	else:
		hand_x_position_min = 0.0
		hand_x_position_max = 0.0

###########################################################################
#                              CARDS POSITION                             #
###########################################################################

func update_hand_positions(card, index):
	if new_turn:
		new_turn = false

	#Position de la nouvelle carte en fonction de l'index
	var x_position = calculate_card_position(index)
	cards_position_in_hand.append(x_position)
	var new_position = Vector2(x_position, HAND_Y_POSITION)
	card.starting_position = new_position
	animate_card_to_position(card, new_position)
	calculate_hand_size()

func move_card_to_index(card, mouse_pos_x):
	var player_hand_min_zone = Vector2(hand_x_position_min, 775)
	var player_hand_max_zone = Vector2(hand_x_position_max, HAND_Y_POSITION)
	var new_index = get_drop_index(mouse_pos_x)
	
	for i in cards_position_in_hand:
		print(cards_position_in_hand)
		var card_orignal_position = card.starting_position
		var card_index = get_card_index(card)
		if is_in_bounds(card.position, player_hand_min_zone, player_hand_max_zone):
			if new_index == 0 && card_index == 0 :
				animate_card_to_position(card, card_orignal_position)
			else:
				print("la carte tirée en position : "+str(card_index)+" remplace la carte en position : "+str(new_index))
				var rebind_position : Array = cards_position_in_hand.duplicate()
				var tmp : int = card_index
				if new_index > card_index:
					while card_index <= new_index:
						print(cards_position_in_hand[card_index])
						print(rebind_position[tmp].starting_position)
						cards_position_in_hand[card_index].starting_position = rebind_position[tmp].starting_position
						card_index += 1
						tmp -= 1
				else:
					print("remplace une carte plus à gauche")
					while card_index <= new_index:
						pass
				animate_card_to_position(card, card.starting_position)
		elif !is_in_bounds(card.position, player_hand_min_zone, player_hand_max_zone):
			animate_card_to_position(card, card.starting_position)

func get_card_index(card):
	for i in cards_position_in_hand.size():
		if cards_position_in_hand[i] > card.starting_position.x:
			return i
	return cards_position_in_hand.size()

func get_drop_index(mouse_pos_x):
	for i in cards_position_in_hand.size():
		if cards_position_in_hand[i] > mouse_pos_x:
			return i
	return cards_position_in_hand.size()

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
