extends Node2D

#constantes
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const DISCARD_SPEED = 0.5

#variables de référence vers un autre Node
var deck_pile_ref

#variables génériques
var player_discard = []
var count_cards_in_discard = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_pile_ref = $"../DeckPile"

func add_card_to_discard(card):
	player_discard.append(card.card_name)
	card.queue_free()
	
	#var discard_position = self.position
	#var tween = get_tree().create_tween()
	#tween.tween_property(card, "position", discard_position, DISCARD_SPEED)

	$DiscardCardCountLabel.text = str(player_discard.size())
	
func reshuffle_discard ():
	if player_discard.size() == 0:
		return
	
	deck_pile_ref.player_deck += player_discard
	player_discard.clear()
	$DiscardCardCountLabel.text = "0"


func _on_area_2d_mouse_entered() -> void:
	pass # Replace with function body.


func _on_area_2d_mouse_exited() -> void:
	pass # Replace with function body.
