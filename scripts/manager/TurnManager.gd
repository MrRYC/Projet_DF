extends Node

#constantes
const START_HAND_SIZE = 5 #main de départ maximum

#variables de référence vers un autre Node
@onready var card_manager_ref = $"../CardManager"
@onready var action_zone_ref = $"../ActionZone"
@onready var player_ref = $"../Player"
@onready var opponent_manager_ref = $"../OpponentManager"

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

func _on_phase_button_pressed() -> void:
	await execute_action_phase()
	new_turn()

###########################################################################
#                             TURN MANAGEMENT                             #
###########################################################################

func update_max_hand_size():
	new_hand_max_size = START_HAND_SIZE #To be adapt based on skill cards effect

func new_turn():
	nb_turn += 1
	EventBus.turn_increased.emit(nb_turn)
	update_max_hand_size()
	EventBus.new_turn.emit(new_hand_max_size, false) #false étant donné que ce n'est pas le premier tour

###########################################################################
#                            BATTLE EXECUTION                             #
###########################################################################

func execute_action_phase():
	EventBus.processing.emit(true)
	
	var action_zone_copy = action_zone_ref.action_zone.duplicate()
	action_zone_copy.reverse()
	for card in range(action_zone_copy.size()):
		await wait_before_action(action_zone_copy[card], action_zone_copy[card].animation_time)
		apply_player_actions(card, action_zone_copy[card], action_zone_copy[card].target)

	execute_opponent_death_effect()
	apply_ai_end_turn_actions()
	
	EventBus.processing.emit(false)

###########################################################################
#                              PLAYER ACTION                              #
###########################################################################

func apply_player_actions(index, card, target):
	if card.is_flipped:
		check_slots_effect(card)
	elif target != null:
		var attack = card.attack
		target.extra_damage = target.take_damage(attack)
		
	if target is OPPONENT:
		if target.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THRESHOLD and target.attack_order == index:
			apply_ai_threshold_actions(target)
	
func check_slots_effect(card):
	
	if !card.slot_number:
		return
	
	#application de l'effet sur le joueur
	for slot_effect in card.effect_per_slot:
		if card.effect_per_slot[slot_effect]["uses"] == null:
			print(apply_slots_effect(card.effect_per_slot[slot_effect]["id"]))
		elif card.effect_per_slot[slot_effect]["uses"] == 0:
			return
		else :
			print(apply_slots_effect(card.effect_per_slot[slot_effect]["id"]))
			card.effect_per_slot[slot_effect]["uses"] -= 1

func apply_slots_effect(slot_effect):
	var player_effect_txt : String

	if slot_effect == "Block":
		player_ref.block += 1
		player_effect_txt = "block appliqué +"+str(player_ref.block)
	elif slot_effect == "Dodge":
		player_ref.dodge += 1
		player_effect_txt = "esquive appliquée +"+str(player_ref.dodge)
	elif slot_effect == "Breath":
		player_effect_txt = "respiration activée"
	else:
		player_effect_txt = "Effet inconnu"

	return player_effect_txt

func wait_before_action(card, time):
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

func action_card_played():
	opponent_manager_ref.notify_card_played()

func apply_ai_threshold_actions(opponent):
	opponent_manager_ref.threshold_actions(opponent)

func execute_opponent_death_effect():
	opponent_manager_ref.opponent_death()

func apply_ai_end_turn_actions():
	opponent_manager_ref.end_of_turn_actions()
	action_zone_ref.clear_all_intents()

func apply_player_damage(amount):
	player_ref.take_damage(amount)

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_deck_loaded(deck_size):
	player_ref.set_starting_health(deck_size)
	EventBus.new_turn.emit(START_HAND_SIZE, true) #true étant donné que c'est le premier tour

func _on_ai_attack_performed(amount):
	apply_player_damage(amount)

func _on_card_played():
	action_card_played()
