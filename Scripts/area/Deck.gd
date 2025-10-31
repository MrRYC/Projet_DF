extends Node2D

#constantes
const CARD_SCENE = preload("res://scenes/Card.tscn")

#variables de référence vers un autre Node
@onready var card_manager_ref: Node2D = $"../../CardManager"
@onready var player_hand_ref: Node2D = $"../../PlayerHand"

#variables du script
var player_deck : Array = []
var deck_size : int = 0
var nb_turn : int = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.turn_increased.connect(_on_turn_increase)
	EventBus.new_turn.connect(_on_new_turn)

	#instanciation du deck du joueur
	load_player_deck()

###########################################################################
#                             TURN MANAGEMENT                             #
###########################################################################
func new_turn(new_hand_size):
	for i in range(new_hand_size):
		print(player_deck)
		await draw()

###########################################################################
#                               DECK CREATION                             #
###########################################################################

func load_player_deck():
	for card in PLAYERDECK.CARDS.keys():
		#Récupération de données du dictionnaire de la carte (id et id des augment utilisés)
		var card_data = PLAYERDECK.CARDS[card]
		
		var card_data_snapshot := {
			"id":card_data["id"],
			"slot_number":card_data["slot_number"], #attention, il faudra bloquer les slots des augment qui s'inactivent après x utilisation
			"slot_flip_effect":{}
		}

		player_deck.append(card_data_snapshot)

	shuffle()
	deck_size = player_deck.size()

func recreate_card_from_snapshot(snapshot):
	var card_id = snapshot["id"]

	#Récupération des données de la carte
	var orignal_data: Dictionary = PLAYERDECK.CARDS[card_id]
	var updated_data: Dictionary = orignal_data.duplicate(true)

	#Mise à jour des données sauvegardées de la carte
	#if snapshot.has("slot_flip_effect") \
	#and snapshot["slot_flip_effect"].has("uses") \
	#and updated_data.has("slot_flip_effect"):
		#updated_data["slot_flip_effect"]["uses"] = snapshot["slot_flip_effect"]["uses"]

	#Instanciation de la carte
	var card: CARD = CARD_SCENE.instantiate()
	card.setup_card(updated_data)

	#Ajour de l'image
	if updated_data.has("image"):
		card.get_node("CardFrontImage").texture = load(updated_data["image"])

	return card

###########################################################################
#                               CARD ENGINE                               #
###########################################################################

func add_card(card):
	player_deck.append(card)

func draw():
	if player_deck.size() == 0 && 	nb_turn > 1:
		EventBus.shuffle_back_discard.emit(true)

	var card = player_deck.pop_front() #Tirage de la première carte du deck
	var card_node: CARD = recreate_card_from_snapshot(card)
	
	card_manager_ref.add_child(card_node)
	player_hand_ref.add_card_to_hand(card_node)

	##lancement de l'animation de la carte lors de la pioche
	card_node.get_node("CardDrawFlipAnimation").play("card_flip")

	await get_tree().create_timer(Global.HAND_DRAW_INTERVAL).timeout

	player_deck.erase(card)
	update_label(player_deck.size())

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

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_turn_increase(turn):
	nb_turn = turn

func _on_new_turn(new_hand_size):
	new_turn(new_hand_size)
