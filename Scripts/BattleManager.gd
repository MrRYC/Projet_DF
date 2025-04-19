extends Node

#signaux
signal attack_phase_signal
signal defense_phase_signal
signal animation_finished(ended)

#constantes
const START_HAND_SIZE = 4 #main de départ maximum

#variables de référence vers un autre Node
@onready var player_hand_ref = $"../PlayerHand"
@onready var deck_pile_ref = $"../DeckPile"
@onready var discard_pile_ref = $"../DiscardPile"
@onready var action_zone_ref = $"../ActionZone"
@onready var opponent_ref = $"../Opponent"
@onready var user_interface_ref = $"../UserInterface"

#variables du script
var is_attack_phase = true
var current_phase = "Attack Phase"
var new_hand_max_size = START_HAND_SIZE
var nb_turn = 1
var player_max_health
var player_current_health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_finished.connect(_on_animation_end)
	
	for i in range(START_HAND_SIZE):
		deck_pile_ref.draw_card()
	
	#Player Health equals to all the players cards (deck + hand + discard)
	count_player_card_in_game()
	player_max_health = player_current_health
	update_player_health(player_current_health,player_max_health)

func _on_phase_button_pressed() -> void:
	if is_attack_phase == true:
		if action_zone_ref.action_zone.size() > 0:
			user_interface_ref.animation_in_progress(true)
		execute_offensive_actions()
		defensive_phase()
	else:
		user_interface_ref.animation_in_progress(true)
		await execute_defensive_actions()
		new_turn()

	user_interface_ref.update_refresh_button(is_attack_phase)

###########################################################################
#                             TURN MANAGEMENT                             #
###########################################################################

func update_max_hand_size():
	new_hand_max_size = START_HAND_SIZE #To be adapt based on skill cards effect
	return new_hand_max_size

func new_turn():
	attack_phase()
	deck_pile_ref.new_turn(update_max_hand_size())
	nb_turn += 1
	user_interface_ref.turn_update(nb_turn)

###########################################################################
#                            PLAYER MANAGEMENT                            #
###########################################################################

func count_player_card_in_game():
	player_current_health = deck_pile_ref.player_deck.size() + player_hand_ref.player_hand.size() + discard_pile_ref.player_discard.size()
	
func update_player_health(current_health,max_health):
	user_interface_ref.player_health_update(current_health,max_health)

###########################################################################
#                            PHASES MANAGEMENT                            #
###########################################################################

func attack_phase():
	current_phase = "Attack Phase"
	user_interface_ref.update_phase_button(current_phase)
	is_attack_phase = true
	emit_signal("attack_phase_signal")

func defensive_phase():
	current_phase = "Defensive Phase"
	user_interface_ref.update_phase_button(current_phase)
	is_attack_phase = false
	emit_signal("defense_phase_signal")
	#defense_phase_signal.emit(current_phase, nb_turn)

###########################################################################
#                            BATTLE EXECUTION                             #
###########################################################################

func execute_offensive_actions():
	var action_zone_copy = action_zone_ref.action_zone.duplicate()
	action_zone_copy.reverse()
	for i in range(action_zone_copy.size()):
		var signal_status = send_animation_signal(i,action_zone_copy.size())
		await wait_before_action(action_zone_copy[i], action_zone_copy[i].animation_time,signal_status)
		apply_offensive_effect(action_zone_copy[i], action_zone_copy[i].target)
		
	action_zone_ref.action_zone.clear()

func execute_defensive_actions():
	if player_hand_ref.player_hand.size()>0:
		var hand_copy = player_hand_ref.player_hand.duplicate()		
		for card in hand_copy:
			action_zone_ref.add_card_to_action_zone(card, Global.DEFAULT_CARD_MOVE_SPEED)
			player_hand_ref.remove_card_from_hand(card)

	if action_zone_ref.action_zone.size() > 0:
		var action_zone_copy = action_zone_ref.action_zone.duplicate()
		action_zone_copy.reverse()
		for i in range(action_zone_copy.size()):
			var signal_status = send_animation_signal(i,action_zone_copy.size())
			await wait_before_action(action_zone_copy[i], action_zone_copy[i].animation_time,signal_status)
			##apply_defensive_effect(card, card.target)
			
	action_zone_ref.action_zone.clear()

func apply_offensive_effect(card, target): #target à définir
	var attack = int(card.get_node("Attack").text) # ou card.attack si tu veux le stocker
	opponent_ref.take_damage(attack)
	
func apply_defensive_effect(card, target):
	var type = card.effects["type"]
	var value = card.effects["value"]
	#var endurance_cost = card.effects["endurance_cost"]
	
	for effect in card.effects:
		match type:
			"damage":
				target.take_damage(value)
			"buff":
				# Appliquer un buff au joueur
				pass
				#player.apply_buff(value)
			"debuff":
				target.apply_debuff(value)
			"regen":
				pass
				#player.restore_endurance(value)
		
		# Gérer l'endurance après l'effet
		#player.reduce_endurance(effect.endurance_cost)

func wait_before_action(card, time, signal_status):
	await get_tree().create_timer(time).timeout
	discard_pile_ref.add_card_to_discard(card)
	
	if signal_status:
		animation_finished.emit(true)
	else:
		animation_finished.emit(false)

func send_animation_signal(current_actions, max_actions):
	if max_actions - 1 == current_actions:
		return true
	else:
		return false

###########################################################################
#                             SIGNAL CONNEXION                            #
###########################################################################

func _on_animation_end(ended):
	if ended:
		user_interface_ref.animation_in_progress(false)
