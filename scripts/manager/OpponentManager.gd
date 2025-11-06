extends Node

@export var opponent_scene: PackedScene = preload("res://scenes/Opponent.tscn")
@onready var action_zone: Node2D = $"../ActionZone"

var match_up: Array = [] # instances Opponent en jeu

func _ready():
	EventBus.new_turn.connect(_on_new_turn)
	spawn_random_opponent_set(3, 3)

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

func end_of_turn_actions():
	for opponent in match_up:
		if !opponent.action_performed:
			opponent.perform_action()

func notify_card_played():
	for opponent in match_up:
		if opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THRESHOLD:
			opponent.on_player_card_played()

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

func _on_new_turn(_deck_size):
	action_zone.clear_all_intents()
	for opponent in match_up:
		#Effacement des données temporaires
		opponent.extra_damage = 0
		opponent.cards_played_counter = 0
		opponent.action_performed = false
		opponent.block = 0
		opponent.cancel_combo = false
		
		#Génération de l'action du tour
		opponent.data.init_action_list()
		var action_number : int = randi_range(0, 3)
		opponent.action = opponent.data.list_of_actions[action_number]
		print(opponent.data.action_type.keys()[opponent.action])
		opponent.set_defensive_action()
		opponent.update_intent()

		if opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THRESHOLD && opponent.data.action_type.keys()[opponent.action] == "ATTACK" : 
			action_zone.save_intent_markers(opponent)

func _on_empty_action_zone_button_pressed() -> void:
	for opponent in match_up:
		opponent.cards_played_counter = 0
