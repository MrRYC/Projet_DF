extends Node

#constantes
signal remove_card(bool)

const ACTION_LANE1_ZONE_X_POSITION = 125
const ACTION_LANE2_ZONE_X_POSITION = 235
const ACTION_LANE_ZONE_Y_OFFSET = 71
const ACTION_ZONE_TOP_Y_POSITION = 150
const FLIPPED_CARD_Y_OFFSET = 1
const ACTION_ZONE_DROP_TOLERANCE_X : int = 90 #marge horizontale de dépôt autour des lanes pour le réordonnancement
const ACTION_ZONE_DROP_TOLERANCE_Y : int = 60 #marge verticale de dépôt autour de la grille pour le réordonnancement
const MARKER_SCENE = preload("res://scenes/IntentMarker.tscn")

#variables de référence
@onready var card_manager_ref = $"../CardManager"

#variables du script
var action_zone : Array = []
var player_markers : Array = []
var opponent_markers : Array = []
var end_turn_opponent : Array = []
var card_removed : bool = false
var processing : bool
var solo_attacker : bool = false
var card_layout_tweens : Dictionary = {} #animation d'agencement active par carte (une seule animation de position par carte)


func _ready() -> void:
	EventBus.card_removed_from_action_zone.connect(_on_card_removed_from_action_zone)
	EventBus.action_zone_button_pressed.connect(_on_action_zone_button_pressed)

###########################################################################
#                          ACTION ZONE MANAGEMENT                         #
###########################################################################

func add_card_to_action_zone(card) -> void:
	if card not in action_zone:
		action_zone.insert(0,card)
		card.current_area = card.board_area.IN_ACTION_ZONE
		card.cancel_incoming_hit_preview()
		card_manager_ref.update_card_size(card)
		update_action_zone_positions()
		
		if card.is_flipped:
			EventBus.player_defensive_actions_preview.emit(card["effect_per_slot"][0]["id"], card["effect_per_slot"][0]["value"])

		update_opponent_defensive_actions()

func return_card_to_hand(card) -> void:
	var action_zone_copy = action_zone.duplicate()
	var index = action_zone.find(card)
	
	for i in range(0,index+1):
		var c = action_zone_copy[i]
		c.target = null
		if c.is_flipped:
			EventBus.player_defensive_actions_removed.emit(c["effect_per_slot"][0]["id"], c["effect_per_slot"][0]["value"])
			card_manager_ref.flip_card_in_hand(c)
		card_manager_ref.return_card_to_hand(c)
		remove_card_from_action_zone(c)
	
	#Mise à jours des pips défensif des ennemis
	update_opponent_defensive_actions()

	#Mise à jour des marqueurs d'intention
	if opponent_markers == null:
		return
	
	#Remise à zero des marqueurs de tour des ennemis
	reset_end_turn_opponent_action_turn()

	#Repositionnement des marqueurs d'intentions
	EventBus.card_removed_from_action_zone.emit(true)
	update_player_markers()
	update_opponent_markers()
	EventBus.card_removed_from_action_zone.emit(false)

func remove_card_from_action_zone(card) -> void:
	action_zone.erase(card)
	stop_card_layout_animation(card)

func empty_action_zone() -> void:
	var action_zone_copy = action_zone.duplicate()
	for card in action_zone_copy:
		if card.is_flipped:
			EventBus.player_defensive_actions_removed.emit(card["effect_per_slot"][0]["id"], card["effect_per_slot"][0]["value"])
			card_manager_ref.flip_card_in_hand(card)
		card_manager_ref.return_card_to_hand(card)

	#Mise à jours des pips défensif des ennemis
	update_opponent_defensive_actions()
	EventBus.card_removed_from_action_zone.emit(true)
	action_zone.clear()
	stop_all_card_layout_animations()

func update_opponent_defensive_actions() -> void:
	EventBus.opponent_incoming_damage_updated.emit()

###########################################################################
#                          SEQUENCE REORDERING                            #
###########################################################################

