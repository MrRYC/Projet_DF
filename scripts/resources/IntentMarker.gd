extends Node2D
class_name MARKER

###########################################################################
#                             MARKER STATE                                #
###########################################################################

var opponent : Node2D
var array_position : int
#var marker_color : Array[Color] = [Color(0.0, 0.0, 0.0, 1.0),Color(0.773, 0.0, 0.235, 0.996),Color(0.533, 0.016, 0.145, 1.0),Color(0.953, 0.902, 0.0, 0.996),Color(0.333, 0.918, 0.831, 1.0)]

###########################################################################
#                        COlOR RECT MANAGEMENT                            #
###########################################################################

func toggle_border(value:bool):
	$MarkerBorder.visible = value

func set_color():
	var marker_corlor : Color
	
	if self.opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THRESHOLD:
		marker_corlor = Color(0.773, 0.0, 0.235, 0.996)
	elif self.opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THE_END:
		marker_corlor = Color(0.333, 0.918, 0.831, 1.0)
	for child in $MarkerBorder.get_children():
		if child is ColorRect:
			child.color = marker_corlor

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_marker_area_2d_mouse_entered() -> void:
	EventBus.marker_hovered.emit(opponent)


func _on_marker_area_2d_mouse_exited() -> void:
	EventBus.marker_hovered_off.emit()
