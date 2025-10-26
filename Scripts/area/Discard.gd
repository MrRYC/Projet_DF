extends Node2D

#constantes
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

#variables de référence vers un autre Node
@onready var deck_pile_ref: Node2D = $"../DeckPile"

#variables génériques
var discard_pile_id = []

func _ready() -> void:
	EventBus.shuffle_back_discard.connect(_on_deck_empty)

###########################################################################
#                            DISCARD MANAGEMENT                           #
###########################################################################

func add_card_to_pile(card):
	discard_pile_id.append(card.id)
	card.queue_free()
	update_label(discard_pile_id.size())

func shuffle_back_discard():
	if discard_pile_id.size() == 0:
		return
	
	deck_pile_ref.deck_pile_id += discard_pile_id
	
	clear()
	update_label(0)
	
func clear():
	discard_pile_id.clear()

func update_label(count_cards_in_discard : int):
	$DiscardCardCountLabel.text = str(count_cards_in_discard)

func show_pile():
	if discard_pile_id.is_empty():
		print("Discard pile vide")
		return
	
	print("📜 Cartes dans la discard :")
	for card_id in discard_pile_id:
		var card_db_ref = load("res://scripts/resources/CardDB.gd")
		var c_data = card_db_ref.CARDS[card_id]
		print(str(c_data["name"]) + " " + str(c_data["animation_time"]) + " " + str(c_data["attack"]))
		
func _on_deck_empty(is_deck_empty):
	if is_deck_empty:
		shuffle_back_discard()
