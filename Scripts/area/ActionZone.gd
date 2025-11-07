extends Node2D

#constantes
const action_lane1_ZONE_X_POSITION = 125
const action_lane2_ZONE_X_POSITION = 225
const MARKER_SCENE = preload("res://scenes/IntentMarker.tscn")

#variables de référence
@onready var card_manager_ref = $"../CardManager"

#variables du script
var action_zone = []
var intent_markers = []
var processing : bool
var marker_color : int = 0

###########################################################################
#                          ACTION ZONE MANAGEMENT                         #
###########################################################################

func add_card_to_action_zone(card):
	if card not in action_zone:
		action_zone.insert(0,card)
		card.current_area = card.board_area.IN_ACTION_ZONE
		card_manager_ref.update_card_size(card)
		update_action_zone_positions()
#
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
	var action_zone_x_position = action_lane1_ZONE_X_POSITION
	var offset = 0
	var marker_index = 0

	for i in range(action_zone.size()-1, -1, -1): #-1, -1, -1 permet de lire le tableau en sens inverse
		var card = action_zone[i]
		
		if !card.is_flipped:
			offset = 0
		else:
			offset = 1

		#gestion du positionnement en cascade des cartes dans l'action zone
		if (action_zone.size() % 2 == 0) && (i % 2 == 0): #action zone pair et index de la carte pair --> lane 2
			action_zone_x_position = action_lane2_ZONE_X_POSITION
		elif (action_zone.size() % 2 == 0) && !(i % 2 == 0): #action zone pair et index de la carte impair --> lane 1
			action_zone_x_position = action_lane1_ZONE_X_POSITION
		elif !(action_zone.size() % 2 == 0) && (i % 2 == 0): #action zone impair et index de la carte pair --> lane 1
			action_zone_x_position = action_lane1_ZONE_X_POSITION
		else: #action zone impair et index de la carte impair --> lane 2
			action_zone_x_position = action_lane2_ZONE_X_POSITION

		var new_position = Vector2(action_zone_x_position, action_zone_y_position+offset)
		card.starting_position = new_position
		animate_card_to_position(card, new_position)

		##Gestion de la position des marqueurs d'intentions
		#if intent_markers[marker_index] != null:
			#intent_markers[marker_index].position = new_position
		#marker_index += 1

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

func save_intent_markers(opponent):
	var m : MARKER = MARKER_SCENE.instantiate()
	m.opponent = opponent
	m.array_position = opponent.data.attack_threshold #Sauvegarde de l'Attack Threshold de l'opponent
	m.set_color(marker_color)
	marker_color += 1
	add_child(m)
	
	#Affichage du marqueur d'intention
	marker_ordering(m)

func marker_ordering(marker):
	var desired_index = 0

	if marker.array_position > 0:
		desired_index = marker.array_position-1
	
	#Les ennemis qui attaquent à la fin (attack_threshold == 0) sont toujours en dernier
	if desired_index == 0:
		intent_markers.append(marker)
		marker.array_position = intent_markers.size() - 1
	else:
		#Gestion à la volée de la taille de l'array
		if intent_markers.size() <= desired_index:
			intent_markers.resize(desired_index + 1)

		if intent_markers[desired_index] == null:
			intent_markers[desired_index] = marker
			marker.array_position = desired_index
		else:
			#Si l'ennemi a le même attack_threshold qu'un autre, on décale l'array à partir de 'desired_index'
			shift_right_from(desired_index)
			intent_markers[desired_index + 1] = marker
			marker.array_position = desired_index + 1
			
	print(str(marker.opponent)+ " - " + str(desired_index) + " - " + str(marker.opponent_color))

# Décalage de tous les éléments vers la droite à partir d'un index donné
func shift_right_from(start_index: int) -> void:
	#Augmentation de la taille de l'array d'une case pour permettre le shift
	intent_markers.append(null)

	# décale vers la droite
	for i in range(intent_markers.size() - 1, start_index + 1, -1):
		intent_markers[i] = intent_markers[i - 1]
	# si on a déplacé un marker existant, incrémente sa array_position
		if intent_markers[i] != null:
			intent_markers[i].array_position = i

func init_markers_position():
	var marker_y_position = 150
	var marker_x_position = action_lane1_ZONE_X_POSITION

	#Positionnement initial des marqueurs d'intention
	for i in range(intent_markers.size()-1, -1, -1): #-1, -1, -1 permet de lire le tableau en sens inverse
		#gestion du positionnement en cascade des cartes dans l'action zone
		if (intent_markers.size() % 2 == 0) && (i % 2 == 0): #action zone pair et index de la carte pair --> lane 2
			marker_x_position = action_lane2_ZONE_X_POSITION
		elif (intent_markers.size() % 2 == 0) && !(i % 2 == 0): #action zone pair et index de la carte impair --> lane 1
			marker_x_position = action_lane1_ZONE_X_POSITION
		elif !(intent_markers.size() % 2 == 0) && (i % 2 == 0): #action zone impair et index de la carte pair --> lane 1
			marker_x_position = action_lane1_ZONE_X_POSITION
		else: #action zone impair et index de la carte impair --> lane 2
			marker_x_position = action_lane2_ZONE_X_POSITION

		intent_markers[i].position = Vector2(marker_x_position, marker_y_position)
		intent_markers[i].toggle_border(true)
		
		marker_y_position += 72

func remove_null_markers():
	var new_arr = []
	for m in intent_markers:
		if m != null:
			m.array_position = new_arr.size()
			new_arr.append(m)
	intent_markers = new_arr

func reset_markers_position():
	for m in intent_markers:
		m.position = Vector2(125, 150)
		
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
		reset_markers_position()
