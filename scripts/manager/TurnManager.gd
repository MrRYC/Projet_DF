extends Node

#constantes
const START_HAND_SIZE = 4 #main de départ maximum

#variables de référence vers un autre Node
@onready var card_manager_ref = $"../CardManager"
@onready var action_zone_ref = $"../ActionZone"
@onready var opponent_ref = $"../Opponent"
@onready var player_ref = $"../Player"

#variables du script
var new_hand_max_size = START_HAND_SIZE
var nb_turn = 0
var player_current_health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_ref.set_starting_health(card_manager_ref.deck_size())
	new_turn()

func _on_phase_button_pressed() -> void:
	await execute_action_phase()
	new_turn()

###########################################################################
#                             TURN MANAGEMENT                             #
###########################################################################

func update_max_hand_size():
	new_hand_max_size = START_HAND_SIZE #To be adapt based on skill cards effect

func new_turn():
	EventBus.new_turn.emit(new_hand_max_size)
	
	card_manager_ref.new_turn(new_hand_max_size)
	action_zone_ref.action_zone.clear()
	
	nb_turn += 1
	EventBus.turn_increased.emit(nb_turn)

###########################################################################
#                            BATTLE EXECUTION                             #
###########################################################################

# Tour tour des actions
#  o Le joueur joue ses actions chronologiquement
#  o Si  ennemi attaque en fonction du nombre de cartes restantes à jouer, insérer une indication dans la zone d'action pour indiquer sa séquence / permettre une défense ou un clash
#  o Sinon ennemi attaque en fin de tour

func execute_action_phase():
	EventBus.combat_in_progress.emit(false)
	
	var action_zone_copy = action_zone_ref.action_zone.duplicate()
	action_zone_copy.reverse()
	for card in range(action_zone_copy.size()):
		var last_action = false
		if card == action_zone_copy.size()-1:
			last_action = true
			
		await wait_before_action(action_zone_copy[card], action_zone_copy[card].animation_time)
		apply_player_actions(action_zone_copy[card], action_zone_copy[card].target, last_action)

	EventBus.combat_in_progress.emit(true)

func apply_player_actions(card, _target, last_action): #target à définir
	if card.is_flipped:
		var flip_effect_txt = check_flip_effect(card)
		print(flip_effect_txt)
		return

	var attack = int(card.get_node("Attack").text) # ou card.attack si tu veux le stocker
	opponent_ref.take_damage(attack,last_action)
	
func check_flip_effect(card):
		
	#application de l'effet sur le joueur
	if card.slot_flip_effect["uses"] == null:
		pass
	elif card.slot_flip_effect["uses"] == 0:
		return
	else :
		print("card.slot_flip_effect[uses] -= 1")

	var slot_effect = card.slot_flip_effect["effect"]
	var player_effect_txt : String
	
	if slot_effect == "add_block":
		player_effect_txt = "+1 block appliqué"
	elif slot_effect == "add_dodge":
		player_effect_txt = "+1 esquive appliquée"
	elif slot_effect == "add_breath":
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