#Détermination de l'index d'insertion d'une carte relachée dans l'action zone
func get_drop_index(drop_position : Vector2, dragged_card) -> int:
	#La crte relachée doit rester dans l'espace horizontale des deux colonnes de l'action zone
	if drop_position.x < ACTION_LANE1_ZONE_X_POSITION - ACTION_ZONE_DROP_TOLERANCE_X:
		return -1
	if drop_position.x > ACTION_LANE2_ZONE_X_POSITION + ACTION_ZONE_DROP_TOLERANCE_X:
		return -1
	
	var total_size : int = action_zone.size()
	
	#Délimitation de la borne verticale basse : une rangée sous la carte la plus basse (hors carte déplacée)
	var bottom_position : float = ACTION_ZONE_TOP_Y_POSITION
	for card in action_zone:
		if card == dragged_card:
			continue
		bottom_position = maxf(bottom_position, card.starting_position.y)
	
	if drop_position.y < ACTION_ZONE_TOP_Y_POSITION - ACTION_ZONE_DROP_TOLERANCE_Y:
		return -1
	if drop_position.y > bottom_position + ACTION_LANE_ZONE_Y_OFFSET + ACTION_ZONE_DROP_TOLERANCE_Y:
		return -1
	
	#Position chronologique cible : avant la première carte (ordre d'exécution)
	var execution_position : int = total_size - 1
	var remaining_count : int = 0
	
	#Lecture du tableau en sens inverse (ordre chronologique d'exécution)
	for i in range(total_size-1, -1, -1):
		var card = action_zone[i]
		if card == dragged_card:
			continue
		remaining_count += 1
		
		if drop_position.y < card.starting_position.y:
			execution_position = remaining_count - 1
			break

	return total_size - 1 - execution_position

#Réordonnacement des cartes dane l'action_zone
func move_card_to_index(card, new_index : int) -> void:
	var old_index : int = action_zone.find(card)
	
	if old_index == -1 or new_index < 0 or new_index == old_index:
		update_action_zone_positions()
		return
	
	action_zone.erase(card)
	action_zone.insert(clampi(new_index, 0, action_zone.size()), card)
	update_action_zone_positions()
	
	#Actualisation des marqueurs de préviews des dégâts
	update_opponent_defensive_actions()

###########################################################################
#                              CARDS POSITION                             #
###########################################################################

#Calcule déterministe des positions des cartes de l'action zone sont à partir de l'ordre actuel du tableau
func update_action_zone_positions() -> void:
	var card_positions := calculate_action_zone_positions()
	
	for card_position in card_positions:
		card_position[0].starting_position = card_position[1]
	
	#animation de la carte après que la précédente se termine
	var last_tween = animate_cards_to_positions(card_positions)
	
	update_player_markers()
	
	if last_tween:
		last_tween.finished.connect(update_opponent_markers)
	else:
		update_opponent_markers()

#Renvoi des paires [carte, position] dans l'ordre de séquencement des actions, de la plus ancienne à la plus récente
func calculate_action_zone_positions() -> Array:
	var card_positions : Array = []
	var y_position : int = ACTION_ZONE_TOP_Y_POSITION
	
	#Lecture du tableau en démarrabt par la carte la plus ancienne
	for i in range(action_zone.size()-1, -1, -1):
		var card = action_zone[i]
		var flipped_offset : int = 0
		
		if card.is_flipped:
			flipped_offset = FLIPPED_CARD_Y_OFFSET
		
		card_positions.append([card, Vector2(get_action_zone_lane_x_position(i), y_position + flipped_offset)])
		
		#Décalage de la carte si elle est jouée retournée depuis la main
		if card.is_flipped:
			y_position += ACTION_LANE_ZONE_Y_OFFSET + FLIPPED_CARD_Y_OFFSET
		else:
			y_position += ACTION_LANE_ZONE_Y_OFFSET
	
	return card_positions

#Gestion de la position en quinquence des cartes dans l'action zone
func get_action_zone_lane_x_position(card_index : int) -> int:
	if card_index % 2 == action_zone.size() % 2:
		return ACTION_LANE2_ZONE_X_POSITION
	
	return ACTION_LANE1_ZONE_X_POSITION

#Animation de la carte vers sa position cible dans l'action zone
func animate_cards_to_positions(card_positions : Array) -> Tween:
	stop_all_card_layout_animations()
	
	var last_tween : Tween = null
	
	for i in range(card_positions.size()):
		var card = card_positions[i][0]
		var new_position : Vector2 = card_positions[i][1]
		
		#on ignore la carte, si elle a été retirée de l'action zone 
		if card not in action_zone:
			continue
		
		var tween = get_tree().create_tween()
		var step = tween.tween_property(card, "position", new_position, Global.ACTION_ZONE_DRAW_INTERVAL)
		step.set_delay(i * Global.ACTION_ZONE_DRAW_INTERVAL)
		card_layout_tweens[card] = tween
		last_tween = tween
	
	return last_tween

