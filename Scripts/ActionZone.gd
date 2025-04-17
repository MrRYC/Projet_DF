extends Node2D

signal animation_finished(ended)

#constantes
const action_ZONE_X_POSITION = 125

#variables de référence
@onready var card_manager_ref = $"../CardManager"
@onready var discard_pile_ref = $"../DiscardPile"
@onready var opponent_ref = $"../Opponent"
@onready var player_hand_ref = $"../PlayerHand"

#variables du script
var action_zone = []

###########################################################################
#                          ACTION ZONE MANAGEMENT                         #
###########################################################################

func add_card_to_action_zone(card, speed):
	if card not in action_zone:
		#action_zone.insert(0,card)
		action_zone.append(card)
		card_manager_ref.update_card_size(card,false)
		update_action_zone_positions(speed)

func remove_card_from_action_zone(card):
	if card in action_zone:
		action_zone.erase(card)
		card_manager_ref.update_card_size(card,true)
		update_action_zone_positions(Global.DEFAULT_CARD_MOVE_SPEED)

func refresh_action_zone():
	var action_zone_copy = action_zone.duplicate()
	for card in action_zone_copy:
		player_hand_ref.add_card_to_hand(card, Global.DEFAULT_CARD_MOVE_SPEED)
		remove_card_from_action_zone(card)

###########################################################################
#                            ACTIONS EXECUTION                            #
###########################################################################

func execute_offensive_actions():
	var max_actions = action_zone.size()
	for  i in range(max_actions):
		var card = action_zone[i]
		var signal_status = send_animation_signal(max_actions,action_zone.size())
		await wait_before_action(card, card.animation_time,signal_status)
		apply_offensive_effect(card, card.target)
		
	action_zone.clear()

func execute_defensive_actions():
	if player_hand_ref.player_hand.size()>0:
		var hand_copy = player_hand_ref.player_hand.duplicate()
		
		#Trier les cartes par leur position X
		hand_copy.sort_custom(func(a, b): return a.position.x < b.position.x)
	
		for card in hand_copy:
			add_card_to_action_zone(card, Global.DEFAULT_CARD_MOVE_SPEED)
			player_hand_ref.remove_card_from_hand(card)

	if action_zone.size() > 0:
		var action_zone_copy = action_zone.duplicate()
		var max_actions = action_zone.size()
		for card in action_zone_copy:
			print("Défausse de :", card.card_name)
			var signal_status = send_animation_signal(max_actions,action_zone_copy.size())
			await wait_before_action(card, card.animation_time,signal_status)
			##apply_defensive_effect(card, card.target)
			
	action_zone.clear()

func apply_offensive_effect(card, opponent):
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

func send_animation_signal(max_actions, current_actions):
	if max_actions >= current_actions:
		return true
	else:
		return false

###########################################################################
#                              CARDS POSITION                             #
###########################################################################

func update_action_zone_positions(speed):
	var action_zone_y_position = 150
	for i in range(action_zone.size()-1, -1, -1): #-1, -1, -1 permet de lire le tableau en sens inverse
		var new_position = Vector2(action_ZONE_X_POSITION, action_zone_y_position)
		var card = action_zone[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position, speed)
		action_zone_y_position += 121

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

###########################################################################
#                             SIGNAL CONNEXION                            #
###########################################################################

func _on_refresh_action_zone_button_pressed():
	if action_zone.size() > 0:
		refresh_action_zone()	
