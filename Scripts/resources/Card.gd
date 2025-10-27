extends Node2D
class_name CARD

#variables du script
var starting_position #position de départ de la carte utilisée dans la funct update_hand_positions du script PlayerHand
var id : String
enum card_area { IN_DECK, IN_HAND, IN_ACTION_ZONE, IN_DISCARD, IN_WOUND, IN_EXHAUST } # 0 = IN_DECK, 1 = IN_HAND, 2 = IN_ACTION_ZONE, 3 = IN_DISCARD, 4 = IN_WOUND, 5 = IN_EXHAUST
var card_current_area : card_area = card_area.IN_DECK
var animation_time : float
var attack : int
var c_usage_number : int
var e_usage_number : int
var slot : int
var reach : String #single or multi target
var target #retourne ennemi ciblé
var is_flipped = false
var flip_effect : Dictionary = {}

func setup_card(data: Dictionary):
	if data.has("c_name"):
		$Name.text = data["c_name"]
	if data.has("c_animation_time"):
		animation_time = data["c_animation_time"]
		$Time.text = str(data["c_animation_time"])
	if data.has("c_attack"):
		attack = data["c_attack"] 
		$Attack.text = str(data["c_attack"])
	if data.has("c_usage_number"):
		c_usage_number = data["c_usage_number"]
	if data.has("c_reach"):
		reach = data["c_reach"]
	if data.has("c_slot"):
		slot = data["c_slot"]
	if data.has("c_flip_effect"):
		flip_effect = data["c_flip_effect"]

func _on_area_2d_mouse_entered() -> void:
	EventBus.hovered.emit(self)

func _on_area_2d_mouse_exited() -> void:
	EventBus.hovered_off.emit(self)