#Arrêt de l'animation de la carte
func stop_card_layout_animation(card) -> void:
	if card_layout_tweens.has(card):
		var tween = card_layout_tweens[card]
		if tween and tween.is_valid():
			tween.kill()
		card_layout_tweens.erase(card)

#Arrêt de toutes les animations des cartes
func stop_all_card_layout_animations() -> void:
	for card in card_layout_tweens.keys():
		var tween = card_layout_tweens[card]
		if tween and tween.is_valid():
			tween.kill()
	card_layout_tweens.clear()

###########################################################################
#                          PLAYER INTENT MARKER                           #
###########################################################################

func save_player_marker(card) -> void:
	var m: MARKER = MARKER_SCENE.instantiate()
	m.opponent = card.target
	m.position = card.starting_position
	m.toggle_player_border()
	add_child(m)
	player_markers.append(m)

func update_player_markers() -> void:
	clear_all_player_markers()
	for card in action_zone:
		save_player_marker(card)

func clear_all_player_markers() -> void:
	for m in player_markers:
		if is_instance_valid(m):
			m.queue_free()
	player_markers.clear()

###########################################################################
#                        OPPONENTS INTENT MARKER                          #
###########################################################################

func save_opponent_markers(incoming_attack) -> void:

	if incoming_attack.size() == 1:
		solo_attacker = true
	else:
		solo_attacker = false

	for o in incoming_attack:
		var m: MARKER = MARKER_SCENE.instantiate()
		m.toggle_opponent_border()
		m.opponent = o
		m.array_position = o.data.attack_threshold #Sauvegarde de l'Attack Threshold de l'opponent
		m.set_color()
		add_child(m)
		threshold_opponent_marker_ordering(m)

#Affichage du marqueur d'intention
func threshold_opponent_marker_ordering(marker) -> void:
	#Placement des ennemis qui attaquent à la fin (attack_threshold == 0) en dernier
	if marker.array_position == 0:
		if solo_attacker:
			opponent_markers.append(marker)
			marker.opponent.attack_order = 1
			marker.opponent.update_attack_order()
		else:
			end_turn_opponent.append(marker)
		return

	#Gestion des ennemis avec une attack_threshold
	var desired_index = marker.array_position-1

	if opponent_markers.size() <= desired_index:
		opponent_markers.resize(desired_index + 1)

	if opponent_markers[desired_index] == null:
		opponent_markers[desired_index] = marker
		marker.array_position = desired_index
		marker.opponent.attack_order = marker.opponent.data.attack_threshold
	else:
		#Gestion des ennemis avec le même attack_threshold
		shift_right_from(desired_index + 1)
		opponent_markers[desired_index + 1] = marker
		marker.array_position = desired_index + 1
		marker.opponent.attack_order = marker.opponent.data.attack_threshold + 1
	
	marker.opponent.update_attack_order()

# Décalage de tous les éléments vers la droite à partir d'un index donné
func shift_right_from(start_index: int) -> void:

	if start_index < 0:
		start_index = 0
	if start_index > opponent_markers.size():
		start_index = opponent_markers.size()
		
	#Augmentation de la taille de l'array d'une case pour permettre le shift
	opponent_markers.insert(start_index, null)

	# Mise à jour de l'array_position pour les markers valides
	for i in range(start_index, opponent_markers.size()):
		if opponent_markers[i] != null:
			opponent_markers[i].array_position = i

func init_markers_position() -> void:
	var marker_x_position = ACTION_LANE1_ZONE_X_POSITION
	var marker_y_position = 150
	var lane1 = true

	#Positionnement initial des marqueurs d'intention
	for i in range(opponent_markers.size()):
		var m = opponent_markers[i]
		#if m == null:
			#continue # protège contre les trous dans l'array

		if lane1 :
			marker_x_position = ACTION_LANE1_ZONE_X_POSITION
			lane1 = false
		elif !lane1:
			marker_x_position = ACTION_LANE2_ZONE_X_POSITION
			lane1 = true

		m.position = Vector2(marker_x_position, marker_y_position)
		marker_y_position += ACTION_LANE_ZONE_Y_OFFSET

