extends Node2D

#constantes
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const DRAW_SPEED = 0.5

#variables de référence vers un autre Node
var card_db_ref
var card_manager_ref
var player_hand_ref
var discard_pile_ref

#variables du script


#variable du deck du joueur
var player_deck = ["Jab_Card", "Jab_Card", "Jab_Card", "Jab_Card", "Direct_Card", "Direct_Card", "Hook_Card", "Hook_Card", "Hypercut_Card"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck.shuffle()
	
	card_manager_ref = $"../CardManager"
	player_hand_ref = $"../PlayerHand"
	discard_pile_ref = $"../DiscardPile"
	card_db_ref = preload("res://Scripts/CardDB.gd")
	
	$DeckCardCountLabel.text = str(player_deck.size())

func draw_card():
	var card_drawn_name = player_deck[0] #Tirage de la première carte du deck
	player_deck.erase(card_drawn_name) #Retrait de la carte du deck
	
	$DeckCardCountLabel.text = str(player_deck.size())
	var card_scene = load(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.card_name = card_drawn_name
	
	#gestion des images des cartes
	var card_image_path = str("res://Assets/CardDB/" + card_drawn_name + ".png")
	new_card.get_node("CardFrontImage").texture = load(card_image_path) #CardFrontImage fait référence au sprite CardFront du Node2D Card
	
	#gestion des valeurs Name, Cost et Attack des cartes
	var card_data = card_db_ref.CARDS[card_drawn_name]
	new_card.get_node("Name").text = card_data[0]
	new_card.get_node("Cost").text = str(card_data[1])
	new_card.get_node("Attack").text = str(card_data[2])
	
	card_manager_ref.add_child(new_card)
	new_card.name = new_card.card_name
	player_hand_ref.add_card_to_hand(new_card, DRAW_SPEED)
	
	#lancement de l'animation de la carte lors de la pioche
	new_card.get_node("CardFlipAnimation").play("card_flip")

func new_turn(new_hand_size):
	if player_deck.size() < new_hand_size:
		discard_pile_ref.reshuffle_discard()
		player_deck.shuffle()
		$DeckCardCountLabel.text = str(player_deck.size())
	
	for i in range(new_hand_size):
		draw_card()
