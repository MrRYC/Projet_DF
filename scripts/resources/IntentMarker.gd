extends Node2D
class_name MARKER

@onready var marker_border: Control = $MarkerBorder

###########################################################################
#                             MARKER STATE                                #
###########################################################################

var opponent : Node2D
var attack_threshold : int
var marker_color : Array[Color] = [Color(1, 0, 0),Color(13, 12, 0.0, 1.0),Color(0.6, 0.3, 1.0, 1.0),Color(0.008, 0.0, 0.843, 1.0),Color(0.875, 0.341, 0.043, 1.0)]
var color_selector : int = 0
var opponent_color : Color

###########################################################################
#                        COlOR RECT MANAGEMENT                            #
###########################################################################

func toggle_border(value:bool):
	$MarkerBorder.visible = value

func change_color():
	self.opponent_color = marker_color[color_selector]
	
	for child in marker_border.get_children():
		if child is ColorRect:
			child.color = self.opponent_color
	
	color_selector += 1
