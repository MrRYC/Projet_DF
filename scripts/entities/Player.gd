extends Node2D
class_name PLAYER

#variables du script
@onready var defense_controller: DefenseController = $DefensiveActionsController
var max_health : int = 0
var current_health : int = 0
var cards_in_hand : int = 0

func _ready() -> void:
	EventBus.new_turn.connect(_on_new_turn)
	EventBus.dim_player.connect(_on_dimmed_player)
	EventBus.undim_player.connect(_on_undimmed_player)
	EventBus.card_removed_from_action_zone.connect(_on_card_removed_from_action_zone)
	EventBus.cards_in_hand.connect(_on_player_hand_signal)

	defense_controller.block_changed.connect(_on_block_changed)
	defense_controller.dodge_changed.connect(_on_dodge_changed)
	defense_controller.feint_changed.connect(_on_feint_changed)

###########################################################################
#                             HEALTH MANAGEMENT                           #
###########################################################################

func set_starting_health(health)-> void:
	max_health = health
	current_health = health
	update_health()

func take_damage(amount)-> void:
	#check if player has defense
	if defense_controller.try_to_block():
		check_block()
		return
	
	#if no defense,check if player has a card in hand
	EventBus.get_cards_in_hand.emit()
	if cards_in_hand > 0:
		EventBus.fracture_a_random_card.emit()
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

func update_preview(amount)-> void:
	$HealthPips.set_preview_damage(amount)

func update_player_pips_block() -> void:
	$HealthPips.set_charges(defense_controller.get_block(),defense_controller.get_dodge(),defense_controller.get_feint())

func consume_damage_preview(damage: int) -> void:
	$HealthPips.consume_damage_preview(damage, defense_controller.has_block())

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
	update_player_pips_block()

func _on_block_changed(_value) -> void:
	defense_controller.get_block()
	update_player_pips_block()
	
func _on_dodge_changed(_value) -> void:
	defense_controller.get_dodge()
	update_player_pips_block()

func _on_feint_changed(_value) -> void:
	defense_controller.get_feint()
	update_player_pips_block()
	
func _on_player_hand_signal(value)->void:
	cards_in_hand = value
