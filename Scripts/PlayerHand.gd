extends Node2D

#constantes
const CARD_WIDTH = 175 #espace entre les cartes
const HAND_Y_POSITION = 950 #hauteur de la zone des cartes en main
const DEFAULT_CARD_MOVE_SPEED = 0.1

#variables de référence vers autre Node
@onready var discard_pile_ref = $"../DiscardPile"

#variables du script
@onready var center_screen_x = get_viewport().size.x / 2
var player_hand = []

func add_card_to_hand(card, speed):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.starting_position, DEFAULT_CARD_MOVE_SPEED)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)

func discard_hand():
	for card in player_hand:
		discard_pile_ref.add_card_to_discard(card)
		
	player_hand.clear()

func update_hand_positions(speed):
	for i in range(player_hand.size()):
		#Position de la nouvelle carte en fonction de l'index
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position, speed)

func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2

	return x_offset

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
