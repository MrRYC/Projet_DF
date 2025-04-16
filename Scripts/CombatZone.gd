extends Node2D

#constantes
const COMBAT_ZONE_X_POSITION = 150

#variables de référence
@onready var card_manager_ref = $"../CardManager"
@onready var discard_pile_ref = $"../DiscardPile"
@onready var opponent_ref = $"../Opponent"

#variables du script
var combat_zone = []

###########################################################################
#                          COMBAT ZONE MANAGEMENT                         #
###########################################################################

func add_card_to_combat_zone(card, speed):
	if card not in combat_zone:
		combat_zone.insert(0, card)
		update_combat_zone_positions(speed)

func remove_card_from_combat_zone(card):
	if card in combat_zone:
		combat_zone.erase(card)
		update_combat_zone_positions(Global.DEFAULT_CARD_MOVE_SPEED)

###########################################################################
#                            ACTIONS EXECUTION                            #
###########################################################################

func execute_actions():
	for  i in range(combat_zone.size()):
		var card = combat_zone[i]
		apply_card_effect(card, card.target)
		#animation de la carte avant disparition --> explosion 
		discard_pile_ref.add_card_to_discard(card)
	
	combat_zone.clear()

func apply_card_effect(card, opponent):
	var attack = int(card.get_node("Attack").text) # ou card.attack si tu veux le stocker
	opponent_ref.take_damage(attack)

###########################################################################
#                              CARDS POSITION                             #
###########################################################################

func update_combat_zone_positions(speed):
	var combat_zone_y_position = 150
	for i in range(combat_zone.size()-1, -1, -1): #-1, -1, -1 permet de lire le tableau en sens inverse
		var new_position = Vector2(COMBAT_ZONE_X_POSITION, combat_zone_y_position)
		var card = combat_zone[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position, speed)
		combat_zone_y_position += 100

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
