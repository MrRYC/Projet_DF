extends Node2D

#constantes
const CARD_SCENE = preload("res://scenes/Card.tscn")
const DRAW_SPEED = 0.5

#variables de référence vers un autre Node
@onready var card_manager_ref: Node2D = $"../../CardManager"
@onready var player_hand_ref: Node2D = $"../../PlayerHand"
@onready var card_db_ref = preload("res://scripts/resources/CardDB.gd")

#variables du script
var deck_size

#variable du deck du joueur
var starting_deck : Array = ["Jab_Card", "Jab_Card", "Jab_Card", "Jab_Card", "Cross_Card", "Cross_Card", "Cross_Card", "Hook_Card" , "Uppercut_Card"]
var player_deck_save : Dictionary = {}
var player_deck : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck = starting_deck
	deck_size = player_deck.size()
	shuffle()
	update_label(deck_size)

###########################################################################
#                             TURN MANAGEMENT                             #
###########################################################################

func new_turn(new_hand_size):	
	for i in range(new_hand_size):
		if player_deck.size() == 0:
			EventBus.shuffle_back_discard.emit(true)

		draw_card()
		update_label(player_deck.size())

###########################################################################
#                              DECK MANAGEMENT                            #
###########################################################################

func instanciate_card(id):
	var card = CARD_SCENE.instantiate()
	var card_data = card_db_ref.CARDS[id]
	card.setup_card(card_data)

	#gestion des images des cartes
	card.get_node("CardFrontImage").texture = load(card_data["image"]) #CardFrontImage fait référence au sprite CardFront du Node2D Card
	
	return card

func draw_card():
	print(player_deck)
	var card_drawn = player_deck.pop_front() #Tirage de la première carte du deck
	
	var new_card = instanciate_card(card_drawn)
	card_manager_ref.add_child(new_card)
	player_hand_ref.add_card_to_hand(new_card, DRAW_SPEED)

	##lancement de l'animation de la carte lors de la pioche
	new_card.get_node("CardDrawFlipAnimation").play("card_flip")

func show_pile():
	if player_deck.is_empty():
		print("Deck pile vide")
		return
	
	print("📜 Cartes restantes dans le deck :")
	for card in player_deck:
		var c_data = card_db_ref.CARDS[card]
		print(str(c_data))

func shuffle():
	player_deck.shuffle()

func update_label(cards_in_deck):
	$DeckCardCountLabel.text = str(cards_in_deck)
