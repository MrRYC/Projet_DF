extends Resource
class_name AUGMENT_DB

const CARDS = {
	"Block" : {
		"title" : "Block",
		"effect" : "add_block",
		"side_effect" : null,
		"condition" : null,
		"time_cost" : 0.5,
		"value" : 1,
		"uses" : null
	}, 
	"Dodge" : {
		"title" : "Dodge",
		"effect" : "add_dodge",
		"side_effect" : "inactive",
		"condition" : null,
		"time_cost" : 0.6,
		"value" : 1,
		"uses" : 2
	}, 
	"Breath" : {
		"title" : "Breath",
		"effect" : "add_breath",
		"side_effect" : "exhaust",
		"time_cost" : 1.0,
		"value" : 1,
		"uses" : 1,
	}
}
