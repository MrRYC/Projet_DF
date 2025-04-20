extends Node2D

var max_health = 50
var current_health = max_health

func _ready():
	$OpponentHealthLabel.text = str(current_health, " / ", max_health)

func take_damage(amount,is_action_zone_empty):
	#var overkill = false
	current_health -= amount

	if current_health < 0:
		current_health = 0
		#overkill = true

	$OpponentHealthLabel.text = str(current_health, " / ", max_health)
	
	if current_health <= 0 && is_action_zone_empty:
		die()
	
	#overkill = false

func die():
	queue_free() # ou animation de mort
	get_tree().quit() #quit the game