func update_opponent_markers() -> void:
	if opponent_markers == null:
		return

	var card_position : Array[Vector2] = []
	for card in action_zone:
		card_position.append(card.starting_position)

	if card_position.size() == 0:
		init_markers_position()
	else:
		update_markers_position(card_position)

	update_opponent_action_turn()

func update_markers_position(card_position) -> void:
	var marker_x_position : float = 0
	var marker_y_position : float = 0
	var next_position = null
	var marker_offset : int = 0
	var end_turn_opponent_number = count_end_turn_opponent()
	var last_end_turn_opponent_turn_order : int = 0

	#Repositionnement des marqueurs d'intention 
	for i in range(opponent_markers.size()):
		var turn_order :int = opponent_markers[i].opponent.attack_order
		var target_index = card_position.size()-1
	
		#Gestion de la position du marqueur pour les opponent qui ont un atack_threshold
		if target_index < turn_order && opponent_markers[i].opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THRESHOLD:
			if next_position == null:
				marker_x_position = card_position[0].x
				marker_y_position = card_position[0].y
			else:
				marker_x_position = next_position.x
				marker_y_position = next_position.y

			opponent_markers[i].position = Vector2(marker_x_position,marker_y_position)
			next_position = next_marker_position(marker_x_position, marker_y_position)

		#Gestion de la position du marqueur pour les opponent qui attaquent à la fin du tour
		elif opponent_markers[i].opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THE_END:
			#Verification si le premier opponent a un attak_threshold
			if opponent_markers[0].opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THRESHOLD:
				#Récupération de numero de tour du dernier opponent avec un attak_threshold
				if last_end_turn_opponent_turn_order == 0:
					last_end_turn_opponent_turn_order = opponent_markers[i-1].opponent.attack_order

				#Decalage si le marqueur suit la position d'un marqueur d'un opponent avec un attack_threshold 
				if next_position != null:
					marker_x_position = next_position.x
					marker_y_position = next_position.y
				#Fixation des positions des marqeurs actuels tant que le nombre de carte en zone d'action <= au nombre de marqueurs d'intention
				elif action_zone.size() <= opponent_markers.size() :
					marker_x_position = next_position.x
					marker_y_position = next_position.y
				#Comparaison de la position du dernier opponent avec un attack_threshold à la taille de l'action zone
				elif action_zone.size() == last_end_turn_opponent_turn_order+1:
					if next_position == null:
						marker_x_position = card_position[0].x
						marker_y_position = card_position[0].y 
					else:
						marker_x_position = next_position.x
						marker_y_position = next_position.y
				#Gestion de la position des marqueurs quand l'action zone s'garandit
				else :
					var marker_index = end_turn_opponent_number - i
					if marker_index == end_turn_opponent_number :
						marker_offset = 1
					else:
						marker_offset += 1
					marker_x_position = action_zone[end_turn_opponent_number-marker_offset].position.x
					marker_y_position = action_zone[end_turn_opponent_number-marker_offset].position.y

			#Verification si le premier opponent a un attak_threshold
			elif opponent_markers[0].opponent.data.behavior_type != OPPONENT_DATA.behaviors.ATTACK_AT_THRESHOLD:
				#Gestion des positions des marqeurs en cas de retour d'une carte en main depuis l'action zone (clic gauche)
				if card_removed:
					if action_zone.size() <= opponent_markers.size():
						if next_position == null:
							marker_offset = action_zone.size()-1
							marker_x_position = action_zone[marker_offset].position.x
							marker_y_position = action_zone[marker_offset].position.y
						else:
							marker_x_position = next_position.x
							marker_y_position = next_position.y
					else:
						var marker_index = end_turn_opponent_number - i
						if marker_index == end_turn_opponent_number :
							marker_offset = 1
						else:
							marker_offset += 1
						marker_x_position = action_zone[end_turn_opponent_number-marker_offset].position.x
						marker_y_position = action_zone[end_turn_opponent_number-marker_offset].position.y
				#Fixation des positions des marqeurs actuels tant que le nombre de carte en zone d'action <= au nombre de marqueurs d'intention
				elif action_zone.size() <= opponent_markers.size() :
					marker_x_position = opponent_markers[i].position.x
					marker_y_position = opponent_markers[i].position.y
				#Gestion de la position des marqueurs quand l'action zone s'garandit
				else :
					var marker_index = end_turn_opponent_number - i
					if marker_index == end_turn_opponent_number :
						marker_offset = 1
					else:
						marker_offset += 1
					marker_x_position = action_zone[end_turn_opponent_number-marker_offset].position.x
					marker_y_position = action_zone[end_turn_opponent_number-marker_offset].position.y

			opponent_markers[i].position = Vector2(marker_x_position,marker_y_position)
			next_position = next_marker_position(marker_x_position, marker_y_position)


