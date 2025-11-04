extends Node2D
class_name OPPONENT

var data: OPPONENT_DATA
var current_hp : int
var extra_damage : int
var cards_played_counter: int = 0

func init_from_data(d: OPPONENT_DATA):
	data = d
	current_hp = d.max_hp
	$Sprite2D.texture = d.sprite
	update_health()

func take_damage(amount,is_last_action):
	current_hp -= amount

	if current_hp < 0:
		current_hp = 0
		extra_damage += amount
	update_health()
	
	if is_last_action :
		if extra_damage > 3 :
			overkill_animation()
		elif current_hp <= 0 :
			die()

func update_health():
	$HealthLabel.text = str(current_hp)

func on_player_card_played(opponent):
	if opponent.data.attack_performed:
		print("attaque déjà réalisée")
		return

	opponent.data.threshold_countdown += 1
	print("j'attaque dans "+ str(opponent.data.attack_threshold-opponent.data.threshold_countdown) +" tours")

	if opponent.data.threshold_countdown == opponent.data.attack_threshold:
		perform_action(opponent)
		opponent.data.threshold_countdown = 0
		opponent.data.attack_performed = true

func perform_action(opponent):
	var action : int = randi_range(0, 3)
	opponent.data.init_action_list()
	if opponent.data.list_of_actions[action] == 1:
		EventBus.ai_attack_performed.emit(opponent.data.damage)
		print(str(opponent.data.display_name)+" "+str(opponent.data.action_type.keys()[opponent.data.list_of_actions[action]])+" : "+str(opponent.data.damage))
	else:
		print(str(opponent.data.display_name)+" "+str(opponent.data.action_type.keys()[opponent.data.list_of_actions[action]]))

func overkill_animation():
	print("animation overkill")
	die()

func die():
	queue_free() # ou animation de mort
	get_tree().quit() #quit the game
