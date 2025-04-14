extends Node2D

signal hovered
signal hovered_off

#variables du script
var starting_position #position de départ de la carte utilisée dans la funct update_hand_positions du script PlayerHand
var card_name
#var card_type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().connect_card_signals(self)

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered",self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off",self)
