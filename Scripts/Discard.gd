extends Node2D

#constantes
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const DISCARD_SPEED = Global.DEFAULT_CARD_MOVE_SPEED*2

#variables de référence vers un autre Node
@onready var deck_pile_ref = $"../DeckPile"

#variables génériques
var player_discard = []

###########################################################################
#                            DISCARD MANAGEMENT                           #
###########################################################################

func add_card_to_discard(card):
	player_discard.append(card.card_name)
	card.queue_free()
	update_label(player_discard.size())
	
func reshuffle_discard():
	if player_discard.size() == 0:
		return
	
	deck_pile_ref.player_deck += player_discard
	player_discard.clear()
	update_label(0)

func update_label(count_cards_in_discard : int):
	$DiscardCardCountLabel.text = str(count_cards_in_discard)
