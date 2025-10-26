extends Node2D

#constantes
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

#variables génériques
var wound_pile_id = []

###########################################################################
#                             WOUND MANAGEMENT                            #
###########################################################################

func add_card_to_pile(card):
	wound_pile_id.append(card.id)
	card.queue_free()
	update_label(wound_pile_id.size())

func update_label(count_cards_in_discard : int):
	$WoundCardCountLabel.text = str(count_cards_in_discard)

func show_pile():
	if wound_pile_id.is_empty():
		print("Wound pile vide")
		return

	print("📜 Cartes dans la wound pile :")
	for card_id in wound_pile_id:
		var card_db_ref = load("res://scripts/resources/CardDB.gd")
		var c_data = card_db_ref.CARDS[card_id]
		print(str(c_data))
