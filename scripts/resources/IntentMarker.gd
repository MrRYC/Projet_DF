extends Node2D
class_name MARKER

###########################################################################
#                             MARKER STATE                                #
###########################################################################

var opponent : Node2D
var array_position : int
#var marker_color : Array[Color] = ["",Color(1, 0, 0),Color(13, 12, 0.0, 1.0),Color(0.6, 0.3, 1.0, 1.0),Color(0.008, 0.0, 0.843, 1.0),Color(0.875, 0.341, 0.043, 1.0)]

###########################################################################
#                        COlOR RECT MANAGEMENT                            #
###########################################################################

func toggle_border(value:bool):
	$MarkerBorder.visible = value

func set_color():
	for child in $MarkerBorder.get_children():
		if child is ColorRect:
			child.color = Color(1, 0, 0)
