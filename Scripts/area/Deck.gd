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
		var card = build_card_from_dictionaries(card_id)
		player_deck.append(card)

	shuffle()
	deck_size = player_deck.size()
	EventBus.deck_loaded.emit(deck_size)

func build_card_from_dictionaries(card_id):
	var card_data = add_augments(card_id)

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
	
	return card_data_snapshot

func add_augments(card_id):
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

###########################################################################
#                               DRAW ENGINE                               #
###########################################################################

func add_card(card):
	player_deck.append(card)

func draw():
	if player_deck.size() == 0 && 	nb_turn > 1:
		EventBus.shuffle_back_discard.emit(true)

	var card = player_deck.pop_front() #Tirage de la première carte du deck
	var card_node: CARD_DATA = create_card_in_hand(card)
	
	card_manager_ref.add_child(card_node)
	player_hand_ref.add_card_to_hand(card_node)

	##lancement de l'animation de la carte lors de la pioche
	card_node.get_node("CardDrawFlipAnimation").play("card_flip")

	await get_tree().create_timer(Global.HAND_DRAW_INTERVAL).timeout

	player_deck.erase(card)
	update_label(player_deck.size())

func create_card_in_hand(card_data):
	var card_id = card_data["id"]
	var effect_inactive = false

	#Récupération des données de la carte
	var orignal_data: Dictionary = PLAYERDECK.CARDS[card_id]
	var updated_data: Dictionary = orignal_data.duplicate(true)

	#Récupération puis mise à jour des données sauvegardées de la carte
	if updated_data.has("effect_per_slot"):
		var card_augment := {}
		for slot_index in updated_data["effect_per_slot"].keys():
			var slot_effect = card_data.effect_per_slot[slot_index]
			var augment_id = updated_data["effect_per_slot"][slot_index]

			if AUGMENTDB.AUGMENTS.has(augment_id):
				#Copie de l'augment afin de pouvoir gérer les utilisations
				card_augment[slot_index] = AUGMENTDB.AUGMENTS[augment_id].duplicate(true)
				#Mise à jour de la valeur "uses" de l'augment
				if slot_effect.has("uses"):
					card_augment[slot_index]["uses"] = slot_effect["uses"]
			else: #Stockackage de l'augment si inconnu dans la BD
				push_error("Augment '%s' not found in AugmentDB" % augment_id)
				card_augment[slot_index] = {}
		
		updated_data["effect_per_slot"] = card_augment
	print(updated_data.effect_per_slot["uses"])
	if updated_data.effect_per_slot["uses"]==0 && updated_data.effect_per_slot["side_effect"]=="inactivate":
		effect_inactive =true
	else:
		effect_inactive = false
		
	#Instanciation de la carte
	var card: CARD_DATA = CARD_SCENE.instantiate()
	card.setup_card(updated_data)

	#Ajout de l'image
	if effect_inactive:
		card.get_node("CardFrontImage").texture = load("res://assets/resources/augments/Augment_Inactivated.png")
	elif updated_data.has("image"):
		card.get_node("CardFrontImage").texture = load(updated_data["image"])

	return card

###########################################################################
#                               CARD ENGINE                               #
###########################################################################

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
