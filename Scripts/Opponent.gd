extends Node2D

var max_health = 50
var current_health = max_health

func _ready():
	$OpponentHealthLabel.text = str(current_health, " / ", max_health)

func take_damage(amount):
	current_health -= amount
	$OpponentHealthLabel.text = str(current_health, " / ", max_health)
	if current_health <= 0:
		die()

func die():
	print("L’ennemi est vaincu !")
	queue_free() # ou animation de mort
