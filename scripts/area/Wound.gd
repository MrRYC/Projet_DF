extends Node2D

#constantes
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

#variables génériques
var wound_pile : Array = []

###########################################################################
#                             WOUND MANAGEMENT                            #
###########################################################################

func add_card_to_pile(card):
	#Sauvegarde de l'id et du statut de la carte
	var card_data_snapshot := {
		"id":card["id"],
		"status":card["status"]
	}

	wound_pile.append(card_data_snapshot)
	
	update_label(wound_pile.size())

func update_label(count_cards_in_discard : int):
	$WoundCardCountLabel.text = str(count_cards_in_discard)

func show_pile():
	if wound_pile.is_empty():
		print("Wound pile vide")
		return

	print("📜 Cartes dans la wound pile :")
	for card in wound_pile:
		print(card)
