extends Node2D
class_name PLAYER

var current_health : int = 0
var block : int = 0
var dodge : int = 0

func _ready() -> void:
	EventBus.new_turn.connect(_on_new_turn)

###########################################################################
#                             HEALTH MANAGEMENT                           #
###########################################################################

func set_starting_health(health):
	current_health = health
	update_health()

func take_damage(amount):
	
	if self.block != 0:
		defensive_action()
	else:
		current_health -= amount
		EventBus.combo_meter_cancelled.emit()

	if current_health < 0:
		current_health = 0

	update_health()

	if current_health <= 0:
		die()

func defensive_action():
	self.block -= 1
	
	if self.block == 0:
		#Animation block lost
		pass

func update_health():
	$HealthLabel.text = str(current_health)

###########################################################################
#                           DEATH MANAGEMENT                              #
###########################################################################

func die():
	queue_free() # ou animation de mort
	get_tree().quit() #quit the game

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_new_turn(_new_hand_size, _is_first_turn):
	block = 0
	dodge = 0
