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
var is_action_zone_empty = false
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
	return new_hand_max_size

func new_turn():
	card_manager_ref.new_turn(update_max_hand_size())
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

	for i in range(action_zone_copy.size()):
		if i == action_zone_copy.size()-1:
			is_action_zone_empty = true

		await wait_before_action(action_zone_copy[i], action_zone_copy[i].animation_time)
		apply_player_actions(action_zone_copy[i], action_zone_copy[i].target)

	EventBus.combat_in_progress.emit(true)

	is_action_zone_empty = false

func apply_player_actions(card, _target): #target à définir
	if card.is_flipped:
		var flip_effect_txt = check_flip_effect(card)
		print(flip_effect_txt)
		return

	var attack = int(card.get_node("Attack").text) # ou card.attack si tu veux le stocker
	opponent_ref.take_damage(attack,is_action_zone_empty)
	
func check_flip_effect(card):
	#exemple de valeurs de card.data["flip_effect"] = {"name" : "Block", "animation_time": 0.5, "usage_number": -1, "side_effect" : "none"}
	
	#application de l'effet sur le joueur
	var fe_name = card.flip_effect["e_name"]
	var player_effect_txt : String
	
	if fe_name == "Block":
		player_effect_txt = "+1 block appliqué"
	elif fe_name == "Dodge":
		player_effect_txt = "+1 esquive appliquée"
	elif fe_name == "Breath":
		player_effect_txt = "respiration activée"
	#elif fe_name == "Regen":
		##player.restore_endurance(value)
	else:
		player_effect_txt = "Effet inconnu"

	#var fe_animation_time = card.flip_effect["animation_time"]
	#var fe_usage_number = card.flip_effect["usage_number"]

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
