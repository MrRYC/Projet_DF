extends Node2D
class_name PLAYER

#variables du script
@onready var defense_controller: DefenseController = $DefensiveActionsController
var max_health : int = 0
var current_health : int = 0

func _ready() -> void:
	EventBus.new_turn.connect(_on_new_turn)
	EventBus.dim_player.connect(_on_dimmed_player)
	EventBus.undim_player.connect(_on_undimmed_player)
	EventBus.card_removed_from_action_zone.connect(_on_card_removed_from_action_zone)
	EventBus.player_incoming_damage_updated.connect(_on_incoming_damage)

	defense_controller.block_changed.connect(_on_block_changed)
	defense_controller.dodge_activated.connect(_on_dodge_changed)

###########################################################################
#                             HEALTH MANAGEMENT                           #
###########################################################################

func set_starting_health(health)-> void:
	max_health = health
	current_health = health
	update_health()

func take_damage(amount)-> void:
	#if self.dodge != 0:
		#evasive_action()
	#elif self.block != 0:
		#defense_controller()
	#else:
		#current_health -= amount
		#EventBus.combo_meter_cancelled.emit()

	if defense_controller.try_block_hit():
		check_block()
		return

	current_health -= amount
	EventBus.combo_meter_cancelled.emit()

	if current_health < 0:
		current_health = 0

	update_health()

	if current_health <= 0:
		die()

func check_block()-> void:
	if defense_controller.get_block() == 0:
		# Animation de perte du blocage
		pass

func check_evasion()-> void:
	if defense_controller.get_dodge():
		return
	else:
		EventBus.drop_combo_cards.emit()

###########################################################################
#                              PIPS MANAGEMENT                            #
###########################################################################

func update_health()-> void:
	$HealthPips.set_health(current_health, max_health)

func update_player_pips_block() -> void:
	$HealthPips.set_block_charges(defense_controller.get_block())

###########################################################################
#                           DEATH MANAGEMENT                              #
###########################################################################

func die()-> void:
	queue_free() # ou animation de mort
	get_tree().quit() #quit the game

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_new_turn(_new_hand_size, _is_first_turn)-> void:
	defense_controller.reset_for_new_turn()
	update_player_pips_block()
	
func _on_dimmed_player()-> void:
	$Image.modulate = Color(0.275, 0.803, 0.496, 1.0)

func _on_undimmed_player()-> void:
	$Image.modulate = Color(1.0, 1.0, 1.0)

func _on_card_removed_from_action_zone(_removed)-> void:
	_on_undimmed_player()

func _on_incoming_damage(amount)-> void:
	$HealthPips.set_preview_damage(amount)

func _on_block_changed(_value) -> void:
	defense_controller.get_block()
	update_player_pips_block()
	
func _on_dodge_changed(_status) -> void:
	defense_controller.get_dodge()
