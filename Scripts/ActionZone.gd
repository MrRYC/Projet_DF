extends Node2D

#constantes
const action_ZONE_X_POSITION = 125

#variables de référence
@onready var card_manager_ref = $"../CardManager"

#variables du script
var action_zone = []

###########################################################################
#                          ACTION ZONE MANAGEMENT                         #
###########################################################################

func add_card_to_action_zone(card, speed):
	if card not in action_zone:
		action_zone.insert(0,card)
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
		card_manager_ref.return_card_to_hand(card)

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
