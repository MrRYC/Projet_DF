extends Node

@export var opponent_scene: PackedScene = preload("res://scenes/Opponent.tscn")
@onready var action_zone: Node = $"../ActionZone"

var match_up: Array = [] # instances Opponent en jeu
var incoming_attack: Array = [] # liste des opponent qui attaquent ce tour
var current_hovered_opponent : Node = null
var dimmed_opponents := [] # array of opponents currently dimmed

func _ready():
	EventBus.new_turn.connect(_on_new_turn)
	EventBus.opponent_marker_hovered.connect(_on_opponent_marker_hovered)
	EventBus.opponent_marker_hovered_off.connect(_on_opponent_marker_hovered_off)
	EventBus.player_marker_hovered.connect(_on_player_marker_hovered)
	EventBus.player_marker_hovered_off.connect(_on_player_marker_hovered_off)
	EventBus.card_removed_from_action_zone.connect(_on_card_removed_from_action_zone)
	EventBus.opponent_incoming_damage_updated.connect(_on_incoming_damage)
	
	spawn_random_opponent_set(0,5)

###########################################################################
#                           OPPONENT CREATION                             #
###########################################################################

func spawn_random_opponent_set(min_count:int, max_count:int):
	var random = randi_range(min_count, max_count)
	var selected_set = OPPONENTS_SETS.SETS.keys()[random]
	var opponents : Dictionary = OPPONENTS_SETS.SETS[selected_set]
	
	for o in opponents.opponents_per_set:
		var opponent_data: OPPONENT_DATA = load(opponents.opponents_per_set[o])
		var opponent_node = opponent_scene.instantiate()
		opponent_node.init_from_data(opponent_data)
		add_child(opponent_node)
		match_up.append(opponent_node)

		place_opponent(opponents.opponents_per_set.size(), o, opponent_node)

func place_opponent(number, index, opponent_node):
	var random = 605
	
	if index % 2 == 0:
		random = randi_range(590, 630)
	else:
		random = randi_range(550, 590)

	match number:
		1 : opponent_node.global_position = Vector2(1300, 605)
		2 : opponent_node.global_position = Vector2(900 + index*200, random)
		3 : opponent_node.global_position = Vector2(800 + index*200, random)

###########################################################################
#                             ACTIONS MANAGEMENT                          #
###########################################################################

func threshold_actions(opponent):
	if !opponent.action_performed:
		opponent.perform_action()

func end_of_turn_actions():
	for opponent in match_up:
		if !opponent.action_performed:
			opponent.perform_action()

func notify_card_played():
	for opponent in match_up:
		if opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THRESHOLD:
			opponent.on_player_card_played()

###########################################################################
#                       OPPONENT IMAGE MANAGEMENT                         #
###########################################################################

# applique l'effet d'estompe sur les opponent à l'exception de celui concerné par l'attaque
func dim_all_except(except_opponent, marker_type):
	undim_all()
	for opponent in match_up:
		if not is_instance_valid(opponent):
			continue
		
		if opponent == except_opponent:
			if marker_type == "opponent":
				opponent.apply_attacker_color()
				continue
			elif marker_type == "player":
				opponent.apply_player_target_color()
				continue
			
		opponent.apply_dim()

func undim_all():
	for opponent in match_up:
		if is_instance_valid(opponent):
			opponent.remove_dim()

###########################################################################
#                           DEATH MANAGEMENT                              #
###########################################################################

func opponent_death():
	var match_up_duplicate : Array = match_up.duplicate()
	for opponent in match_up_duplicate:
		if opponent.is_dead:
			opponent.death_check()
			match_up.erase(opponent)
		
		if match_up.size() == 0:
			EventBus.matchup_over.emit()

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_new_turn(_deck_size, _is_first_turn):
	action_zone.clear_all_player_markers()
	action_zone.clear_all_opponent_markers()
	incoming_attack.clear()
	var label_value : int = 0
	
	for opponent in match_up:
		#Reinitialisation des données du tour précédent
		opponent.extra_damage = 0
		opponent.cards_played_counter = 0
		opponent.action_performed = false
		opponent.block = 0
		
		#Génération de l'action du tour
		opponent.data.init_action_list()
		var action_number : int = randi_range(0, 3)
		opponent.action_type = opponent.data.list_of_actions[action_number]
		
		#Activation des effets défensifs
		if opponent.data.action_type.keys()[opponent.action_type] == "SIMPLE_BLOCK" || opponent.data.action_type.keys()[opponent.action_type] == "DOUBLE_BLOCK":
			opponent.set_defensive_action()
			label_value = opponent.block #Récupération de la valeur de défense pour le label des intentions

		#Récupération de la valeur d'attaque pour le label des intentions
		if opponent.data.action_type.keys()[opponent.action_type] == "ATTACK":
			label_value = opponent.data.damage
		
		#Mise à jour du label des intentions
		opponent.update_intent(label_value)

		#Activation du marqeur si l'opponent est de type action après x cartes et que son action est une action
		if opponent.data.action_type.keys()[opponent.action_type] == "ATTACK" : 
			incoming_attack.append(opponent)
	
	if incoming_attack.size()>0:
		action_zone.save_opponent_markers(incoming_attack)

	var total_incoming: int = 0
	for opp in incoming_attack:
		total_incoming += opp.data.damage
	EventBus.player_incoming_damage_updated.emit(total_incoming)
	
	#Initialisation des marqueurs d'intention des opponent
	action_zone.remove_null_markers()
	action_zone.init_opponent_action_turn()
	action_zone.init_markers_position()

func _on_empty_action_zone_button_pressed() -> void:
	for opponent in match_up:
		opponent.cards_played_counter = 0

func _on_opponent_marker_hovered(opponent):
	if current_hovered_opponent == opponent:
		return
		
	current_hovered_opponent = opponent
	dim_all_except(opponent,"opponent")

func _on_opponent_marker_hovered_off():
	undim_all()
	current_hovered_opponent = null

func _on_player_marker_hovered(target):
	if current_hovered_opponent == target:
		return
	elif target is PLAYER:
		EventBus.dim_player.emit()
		return
		
	current_hovered_opponent = target
	dim_all_except(target,"player")

func _on_player_marker_hovered_off():
	EventBus.undim_player.emit()
	undim_all()
	current_hovered_opponent = null

func _on_card_removed_from_action_zone(_removed):
	undim_all()

func _on_incoming_damage():
	#Reset des preview sur tous les opponents
	for opponent in match_up:
		if is_instance_valid(opponent):
			opponent.clear_pending_damage_preview()

	#Cumul les dégâts des cartes en action zone par opponent
	var dmg_by_opp: Dictionary = {} # key: OPPONENT, value: int

	for card in action_zone.action_zone:
		if card == null:
			continue
		if card.is_flipped:
			continue # flipped = slots/defense, pas une attaque
		if card.target == null:
			continue
		if card.target is OPPONENT:
			var o: OPPONENT = card.target
			var prev: int = 0
			if dmg_by_opp.has(o):
				prev = int(dmg_by_opp[o])
			dmg_by_opp[o] = prev + int(card.attack)

	#Affichage des previews sur les opponents
	for o in dmg_by_opp.keys():
		if is_instance_valid(o):
			o.set_pending_damage_preview(int(dmg_by_opp[o]))  # ou o.get_node("HealthPips").set_preview_damage(...)
