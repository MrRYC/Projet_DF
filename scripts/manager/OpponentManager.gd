extends Node

@export var opponent_scene: PackedScene = preload("res://scenes/Opponent.tscn")
@onready var action_zone: Node2D = $"../ActionZone"

var match_up: Array = [] # instances Opponent en jeu
var incoming_attack: Array = [] # liste des opponent qui attaquent ce tour
var current_hovered_opponent : Node = null
var dimmed_opponents := [] # array of opponents currently dimmed

func _ready():
	EventBus.new_turn.connect(_on_new_turn)
	EventBus.marker_hovered.connect(_on_marker_hovered)
	EventBus.marker_hovered_off.connect(_on_marker_hovered_off)
	
	spawn_random_opponent_set(2,2)

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
#                            DIMM MANAGEMENT                              #
###########################################################################

# applique le dim à tous sauf "except_opponent"
func dim_all_except(except_opponent):
	undim_all() # nettoyer d'abord pour éviter doublons
	for op in match_up:
		if not is_instance_valid(op):
			continue
		if op == except_opponent:
			continue
			
		op.apply_dim_to()
		dimmed_opponents.append(op)

func undim_all():
	for op in dimmed_opponents:
		if is_instance_valid(op):
			op.remove_dim_from()
	dimmed_opponents.clear()

###########################################################################
#                           DEATH MANAGEMENT                              #
###########################################################################

func opponent_death():
	var match_up_duplicate : Array = match_up.duplicate()
	for opponent in match_up_duplicate:
		var dead : bool = false
		dead = opponent.death_check()
		
		if dead:
			match_up.erase(opponent)
		
		if match_up.size() == 0:
			get_tree().quit() #quit the game

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_new_turn(_deck_size, _is_first_turn):
	action_zone.clear_all_intents()
	incoming_attack.clear()
	var label_value : int = 0
	
	for opponent in match_up:
		#Reinitialisation des données du tour précédent
		opponent.extra_damage = 0
		opponent.cards_played_counter = 0
		opponent.action_performed = false
		opponent.block = 0
		opponent.cancel_combo = false
		
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
		action_zone.save_intent_markers(incoming_attack)

	#Initialisation des marqueurs d'intention des opponent
	action_zone.remove_null_markers()
	action_zone.init_opponent_action_turn()
	action_zone.init_markers_position()

func _on_empty_action_zone_button_pressed() -> void:
	for opponent in match_up:
		opponent.cards_played_counter = 0

func _on_marker_hovered(opponent):
	if current_hovered_opponent == opponent:
		return
		
	current_hovered_opponent = opponent
	dim_all_except(opponent)

func _on_marker_hovered_off():
	#if current_hovered_opponent != opponent:
		#return
		
	undim_all()
	current_hovered_opponent = null
