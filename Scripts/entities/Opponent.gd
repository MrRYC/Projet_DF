extends Node2D
class_name OPPONENT

var data: OPPONENT_DATA
var current_hp : int
var extra_damage : int = 0
var cards_played_counter: int = 0

func init_from_data(d: OPPONENT_DATA):
	data = d
	current_hp = d.max_hp
	$Sprite2D.texture = d.sprite
	update_health()

func take_damage(amount):
	current_hp -= amount

	if current_hp < 0:
		current_hp = 0
		extra_damage += amount
		#animation étourdi

	update_health()
	
	return extra_damage

func update_health():
	$HealthLabel.text = str(current_hp)

func on_player_card_played(opponent):
	cards_played_counter += 1
	
	if cards_played_counter == opponent.data.attack_threshold:
		#Animation de l'ennemi prêt
		pass
	elif cards_played_counter < opponent.data.attack_threshold:
		#Animation idle
		return

func perform_action(opponent):
	var action : int = randi_range(0, 3)
	opponent.data.init_action_list()
	var opponent_action = opponent.data.list_of_actions[action]
	if opponent_action == 1:
		EventBus.ai_attack_performed.emit(opponent.data.damage)
		print(str(opponent.data.display_name)+" "+str(opponent.data.action_type.keys()[opponent_action])+" : "+str(opponent.data.damage))
	else:
		apply_effect(opponent.data.action_type.keys()[opponent_action])
		print(str(opponent.data.display_name)+" "+str(opponent.data.action_type.keys()[opponent_action]))

func apply_effect(action):
	print(action)
	print(OPPONENT_DATA.action_type.keys())
	#match opponent.data.list_of_actions.keys():
		#2:
		#3:
		#4:
		#5:

func death_check(overkill_limit):
	if extra_damage >= overkill_limit :
		overkill_animation()
		return true
	elif current_hp == 0 :
		die()
		return true
	else:
		return false

func overkill_animation():
	print("animation overkill")
	die()

func die():
	queue_free() # ou animation de mort
