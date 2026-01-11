extends Node

#constantes
const START_HAND_SIZE = 6 #main de départ maximum

#variables de référence vers un autre Node
@onready var card_manager_ref : Node2D = $"../CardManager"
@onready var action_zone_ref : Node = $"../ActionZone"
@onready var player_ref : Node2D = $"../Player"
@onready var opponent_manager_ref : Node2D = $"../OpponentManager"

#variables du script
var new_hand_max_size = START_HAND_SIZE
var nb_turn : int = 1
var player_current_health
var is_player_attacked : bool = false
var damage_to_player : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.deck_loaded.connect(_on_deck_loaded)
	EventBus.card_played.connect(_on_card_played)
	EventBus.ai_attack_performed.connect(_on_ai_attack_performed)
	EventBus.ai_cancel_combo_performed.connect(_on_cancel_combo_performed)
	EventBus.matchup_over.connect(_on_matchup_over)

###########################################################################
#                             TURN MANAGEMENT                             #
###########################################################################

func update_max_hand_size()-> void:
	new_hand_max_size = START_HAND_SIZE #To be adapt based on skill cards effect

func new_turn()-> void:
	nb_turn += 1
	EventBus.turn_increased.emit(nb_turn)
	update_max_hand_size()
	EventBus.new_turn.emit(new_hand_max_size, false) #false étant donné que ce n'est pas le premier tour
	EventBus.opponent_incoming_damage_updated.emit()

###########################################################################
#                            BATTLE EXECUTION                             #
###########################################################################

func execute_action_phase()-> void:
	EventBus.processing.emit(true)
	var index : int = 0
	var action_zone_copy = action_zone_ref.action_zone.duplicate()
	action_zone_copy.reverse()
	for card in range(action_zone_copy.size()):
		index += 1
		await wait_before_action(action_zone_copy[card], action_zone_copy[card].animation_time)
		apply_player_actions(action_zone_copy[card], action_zone_copy[card].target)
		execute_ai_threshold_action(index)

	execute_opponent_death_effect()
	apply_ai_end_turn_actions()
	
	EventBus.processing.emit(false)

###########################################################################
#                              PLAYER ACTION                              #
###########################################################################

func apply_player_actions(card, target)-> void:
	if card.is_flipped:
		check_slots_effect(card)
	elif target != null:
		var damage: int = card.attack
		target.consume_damage_preview(damage)
		target.extra_damage = target.take_damage(damage)

func check_slots_effect(card)-> void:
	
	if !card.slot_number:
		return
	
	#application de l'effet sur le joueur
	for slot_effect in card.effect_per_slot:
		if card.effect_per_slot[slot_effect]["uses"] == null:
			apply_slots_effect(card.effect_per_slot[slot_effect])
		elif card.effect_per_slot[slot_effect]["uses"] == 0:
			continue
		else :
			apply_slots_effect(card.effect_per_slot[slot_effect])
			card.effect_per_slot[slot_effect]["uses"] -= 1

func apply_slots_effect(slot_effect: Dictionary) -> void:
	$SlotEffectManager.apply(slot_effect, player_ref)

func wait_before_action(card, time)-> void:
	#détermination de la vitesse de l'animation Fade In
	var fade_in_animation = card.get_node("CardFadeInAnimation")
	var speed
	
	if card.is_flipped:
		time = 0.1
		speed = 15
	else:
		if time == 1.5:
			speed = 1.4
		elif time == 1.2:
			speed = 1.7
		elif time == 1:
			speed = 2

	##lancement de l'animation de la carte lors de la pioche
	fade_in_animation.speed_scale = speed
	if !card.is_flipped:
		fade_in_animation.play("fade_to_black")
	else:
		fade_in_animation.play("fade_to_black_180")

	await get_tree().create_timer(time).timeout

###########################################################################
#                               AI ACTION                                 #
###########################################################################

func action_card_played()-> void:
	opponent_manager_ref.notify_card_played()

func execute_ai_threshold_action(index)-> void:
	opponent_manager_ref.threshold_actions(index)

func execute_opponent_death_effect()-> void:
	opponent_manager_ref.opponent_death()

func apply_ai_end_turn_actions()-> void:
	opponent_manager_ref.end_of_turn_actions()
	action_zone_ref.clear_all_opponent_markers()

func apply_player_damage(amount)-> void:
	player_ref.take_damage(amount)

func apply_cancel_combo()-> void:
	player_ref.check_evasion()

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_fight_button_pressed() -> void:
	await execute_action_phase()
	new_turn()
	
func _on_deck_loaded(deck_size)-> void:
	player_ref.set_starting_health(deck_size)
	EventBus.new_turn.emit(START_HAND_SIZE, true) #true étant donné que c'est le premier tour

func _on_ai_attack_performed(amount)-> void:
	apply_player_damage(amount)
	
func _on_cancel_combo_performed()-> void:
	apply_cancel_combo()

func _on_card_played()-> void:
	action_card_played()

func _on_matchup_over()-> void:
	print("Score final : ",Global.global_score)
	get_tree().quit() #quit the game
