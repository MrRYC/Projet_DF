extends Node2D

#constantes
const CARD_WIDTH = 175 #espace entre les cartes
const HAND_Y_POSITION = 950 #hauteur de la zone des cartes en main

#variables de référence vers autre Node
@onready var discard_pile_ref = $"../DiscardPile"

#variables du script
@onready var center_screen_x = get_viewport().size.x / 2
var player_hand = []
var hand_x_position_min = 0.0
var hand_x_position_max = 0.0

###########################################################################
#                              HAND MANAGEMENT                            #
###########################################################################

func add_card_to_hand(card, speed):
	if card not in player_hand:
		player_hand.insert(0,card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.starting_position, Global.DEFAULT_CARD_MOVE_SPEED)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(Global.DEFAULT_CARD_MOVE_SPEED)

func add_card_to_discard(card):
	if card in player_hand:
		remove_card_from_hand(card)
		discard_pile_ref.add_card_to_discard(card)
		update_hand_positions(Global.DEFAULT_CARD_MOVE_SPEED)

###########################################################################
#                           PLAYER HAND POSITION                          #
###########################################################################

func calculate_hand_size(cards_x_position : Array):
	if cards_x_position.size() > 0:
		hand_x_position_min = float(cards_x_position.min())
		hand_x_position_max = float(cards_x_position.max())
	else:
		hand_x_position_min = 0.0
		hand_x_position_max = 0.0

###########################################################################
#                              CARDS POSITION                             #
###########################################################################

func update_hand_positions(speed):
	if player_hand.size() == 0:
		hand_x_position_min = 0.0
		hand_x_position_max = 0.0
		return
	
	var cards_x_position = []

	for i in range(player_hand.size()):
		#Position de la nouvelle carte en fonction de l'index
		var x_position = calculate_card_position(i)
		cards_x_position.append(x_position)
		var new_position = Vector2(x_position, HAND_Y_POSITION)
		var card = player_hand[i]
		card.starting_position = new_position

		animate_card_to_position(card, new_position, speed)
		
	calculate_hand_size(cards_x_position)

func get_drop_index(mouse_pos_x):
	for i in range(player_hand.size()):
		var card_x = calculate_card_position(i)
		if mouse_pos_x < card_x + CARD_WIDTH / 2.0:
			return i
	return player_hand.size()

func move_card_to_index(card, target_index):
	if card in player_hand:
		player_hand.erase(card)
		player_hand.insert(target_index, card)
		update_hand_positions(Global.DEFAULT_CARD_MOVE_SPEED)

func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2.0
	return x_offset

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
