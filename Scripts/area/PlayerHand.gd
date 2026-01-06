extends Node2D

#constantes
const CARD_WIDTH = 175 #espace entre les cartes
const HAND_Y_POSITION = 950 #hauteur de la zone des cartes en main

#variables du script
@onready var center_screen_x = get_viewport().size.x / 2
var speed = Global.HAND_DRAW_INTERVAL
var player_hand : Array = []
var combo_cards : Array = []
var hand_x_position_min : float = 0.0
var hand_x_position_max : float = 0.0

func _ready():
	EventBus.drop_combo_cards.connect(_on_drop_combo_cards)

###########################################################################
#                              HAND MANAGEMENT                            #
###########################################################################

func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.insert(0,card)
		card.current_area = card.board_area.IN_HAND
		update_hand_positions()
	else:
		animate_card_to_position(card, card.starting_position)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()

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

func update_hand_positions():
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

		animate_card_to_position(card, new_position)
		
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
		update_hand_positions()

func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2.0
	return x_offset

func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_drop_combo_cards():
	if combo_cards.size() == 0:
		print("Aucune carte de combo")
		return
	
	for card in combo_cards:
		combo_cards.erase(card)
		update_hand_positions()
		print("Carte(s) de combo perdue(s)")
