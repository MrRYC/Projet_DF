extends Node2D

#variables du script
var starting_position #position de départ de la carte utilisée dans la funct update_hand_positions du script PlayerHand
var id : String
var animation_time : float
var flip_effect : Dictionary = {}
var is_in_action_zone = false
var is_flipped = false
var usage_number : int
var reach : String #single or multi target
var target #retourne ennemi ciblé

func setup_card(data: Dictionary):
	if data.has("name"):
		$Name.text = data["name"]
	if data.has("animation_time"):
		animation_time = data["animation_time"]
		$Time.text = str(data["animation_time"])
	if data.has("attack"):
		$Attack.text = str(data["attack"])
	if data.has("usage_number"):
		usage_number = data["usage_number"]
	if data.has("reach"):
		reach = data["reach"]
	if data.has("flip_effect"):
		flip_effect = data["flip_effect"]

func _on_area_2d_mouse_entered() -> void:
	EventBus.hovered.emit(self)

func _on_area_2d_mouse_exited() -> void:
	EventBus.hovered_off.emit(self)
