extends Node2D
class_name PLAYER

var current_health

func set_starting_health(health):
	current_health = health
	update_health()

func take_damage(amount,is_action_zone_empty):
	current_health -= amount
	if current_health < 0:
		current_health = 0

	update_health()
	
	if current_health <= 0 && is_action_zone_empty:
		die()

func update_health():
	$HealthLabel.text = str(current_health)

func die():
	queue_free() # ou animation de mort
	get_tree().quit() #quit the game
