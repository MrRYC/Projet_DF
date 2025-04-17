extends Node2D

signal hovered
signal hovered_off

#variables du script
var starting_position #position de départ de la carte utilisée dans la funct update_hand_positions du script PlayerHand
var card_name = ""
var animation_time = 0.0
var effects = []
var is_in_action_zone = false
var target

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().connect_card_signals(self)

func setup_card(data: Dictionary):
	if data.has("name"):
		$Name.text = data["name"]
	if data.has("cost"):
		$Cost.text = str(data["cost"])
	if data.has("attack"):
		$Attack.text = str(data["attack"])
	if data.has("animation_time"):
		animation_time = data["animation_time"]
		#$Animation_time.text = str(data["animation_time"])
	if data.has("effects"):
		effects = data["effects"]

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered",self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off",self)
