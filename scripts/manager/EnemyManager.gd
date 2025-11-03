extends Node

@export var opponent_scene: PackedScene = preload("res://scenes/Opponent.tscn")
@export var possible_opponent: Array = []
@export var opponent_slots: Array[NodePath]       # les positions dans ta scène où tu poses les ennemis
"res://scripts/resources/opponents/girl_fighter.tres"

var opponent: Array = [] # instances Opponent en jeu

func _ready():
	load_possible_opponent("res://scripts/resources/opponents/")
	spawn_random_enemies(1, 3) # ex: entre 2 et 3 ennemis

func load_possible_opponent(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var enemy_res = load(path + file_name)
				if enemy_res:
					possible_opponent.append(enemy_res)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("Le dossier d'ennemis n'a pas pu être ouvert : " + path)

func spawn_random_enemies(min_count:int, max_count:int):
	var ennemi_number = randi_range(min_count, max_count)
	for i in range(ennemi_number):
		var data: ENEMYDATA = possible_opponent.pick_random()
		var opponent_instance = opponent_scene.instantiate()
		opponent_instance.init_from_data(data)
		add_child(opponent_instance)
		opponent.append(opponent_instance)

		# placer l’ennemi sur une "slot" visuelle dédiée
		if i < opponent_slots.size():
			var slot_node = get_node(opponent_slots[i])
			opponent_instance.global_position = slot_node.global_position
		else:
			# fallback si y a plus de slot définie
			opponent_instance.global_position = Vector2(200 + i*150, 200)

func end_of_turn_actions():
	for o in opponent:
		if o.data.behavior_type == ENEMYDATA.behaviors.ATTACK_AT_THE_END:
			o.perform_attack()

func notify_card_played():
	for o in opponent:
		o.on_player_card_played()
