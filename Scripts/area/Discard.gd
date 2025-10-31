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
	var card_data = card.id
	#Sauvegarde des données des slots de la carte
	var card_data_snapshot := {
		"id":card_data,
		"slot_number":card["slot_number"], #attention, il faudra bloquer les slots des augment qui s'inactivent après x utilisation
		"effect_per_slot":{}
	}
	
	#Sauvegarde des datas modifiables des augments
	if card.slot_number > 0:
		for slot_index in card.effect_per_slot.keys():
			#Récupération des augment des slots de la carte
			var slot_effect = card.effect_per_slot[slot_index]
			
			if not card_data_snapshot["effect_per_slot"].has(slot_index):
				card_data_snapshot["effect_per_slot"][slot_index] = {}
			
			if slot_effect.has("uses"):
				card_data_snapshot["effect_per_slot"][slot_index]["id"] = slot_effect["id"]
				card_data_snapshot["effect_per_slot"][slot_index]["uses"] = slot_effect["uses"]
	
	#Déplacement dans la discard
	discard_pile.append(card_data_snapshot)

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
