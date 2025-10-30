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
	var card_id = card.id
	var card_id_data: Dictionary = {
		"id": card_id,
		"attack": card.attack,
		"animation_time": card.animation_time,
	}
	discard_pile.append(card_id_data)
	card.card_current_area = card.card_area.IN_DISCARD
	update_label(discard_pile.size())

func shuffle_back_discard():
	if discard_pile.is_empty():
		return

	while discard_pile.size() > 0:
		deck_pile_ref.append(discard_pile.pop_front())
	
	print(deck_pile_ref.player_deck)
	
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
		var card_db_ref = load("res://scripts/resources/CardDB.gd")
		var c_data = card_db_ref.CARDS[card.id]
		print(str(c_data))
		
func _on_deck_empty(is_deck_empty):
	if is_deck_empty:
		shuffle_back_discard()
