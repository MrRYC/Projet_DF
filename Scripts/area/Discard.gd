extends Node2D

#constantes
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

#variables de référence vers un autre Node
@onready var deck_pile_ref: Node2D = $"../DeckPile"

#variables génériques
var discard_pile : Array[CARD] = []

func _ready() -> void:
	EventBus.shuffle_back_discard.connect(_on_deck_empty)

###########################################################################
#                            DISCARD MANAGEMENT                           #
###########################################################################

func add_card_to_pile(card):
	discard_pile.insert(0,card)
	update_label(discard_pile.size())
	print(discard_pile)

func shuffle_back_discard():
	print(discard_pile)
	
	if discard_pile.is_empty():
		return

	while discard_pile.size() > 0:
		deck_pile_ref.add_card(discard_pile.pop_front())
	
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
