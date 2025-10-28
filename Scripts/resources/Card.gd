extends Node2D
class_name CARD

#variables du script
#var slots_flip_effect: Array = []             # définitions de slots (depuis CardDB)

var starting_position #position de départ de la carte utilisée dans la funct update_hand_positions du script PlayerHand
enum card_area { IN_DECK, IN_HAND, IN_ACTION_ZONE, IN_DISCARD, IN_WOUND, IN_EXHAUST } # 0 = IN_DECK, 1 = IN_HAND, 2 = IN_ACTION_ZONE, 3 = IN_DISCARD, 4 = IN_WOUND, 5 = IN_EXHAUST
var card_current_area : card_area = card_area.IN_DECK

var id : String
var animation_time : float
var attack : int
var reach : String #single or multi target
var target : Node2D
var slot_number : int
var slot_flip_effect : Dictionary = {}
var is_flipped = false

###########################################################################
#                          CARD CONFIGURATION                             #
###########################################################################

func setup_card(data: Dictionary):
	if data.has("title"):
		$Name.text = data["title"]

	if data.has("description"):
		#$Name.text = data["description"]
		pass

	if data.has("animation_time"):
		animation_time = data["animation_time"]
		$Time.text = str(data["animation_time"])
		
	if data.has("attack"):
		attack = data["attack"] 
		$Attack.text = str(data["attack"])
		
	if data.has("reach"):
		reach = data["reach"]

	if data.has("slot_number"):
		slot_number = data["slot_number"] 

	if data.has("slot_flip_effect"):
		slot_flip_effect = data["slot_flip_effect"]

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_area_2d_mouse_entered() -> void:
	EventBus.hovered.emit(self)

func _on_area_2d_mouse_exited() -> void:
	EventBus.hovered_off.emit(self)
