extends Node2D

#constantes
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

#variables génériques
var wound_pile : Array = []

###########################################################################
#                             WOUND MANAGEMENT                            #
###########################################################################

func add_card_to_pile(card):
	wound_pile.insert(0,card)
	update_label(wound_pile.size())

func update_label(count_cards_in_discard : int):
	$WoundCardCountLabel.text = str(count_cards_in_discard)

func show_pile():
	if wound_pile.is_empty():
		print("Wound pile vide")
		return

	print("📜 Cartes dans la wound pile :")
	for card in wound_pile:
		var card_db_ref = load("res://scripts/resources/CardDB.gd")
		var c_data = card_db_ref.CARDS[card.id]
		print(str(c_data))