func next_marker_position(x_position, y_position):
	if x_position == ACTION_LANE1_ZONE_X_POSITION :
		x_position = ACTION_LANE2_ZONE_X_POSITION
	elif x_position == ACTION_LANE2_ZONE_X_POSITION:
		x_position = ACTION_LANE1_ZONE_X_POSITION
	y_position += ACTION_LANE_ZONE_Y_OFFSET
	
	return Vector2(x_position,y_position)

func remove_null_markers() -> void:
	var new_arr : Array = []
	for m in opponent_markers:
		if m != null:
			m.array_position = new_arr.size()
			new_arr.append(m)
	opponent_markers = new_arr
		
func clear_all_opponent_markers() -> void:
	#Effacement de l'array contenant la position des marqueurs ennemis
	for m in opponent_markers:
		if is_instance_valid(m):
			m.queue_free()
	opponent_markers.clear()
	
	#Effacement de l'array intermédiaire contenant la position des marqueurs ennemis avec un attack_threshold == 0 
	for m in end_turn_opponent:
		if is_instance_valid(m):
			m.queue_free()
	end_turn_opponent.clear()
	
	reset_end_turn_opponent_action_turn()

###########################################################################
#                         OPPONENTS ACTION TURN                           #
###########################################################################

func init_opponent_action_turn() -> void:
	if end_turn_opponent.size() == 0:
		return
	
	#Récupération du numero d'ordre d'attaque le plus haut
	var highest_attack_order : int = 0
	var offset : int = 1
	if opponent_markers != null:
		for marker in opponent_markers:
			highest_attack_order = check_attack_turn_order(marker)

	#Insertion du marqueur pour les opponent avec un attack_threshold == 0
	for marker in end_turn_opponent:
		opponent_markers.append(marker)
		marker.opponent.attack_order = highest_attack_order + offset
		marker.opponent.update_attack_order()
		offset += 1

func update_opponent_action_turn() -> void:
	var highest_attack_order : int = 0
	
	#Récupération du numero d'ordre d'attaque le plus haut
	for marker in opponent_markers:
		if marker.opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THE_END:
			highest_attack_order = check_attack_turn_order(marker)

	if action_zone.size() > highest_attack_order:
		var diff = action_zone.size() - highest_attack_order
		for marker in opponent_markers:
			if marker.opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THE_END:
				marker.opponent.attack_order +=diff
				marker.opponent.update_attack_order()

func check_attack_turn_order(m) -> int:
	var highest_attack_order : int = 0
	
	if highest_attack_order == 0:
		highest_attack_order = m.opponent.attack_order
	elif highest_attack_order < m.opponent.attack_order:
		highest_attack_order = m.opponent.attack_order
		
	return highest_attack_order

func count_end_turn_opponent() -> int:
	var end_turn_opponent_number : int = 0
	for marker in opponent_markers:
		if marker.opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THE_END:
			end_turn_opponent_number += 1
	
	return end_turn_opponent_number

func reset_end_turn_opponent_action_turn() -> void:
	for marker in opponent_markers:
		marker.opponent.attack_order = marker.opponent.attack_order_copy
		marker.opponent.attack_order_copy = 0
		marker.opponent.update_attack_order()

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_action_zone_button_pressed() -> void:
	if action_zone.size() > 0:
		empty_action_zone()
		clear_all_player_markers()

	if opponent_markers.size() > 0:
		init_markers_position()
		reset_end_turn_opponent_action_turn()

func _on_card_removed_from_action_zone(removed) -> void:
	if removed:
		card_removed = true
	else:
		card_removed = false
