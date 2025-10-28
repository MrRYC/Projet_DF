extends Node2D

#constantes
const CARD_SCENE_PATH = preload("res://scenes/Card.tscn")
const DRAW_SPEED = 0.5

#variables de référence vers un autre Node
@onready var card_manager_ref: Node2D = $"../../CardManager"
@onready var player_hand_ref: Node2D = $"../../PlayerHand"
@onready var card_db_ref = preload("res://scripts/resources/CardDB.gd")

#variables du script
var deck_size
var dictionary_id
var card_id_number = 1

#variable du deck du joueur
var starting_deck : Array = ["Jab_Card", "Jab_Card", "Jab_Card", "Jab_Card", "Cross_Card", "Cross_Card", "Cross_Card", "Hook_Card" , "Uppercut_Card"]
var player_deck_save : Dictionary = {}
var player_deck : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck = starting_deck
	
	for id in starting_deck:
		dictionary_id = str(id)+"_"+str(card_id_number)
		instanciate_card(id, dictionary_id)
		player_deck.insert[id,dictionary_id]
		print(player_deck[id])
		
		card_id_number += 1

	#for id in player_deck:
		#print(str(player_deck[id]))

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

func instanciate_card(starting_deck_id, dictionnary_deck_id):
	var new_card = CARD_SCENE_PATH.instantiate()
	var card_data = card_db_ref.CARDS[starting_deck_id]
	new_card.setup_card(card_data)

	player_deck_save[dictionnary_deck_id] = card_data

	#gestion des images des cartes
	new_card.get_node("CardFrontImage").texture = load(card_data["image"]) #CardFrontImage fait référence au sprite CardFront du Node2D Card

func draw_card():
	var new_card_drawn = player_deck.pop_front() #Tirage de la première carte du deck
	new_card_drawn.card_current_area = new_card_drawn.card_area.IN_HAND
	card_manager_ref.add_child(new_card_drawn)
	player_hand_ref.add_card_to_hand(new_card_drawn, DRAW_SPEED)

	##lancement de l'animation de la carte lors de la pioche
	new_card_drawn.get_node("CardDrawFlipAnimation").play("card_flip")

func show_pile():
	if player_deck.is_empty():
		print("Deck pile vide")
		return
	
	print("📜 Cartes restantes dans le deck :")
	#for card in player_deck:
		#var c_data = card_db_ref.CARDS[card.id]
		#print(str(c_data))

func shuffle():
	player_deck.shuffle()

func update_label(cards_in_deck):
	$DeckCardCountLabel.text = str(cards_in_deck)
