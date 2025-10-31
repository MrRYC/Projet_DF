extends Node2D
class_name AUGMENT

#variables du script
var title : String
var description : String
var effect : String
var side_effect : String = ""
var condition : String = ""
var time_cost : float
var value : int
var uses : int

###########################################################################
#                       ENHANCEMENT CONFIGURATION                         #
###########################################################################

func setup_enhancement(data: Dictionary):
	if data.has("title"):
		title = data["title"]

	if data.has("description"):
		description = data["description"]

	if data.has("effect"):
		effect = data["effect"]

	if data.has("side_effect"):
		side_effect = data["side_effect"]

	if data.has("condition"):
		condition = data["condition"]

	if data.has("time_cost"):
		time_cost = data["time_cost"]
		
	if data.has("value"):
		value = data["value"]
		
	if data.has("uses"):
		uses = data["uses"]
