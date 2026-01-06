extends Node2D
class_name PLAYER

var max_health : int = 0
var current_health : int = 0
var block : int = 0
var dodge : int = 0

func _ready() -> void:
	EventBus.new_turn.connect(_on_new_turn)
	EventBus.dim_player.connect(_on_dimmed_player)
	EventBus.undim_player.connect(_on_undimmed_player)
	EventBus.card_removed_from_action_zone.connect(_on_card_removed_from_action_zone)
	EventBus.player_incoming_damage_updated.connect(_on_incoming_damage)
	
###########################################################################
#                             HEALTH MANAGEMENT                           #
###########################################################################

func set_starting_health(health):
	max_health = health
	current_health = health
	update_health()

func take_damage(amount):
	
	if self.dodge != 0:
		evasive_action()
	elif self.block != 0:
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

func evasive_action():
	self.dodge -= 1
	
	if self.dodge == 0:
		#Animation block lost
		pass

func check_evasive_action():
	if self.dodge != 0:
		evasive_action()
	else:
		EventBus.drop_combo_cards.emit()

func update_health():
	$HealthPips.set_health(current_health, max_health)

func set_incoming_damage_preview(dmg):
	$HealthPips.set_preview_damage(dmg)
	$HealthPips.set_preview_block(self.block)

func clear_incoming_damage_preview():
	$HealthPips.set_preview_damage(0)
	$HealthPips.set_preview_block(0)

func update_block() -> void:
	$HealthPips.set_block_charges(self.block)

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
	self.block = 0
	self.dodge = 0
	update_block()
	
func _on_dimmed_player():
	$Image.modulate = Color(0.275, 0.803, 0.496, 1.0)

func _on_undimmed_player():
	$Image.modulate = Color(1.0, 1.0, 1.0)

func _on_card_removed_from_action_zone(_removed):
	_on_undimmed_player()

func _on_incoming_damage(amount):
	$HealthPips.set_preview_damage(amount)
