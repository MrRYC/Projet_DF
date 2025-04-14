extends Node2D

#constantes
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const DISCARD_SPEED = 0.5

#variables de référence vers un autre Node
var deck_pile_ref

#variables génériques
var player_discard = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_pile_ref = $"../DeckPile"

func add_card_to_discard(card):
	player_discard.append(card)
	# animation de la défausse ?
	card.queue_free() 
	
func reshuffle_discard ():
	deck_pile_ref.player_deck += player_discard
	player_discard.clear()
	$DiscardCardCountLabel.text = "0"
