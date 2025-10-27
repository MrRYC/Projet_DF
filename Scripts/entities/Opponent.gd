extends Node2D
class_name Opponent

var max_health : int = 6
var current_health : int = max_health

func _ready():
	update_health()

func take_damage(amount,is_last_action):
	#var overkill = false
	current_health -= amount

	if current_health < 0:
		current_health = 0
		#overkill = true

	update_health()
	
	if current_health <= 0 && is_last_action:
		die()
	
	#overkill = false

func update_health():
	$HealthLabel.text = str(current_health)

func die():
	queue_free() # ou animation de mort
	get_tree().quit() #quit the game
