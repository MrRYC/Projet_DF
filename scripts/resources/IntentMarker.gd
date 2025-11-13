extends Node2D
class_name MARKER

###########################################################################
#                             MARKER STATE                                #
###########################################################################

var opponent : Node2D
var array_position : int
#var color_palet : Array[Color] = [Color(0.0, 0.0, 0.0, 1.0),Color(0.773, 0.0, 0.235, 0.996),Color(0.953, 0.902, 0.0, 0.996),Color(0.333, 0.918, 0.831, 1.0),Color(0.059, 0.584, 0.584, 1.0),Color(0.757, 0.067, 0.353, 1.0),Color(0.761, 0.322, 0.882, 1.0)]


func toggle_border(value:bool):
	$PlayerMarkerBorder.visible = value

###########################################################################
#                        COlOR RECT MANAGEMENT                            #
###########################################################################

func set_color():
	var marker_corlor : Color
	
	if self.opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THRESHOLD:
		marker_corlor = Color(0.773, 0.0, 0.235, 0.996)
	elif self.opponent.data.behavior_type == OPPONENT_DATA.behaviors.ATTACK_AT_THE_END:
		marker_corlor = Color(0.953, 0.902, 0.0, 0.996)

	for child in $OpponentMarkerBorder.get_children():
		if child is ColorRect:
			child.color = marker_corlor

	for child in $PlayerMarkerBorder.get_children():
		if child is ColorRect:
			child.color = Color(0.333, 0.918, 0.831, 1.0)

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_marker_area_2d_mouse_entered() -> void:
	EventBus.marker_hovered.emit(opponent)


func _on_marker_area_2d_mouse_exited() -> void:
	EventBus.marker_hovered_off.emit()
