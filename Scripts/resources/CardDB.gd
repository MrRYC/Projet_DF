const CARDS = {
	"Jab_Card":{
		"name" = "Jab",
		"endurance_cost" = 1,
		"attack" = 5,
		"reach" = "single_enemy",
		"animation_time" = 1.0,
		"slots" = 0,
		"effects" = {} #effects : type, value (bonus or malus) and cost or regen point
	}, 
	"Direct_Card":{
		"name" = "Direct",
		"endurance_cost" = 2,
		"attack" = 10,
		"reach" = "single_enemy",
		"animation_time" = 1.0,
		"slots" = 1,
		"effects" = {"type": "block", "value": 1, "endurance_cost": 10, "reach" : "self"}
	}, 
	"Hook_Card":{
		"name" = "Hook",
		"endurance_cost" = 3,
		"attack" = 15,
		"reach" = "all_enemy",
		"animation_time" = 1.2,
		"slots" = 0,
		"effects" = {}
	}, 
	"Uppercut_Card":{
		"name" = "Uppercut",
		"endurance_cost" = 4,
		"attack" = 25,
		"reach" = "single_enemy",
		"animation_time" = 1.5,
		"slots" = 0,
		"effects" = {}
	}
}
