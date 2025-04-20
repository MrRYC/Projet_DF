extends Node2D

#constantes
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const DRAW_SPEED = 0.5

#variables de référence vers un autre Node
@onready var card_manager_ref = $"../CardManager"
@onready var player_hand_ref = $"../PlayerHand"
@onready var discard_pile_ref = $"../DiscardPile"
@onready var card_db_ref = preload("res://Scripts/CardDB.gd")

#variables du script

#variable du deck du joueur
var player_deck = ["Jab_Card", "Jab_Card", "Jab_Card", "Direct_Card", "Direct_Card", "Hook_Card", "Hypercut_Card"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck.shuffle()
	update_label(player_deck.size())

###########################################################################
#                              DECK MANAGEMENT                            #
###########################################################################
	
func draw_card():
	var card_drawn_name = player_deck[0] #Tirage de la première carte du deck
	player_deck.erase(card_drawn_name) #Retrait de la carte du deck
	
	update_label(player_deck.size())
	
	var card_scene = load(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.card_name = card_drawn_name #conservation du nom de la carte dans une variable afin de le relier au nom de l'image correspondante après un reshuffle de la discard dans le deck
	
	#gestion des images des cartes
	var card_image_path = str("res://Assets/CardDB/" + card_drawn_name + ".png")
	new_card.get_node("CardFrontImage").texture = load(card_image_path) #CardFrontImage fait référence au sprite CardFront du Node2D Card
	
	#gestion des valeurs Name, Cost et Attack des cartes
	var card_data = card_db_ref.CARDS[card_drawn_name]
	new_card.setup_card(card_data)
	
	card_manager_ref.add_child(new_card)
	player_hand_ref.add_card_to_hand(new_card, DRAW_SPEED)
	
	#print(new_card.card_name ," ", new_card.cost ," ", new_card.attack ," ", new_card.animation_time)
	
	#lancement de l'animation de la carte lors de la pioche
	new_card.get_node("CardDrawFlipAnimation").play("card_flip")

#put back card in hand or action zone in deck
#func put_card_in_deck ():
	#for card in ???:
		#card.is_in_action_zone = false
		#...

func new_turn(new_hand_size):
	if player_deck.size() < new_hand_size:
		discard_pile_ref.reshuffle_discard()
		player_deck.shuffle()
		update_label(player_deck.size())
	
	for i in range(new_hand_size):
		draw_card()

func update_label(count_cards_in_deck : int):
	$DeckCardCountLabel.text = str(count_cards_in_deck)
