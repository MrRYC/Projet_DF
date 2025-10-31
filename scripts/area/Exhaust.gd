extends Node2D

#constantes
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

#variables génériques
var exhaust_pile : Array = []

###########################################################################
#                             WOUND MANAGEMENT                            #
###########################################################################

func add_card_to_pile(card):
	#Sauvegarde de l'id de la carte
	var card_data_snapshot := {
		"id":card["id"]
	}

	exhaust_pile.append(card_data_snapshot)

	update_label(exhaust_pile.size())

func update_label(count_cards_in_discard : int):
	$BanishCardCountLabel.text = str(count_cards_in_discard)

func show_pile():
	if exhaust_pile.is_empty():
		print("Wound pile vide")
		return

	print("📜 Cartes dans la Banish pile :")
	for card in exhaust_pile:
		print(card)
