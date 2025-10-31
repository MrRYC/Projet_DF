extends Node2D
class_name CARD


###########################################################################
#                               CARD STATE                                #
###########################################################################

var starting_position #position de départ de la carte utilisée dans la funct update_hand_positions du script PlayerHand
enum board_area { IN_PILE, IN_HAND, IN_ACTION_ZONE } # 0 = IN_PILE, 1 = IN_HAND, 2 = IN_ACTION_ZONE
var current_area : board_area = board_area.IN_PILE

var id : String
var animation_time : float
var attack : int
var reach : String = "" #single or multi target
var target : Node2D
var slot_number : int = 0
var effect_per_slot : Dictionary = {}
var is_flipped = false

###########################################################################
#                          CARD CONFIGURATION                             #
###########################################################################

func setup_card(data: Dictionary):
	if data.has("title"):
		$Name.text = data["title"]

	if data.has("id"):
		id = data["id"]

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

	#liste des augments id si carte à des slots
	if data.has("effect_per_slot"):
		effect_per_slot = data["effect_per_slot"]

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_area_2d_mouse_entered() -> void:
	EventBus.hovered.emit(self)

func _on_area_2d_mouse_exited() -> void:
	EventBus.hovered_off.emit(self)
