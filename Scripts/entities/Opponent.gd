extends Node2D
class_name OPPONENT

var data: ENEMYDATA
var current_hp : int
var extra_damage : int
var cards_played_counter: int = 0

func init_from_data(d: ENEMYDATA):
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

func on_player_card_played():
	if data.behavior_type == ENEMYDATA.behaviors.ATTACK_AT_THRESHOLD:
		cards_played_counter += 1
		if data.attack_performed:
			print("attaque déjà réalisée")
			pass

		if cards_played_counter == data.cards_threshold:
			perform_attack()
			data.attack_performed = true

func perform_attack():
	take_damage
	
func overkill_animation():
	print("animation overkill")
	die()

func die():
	queue_free() # ou animation de mort
	get_tree().quit() #quit the game
