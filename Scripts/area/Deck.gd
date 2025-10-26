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

#variable du deck du joueur
var deck_pile_id : Array = ["Jab_Card", "Jab_Card", "Jab_Card", "Cross_Card", "Cross_Card", "Hook_Card" , "Uppercut_Card"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_size = deck_pile_id.size()
	shuffle()
	update_label(deck_size)

###########################################################################
#                             TURN MANAGEMENT                             #
###########################################################################

func new_turn(new_hand_size):	
	for i in range(new_hand_size):
		if deck_pile_id.size() == 0:
			EventBus.shuffle_back_discard.emit(true)

		draw_card()
		update_label(deck_pile_id.size())

###########################################################################
#                              DECK MANAGEMENT                            #
###########################################################################

func instanciate_card(id):
	var card = CARD_SCENE_PATH.instantiate()
	card.id = id #conservation du nom de la carte permettant de le relier à l'image correspondante après un shuffle de la discard dans le deck
	
	#gestion des images des cartes
	var card_image_path = str("res://assets/fighting_style/boxing/" + id + ".png")
	card.get_node("CardFrontImage").texture = load(card_image_path) #CardFrontImage fait référence au sprite CardFront du Node2D Card
	
	#gestion des valeurs Name, Cost et Attack des cartes
	var card_data = card_db_ref.CARDS[id]
	card.setup_card(card_data)
	
	return card
	
func draw_card():
	var card_drawn_id = deck_pile_id[0] #Tirage de la première carte du deck
	deck_pile_id.erase(card_drawn_id) #Retrait de la carte du deck
	
	var new_card = instanciate_card(card_drawn_id)
	
	card_manager_ref.add_child(new_card)
	player_hand_ref.add_card_to_hand(new_card, DRAW_SPEED)
	
	#lancement de l'animation de la carte lors de la pioche
	new_card.get_node("CardDrawFlipAnimation").play("card_flip")

func show_pile():
	if deck_pile_id.is_empty():
		print("Deck pile vide")
		return
	
	print("📜 Cartes restantes dans le deck :")
	for card_id in deck_pile_id:
		var c_data = card_db_ref.CARDS[card_id]
		print(str(c_data))

func shuffle():
	deck_pile_id.shuffle()

func update_label(cards_in_deck):
	$DeckCardCountLabel.text = str(cards_in_deck)
