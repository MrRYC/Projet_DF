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
var player_deck : Array[CARD] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for id in starting_deck:
		instanciate_card(id)

	shuffle()
	deck_size = player_deck.size()

###########################################################################
#                             TURN MANAGEMENT                             #
###########################################################################

func new_turn(new_hand_size):
	var tween := create_tween()
	for i in range(new_hand_size):
		if player_deck.size() == 0:
			EventBus.shuffle_back_discard.emit(true)
		
		tween.tween_callback(draw_card)
		tween.tween_interval(Global.HAND_DRAW_INTERVAL)

###########################################################################
#                              DECK MANAGEMENT                            #
###########################################################################

func add_card(card: CARD):
	player_deck.append(card)

func instanciate_card(id):
	var card = CARD_SCENE.instantiate()
	card.id = id
	var card_data = card_db_ref.CARDS[id]
	card.setup_card(card_data)

	#gestion des images des cartes
	card.get_node("CardFrontImage").texture = load(card_data["image"]) #CardFrontImage fait référence au sprite CardFront du Node2D Card
	
	add_card(card)

func draw_card():
	var card_drawn = player_deck.pop_front() #Tirage de la première carte du deck
	
	card_manager_ref.add_child(card_drawn)
	player_hand_ref.add_card_to_hand(card_drawn, DRAW_SPEED)

	##lancement de l'animation de la carte lors de la pioche
	card_drawn.get_node("CardDrawFlipAnimation").play("card_flip")
	
	update_label(player_deck.size())

func show_pile():
	if player_deck.is_empty():
		print("Deck pile vide")
		return
	
	print("📜 Cartes restantes dans le deck :")
	for card in player_deck:
		var c_data = card_db_ref.CARDS[card.id]
		print(str(c_data))

func shuffle():
	player_deck.shuffle()

func update_label(cards_in_deck):
	$DeckCardCountLabel.text = str(cards_in_deck)
