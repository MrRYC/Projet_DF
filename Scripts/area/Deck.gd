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
		await draw()

###########################################################################
#                               DECK CREATION                             #
###########################################################################

func load_player_deck():
	for card_id in PLAYERDECK.CARDS.keys():
		#Récupération des données de base des dictionnaires PLAYERDECK et AUGMENTDB
		var card_data = add_augments_to_card_data(card_id)

		#Sauvegarde des datas modifiables des cartes
		var card_data_snapshot := {
			"id":card_data["id"],
			"slot_number":card_data["slot_number"], #attention, il faudra bloquer les slots des augment qui s'inactivent après x utilisation
			"effect_per_slot":{}
		}

		#Sauvegarde des datas modifiables des augments
		if card_data.has("effect_per_slot"):
			for slot_index in card_data["effect_per_slot"].keys():
				var augment = card_data["effect_per_slot"][slot_index]
				if augment.has("uses"):
					if not card_data_snapshot["effect_per_slot"].has(slot_index):
						card_data_snapshot["effect_per_slot"][slot_index] = {}
					card_data_snapshot["effect_per_slot"][slot_index]["id"] = augment["id"]
					card_data_snapshot["effect_per_slot"][slot_index]["uses"] = augment["uses"]

		player_deck.append(card_data_snapshot)

	shuffle()
	deck_size = player_deck.size()

func add_augments_to_card_data(card_id):
	var orignal_data: Dictionary = PLAYERDECK.CARDS[card_id]
	var updated_data: Dictionary = orignal_data.duplicate(true)

	if updated_data.has("effect_per_slot"):
		var card_augment := {}
		for slot_index in updated_data["effect_per_slot"].keys():
			var augment_id = updated_data["effect_per_slot"][slot_index]

			if AUGMENTDB.AUGMENTS.has(augment_id):
				#Copie de l'augment afin de pouvoir gérer les utilisations
				card_augment[slot_index] = AUGMENTDB.AUGMENTS[augment_id].duplicate(true)
			else: #Stockackage de l'augment si inconnu dans la BD
				push_error("Augment '%s' not found in AugmentDB" % augment_id)
				card_augment[slot_index] = {}
		
		updated_data["effect_per_slot"] = card_augment
	
	return updated_data

func create_card_in_hand(card_data):
	var card_id = card_data["id"]

	#Récupération des données de la carte
	var orignal_data: Dictionary = PLAYERDECK.CARDS[card_id]
	var updated_data: Dictionary = orignal_data.duplicate(true)

	#Récupération puis mise à jour des données sauvegardées de la carte
	if updated_data.has("effect_per_slot"):
		var card_augment := {}
		for slot_index in updated_data["effect_per_slot"].keys():
			var augment_id = updated_data["effect_per_slot"][slot_index]

			if AUGMENTDB.AUGMENTS.has(augment_id):
				#Copie de l'augment afin de pouvoir gérer les utilisations
				card_augment[slot_index] = AUGMENTDB.AUGMENTS[augment_id].duplicate(true)
			else: #Stockackage de l'augment si inconnu dans la BD
				push_error("Augment '%s' not found in AugmentDB" % augment_id)
				card_augment[slot_index] = {}
		
		updated_data["effect_per_slot"] = card_augment

	if card_id == "Hook_Card_01":
		print(updated_data)

	#Instanciation de la carte
	var card: CARD = CARD_SCENE.instantiate()
	card.setup_card(updated_data)
	

	#Ajout de l'image
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
	var card_node: CARD = create_card_in_hand(card)
	
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
	for card in player_deck:
		print(card)

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
