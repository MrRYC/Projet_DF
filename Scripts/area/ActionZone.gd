extends Node2D

#constantes
const ACTION_LANE1_ZONE_X_POSITION = 125
const ACTION_LANE2_ZONE_X_POSITION = 225
const MARKER_SCENE = preload("res://scenes/IntentMarker.tscn")

#variables de référence
@onready var card_manager_ref = $"../CardManager"

#variables du script
var action_zone : Array = []
var intent_markers : Array = []
var end_turn_opponent_marker : Array = []
var processing : bool
var solo_attacker : bool = false

###########################################################################
#                          ACTION ZONE MANAGEMENT                         #
###########################################################################

func add_card_to_action_zone(card):
	if card not in action_zone:
		action_zone.insert(0,card)
		card.current_area = card.board_area.IN_ACTION_ZONE
		card_manager_ref.update_card_size(card)
		update_action_zone_positions()

func return_card_to_hand(card):
	var action_zone_copy = action_zone.duplicate()
	var index = action_zone.find(card)
	
	for i in range(0,index+1):
		var c = action_zone_copy[i]
		c.target = null
		if c.is_flipped:
			card_manager_ref.flip_card_in_hand(c)
		card_manager_ref.return_card_to_hand(c)
		remove_card_from_action_zone(c)
	update_action_zone_positions()


func remove_card_from_action_zone(card):
	action_zone.erase(card)

func empty_action_zone():
	var action_zone_copy = action_zone.duplicate()
	for card in action_zone_copy:
		if card.is_flipped:
			card_manager_ref.flip_card_in_hand(card)
		card_manager_ref.return_card_to_hand(card)

	action_zone.clear()

###########################################################################
#                              CARDS POSITION                             #
###########################################################################

func update_action_zone_positions():
	var action_zone_y_position = 150
	var action_zone_x_position = ACTION_LANE1_ZONE_X_POSITION
	var offset = 0

	for i in range(action_zone.size()-1, -1, -1): #-1, -1, -1 permet de lire le tableau en sens inverse
		var card = action_zone[i]
		
		if !card.is_flipped:
			offset = 0
		else:
			offset = 1

		#gestion du positionnement en cascade des cartes dans l'action zone
		if (action_zone.size() % 2 == 0) && (i % 2 == 0): #action zone pair et index de la carte pair --> lane 2
			action_zone_x_position = ACTION_LANE2_ZONE_X_POSITION
		elif (action_zone.size() % 2 == 0) && !(i % 2 == 0): #action zone pair et index de la carte impair --> lane 1
			action_zone_x_position = ACTION_LANE1_ZONE_X_POSITION
		elif !(action_zone.size() % 2 == 0) && (i % 2 == 0): #action zone impair et index de la carte pair --> lane 1
			action_zone_x_position = ACTION_LANE1_ZONE_X_POSITION
		else: #action zone impair et index de la carte impair --> lane 2
			action_zone_x_position = ACTION_LANE2_ZONE_X_POSITION

		var new_position = Vector2(action_zone_x_position, action_zone_y_position+offset)
		card.starting_position = new_position
		animate_card_to_position(card, new_position)

		update_intent_markers_positions()
		update_end_turn_opponent_marker_ordering()

		#Gestion de l'espacement si la carte est inversée
		if !card.is_flipped:
			action_zone_y_position += 71
		else:
			action_zone_y_position += 72

func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, Global.HAND_DRAW_INTERVAL)

###########################################################################
#                        OPPONENTS INTENT ORDER                           #
###########################################################################

func save_intent_markers(incoming_attack):

	if incoming_attack.size() == 1:
		solo_attacker = true
	else:
		solo_attacker = false

	for o in incoming_attack:
		var m: MARKER = MARKER_SCENE.instantiate()
		m.opponent = o
		m.array_position = o.data.attack_threshold #Sauvegarde de l'Attack Threshold de l'opponent
		m.set_color()
		
		add_child(m)
	
		#Affichage du marqueur d'intention
		threshold_opponent_marker_ordering(m)

	end_turn_opponent_marker_ordering()

func threshold_opponent_marker_ordering(marker):

	#Les ennemis qui attaquent à la fin (attack_threshold == 0) sont toujours en dernier
	if marker.array_position == 0:
		if solo_attacker:
			intent_markers.append(marker)
			marker.opponent.update_attack_order()
		else:
			end_turn_opponent_marker.append(marker)
		return

	#Gestion des ennemi avec une attack_threshold
	var desired_index = marker.array_position-1

	if intent_markers.size() <= desired_index:
		intent_markers.resize(desired_index + 1)

	if intent_markers[desired_index] == null:
		intent_markers[desired_index] = marker
		marker.array_position = desired_index
		marker.opponent.attack_order = marker.opponent.data.attack_threshold
	else:
		#Si l'ennemi a le même attack_threshold qu'un autre, on ajoute le marqeur dans l'array à partir de 'desired_index'
		shift_right_from(desired_index + 1)
		intent_markers[desired_index + 1] = marker
		marker.array_position = desired_index + 1
		marker.opponent.attack_order = marker.opponent.data.attack_threshold + 1
	
	marker.opponent.update_attack_order()

func end_turn_opponent_marker_ordering():
	if end_turn_opponent_marker.size() == 0:
		return

	for marker in end_turn_opponent_marker:
		intent_markers.append(marker)

func update_end_turn_opponent_marker_ordering():
	if end_turn_opponent_marker == null:
		return

	for marker in end_turn_opponent_marker:
		if marker.opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THE_END:
			marker.opponent.attack_order = action_zone.size()
			marker.opponent.update_attack_order()

# Décalage de tous les éléments vers la droite à partir d'un index donné
func shift_right_from(start_index: int) -> void:

	if start_index < 0:
		start_index = 0
	if start_index > intent_markers.size():
		start_index = intent_markers.size()
		
	#Augmentation de la taille de l'array d'une case pour permettre le shift
	intent_markers.insert(start_index, null)

	# Met à jour array_position pour les markers valides
	for i in range(start_index, intent_markers.size()):
		if intent_markers[i] != null:
			intent_markers[i].array_position = i

func init_markers_position():
	var marker_y_position = 150
	var marker_x_position = ACTION_LANE1_ZONE_X_POSITION
	var lane1 = true

	#Positionnement initial des marqueurs d'intention
	for i in range(intent_markers.size()):
		var m = intent_markers[i]
		if m == null:
			continue # protège contre les trous dans l'array
		if lane1 :
			marker_x_position = ACTION_LANE1_ZONE_X_POSITION
			lane1 = false
		elif !lane1:
			marker_x_position = ACTION_LANE2_ZONE_X_POSITION
			lane1 = true

		m.position = Vector2(marker_x_position, marker_y_position)
		m.toggle_border(true)
		
		marker_y_position += 72

func update_intent_markers_positions():
	pass
	
func remove_null_markers():
	var new_arr : Array = []
	for m in intent_markers:
		if m != null:
			m.array_position = new_arr.size()
			new_arr.append(m)
	intent_markers = new_arr
		
func clear_all_intents():
	for m in intent_markers:
		if is_instance_valid(m):
			m.queue_free()
	intent_markers.clear()

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_empty_action_zone_button_pressed():
	if action_zone.size() > 0:
		empty_action_zone()

	if intent_markers.size() > 0:
		init_markers_position()
