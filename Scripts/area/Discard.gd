extends Node2D

#constantes
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

#variables de référence vers un autre Node
@onready var deck_pile_ref: Node2D = $"../DeckPile"

#variables génériques
var discard_pile : Array = []

func _ready() -> void:
	EventBus.shuffle_back_discard.connect(_on_deck_empty)

###########################################################################
#                            DISCARD MANAGEMENT                           #
###########################################################################

func add_card_to_pile(card):
	#Sauvegarde des données des slots de la carte
	var card_data_snapshot := {
		"id":card["id"],
		"slot_number":card["slot_number"], #attention, il faudra bloquer les slots des augment qui s'inactivent après x utilisation
		"slot_flip_effect":{}
	}
	
	#if card.slot_flip_effect.has("uses"):
		#card_data_snapshot["slot_flip_effect"]["uses"] = card.slot_flip_effect["uses"]
	
	#Déplacement dans la discard
	discard_pile.append(card_data_snapshot)
	#card_data_snapshot.card_current_area = card_data_snapshot.card_area.IN_DISCARD
	
	update_label(discard_pile.size())

func shuffle_back_discard():
	if discard_pile.is_empty():
		return

	for card in discard_pile.duplicate():
		deck_pile_ref.player_deck.append(card)
	
	clear()
	update_label(0)

func clear():
	discard_pile.clear()

func update_label(discard_size : int):
	$DiscardCardCountLabel.text = str(discard_size)

func show_pile():
	if discard_pile.is_empty():
		print("Discard pile vide")
		return

	print("📜 Cartes restantes dans le deck :")
	for card in discard_pile:
		print(card)
		
func _on_deck_empty(is_deck_empty):
	if is_deck_empty:
		shuffle_back_discard()
