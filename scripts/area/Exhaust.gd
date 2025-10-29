extends Node2D

#constantes
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

#variables génériques
var exhaust_pile : Array = []

###########################################################################
#                             WOUND MANAGEMENT                            #
###########################################################################

func add_card_to_pile(card):
	exhaust_pile.insert(0,card)
	update_label(exhaust_pile.size())

func update_label(count_cards_in_discard : int):
	$BanishCardCountLabel.text = str(count_cards_in_discard)

func show_pile():
	if exhaust_pile.is_empty():
		print("Wound pile vide")
		return

	print("📜 Cartes dans la Banish pile :")
	for card in exhaust_pile:
		var card_db_ref = load("res://scripts/resources/CardDB.gd")
		var c_data = card_db_ref.CARDS[card.id]
		print(str(c_data))
