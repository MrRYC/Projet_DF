extends Node2D

#constantes
const action_lane1_ZONE_X_POSITION = 125
const action_lane2_ZONE_X_POSITION = 225
const MARKER_SCENE = preload("res://scenes/Intent_Marker.tscn")

#variables de référence
@onready var card_manager_ref = $"../CardManager"

#variables du script
var action_zone = []
var intent_markers = []
var processing : bool

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

		if !card.is_flipped:
			action_zone_y_position += 71
		else:
			action_zone_y_position += 72
		
	update_intent_markers()

func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, Global.HAND_DRAW_INTERVAL)

###########################################################################
#                            OPPONENTS INTENT                             #
###########################################################################

func save_intent_markers(opponent):
	var m : MARKER = MARKER_SCENE.instantiate()
	add_child(m)
	intent_markers.append(m)
	
	m.opponent = opponent
	m.attack_threshold = opponent.data.attack_threshold
	m.change_color()
	m.position = Vector2(125, 150)

func update_intent_markers():
	for m in intent_markers:
		if action_zone.size() < m.attack_threshold:
			update_markers_position(m)
			print("je décalle le marqueur")
		else:
			print("je suis à la position de mon marqueur - carte n° "+str(m.attack_threshold))

func update_markers_position(marker):
	var action_zone_y_position = 150
	var action_zone_x_position = action_lane1_ZONE_X_POSITION
	var offset = 0
	var action_zone_copy = action_zone.duplicate()
	action_zone_copy.insert(0,marker)

	for i in range(action_zone_copy.size()-1, -1, -1): #-1, -1, -1 permet de lire le tableau en sens inverse
		var element = action_zone_copy[i]

		if element is MARKER:
			pass
		elif !element.is_flipped:
			offset = 0
		else:
			offset = 1
		
		#gestion du positionnement en cascade des cartes dans l'action zone
		if (action_zone_copy.size() % 2 == 0) && (i % 2 == 0): #action zone pair et index de la carte pair --> lane 2
			action_zone_x_position = action_lane2_ZONE_X_POSITION
		elif (action_zone_copy.size() % 2 == 0) && !(i % 2 == 0): #action zone pair et index de la carte impair --> lane 1
			action_zone_x_position = action_lane1_ZONE_X_POSITION
		elif !(action_zone_copy.size() % 2 == 0) && (i % 2 == 0): #action zone impair et index de la carte pair --> lane 1
			action_zone_x_position = action_lane1_ZONE_X_POSITION
		else: #action zone impair et index de la carte impair --> lane 2
			action_zone_x_position = action_lane2_ZONE_X_POSITION

		var new_position = Vector2(action_zone_x_position, action_zone_y_position+offset)
		marker.position = new_position

		if element is MARKER:
			pass
		elif !element.is_flipped:
			action_zone_y_position += 71
		else:
			action_zone_y_position += 72

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
