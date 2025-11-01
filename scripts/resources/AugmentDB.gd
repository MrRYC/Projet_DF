extends Resource
class_name AUGMENTDB

const AUGMENTS = {
	"Block_Augment" : {
		"id" : "Block",
		"description" : "add 1 block",
		"side_effect" : null,
		"condition" : null,
		"time_cost" : 0.5,
		"value" : 1,
		"uses" : null
	}, 
	"Dodge_Augment" : {
		"id" : "Dodge",
		"description" : "add 1 dodge",
		"side_effect" : "inactivate",
		"condition" : null,
		"time_cost" : 0.6,
		"value" : 1,
		"uses" : 2
	}, 
	"Breath_Augment" : {
		"id" : "Breath",
		"description" : "add 2.5 recovery",
		"side_effect" : "exhaust",
		"time_cost" : 1.0,
		"value" : 1,
		"uses" : 1,
	}
}
