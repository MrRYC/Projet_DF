extends Node2D

var max_health = 50
var current_health = 50

func take_damage(amount):
	current_health -= amount
	print("Ennemi prend", amount, "dégâts. HP restants :", current_health)
	if current_health <= 0:
		die()

func die():
	print("L’ennemi est vaincu !")
	queue_free() # ou animation de mort
