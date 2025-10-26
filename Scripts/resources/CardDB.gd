const CARDS = {
	"Jab_Card":{
		"name" = "Jab",
		"animation_time" = 1.0,
		"attack" = 1,
		"usage_number" = -1,
		"reach" = "single_enemy",
		"slots" = 0,
		"flip_effect" = {} #effects : name, animation_time, nombre d'usage, side_effect(bonus/malus)
	}, 
	"Cross_Card":{
		"name" = "Cross",
		"animation_time" = 1.0,
		"attack" = 1,
		"usage_number" = -1,
		"reach" = "single_enemy",
		"slots" = 1,
		"flip_effect" = {"name" : "Block", "animation_time": 0.5, "usage_number": -1, "side_effect" : "none"}
	}, 
	"Hook_Card":{
		"name" = "Hook",
		"animation_time" = 1.2,
		"attack" = 2,
		"usage_number" = -1,
		"reach" = "single_enemy",
		"slots" = 0,
		"flip_effect" = {"name" : "Dodge", "animation_time": 0.6, "usage_number": 2, "side_effect" : "wound"} #replace wound par inactivate after usage_number
	}, 
	"Uppercut_Card":{
		"name" = "Uppercut",
		"animation_time" = 1.5,
		"attack" = 3,
		"usage_number" = -1,
		"reach" = "single_enemy",
		"slots" = 0,
		"flip_effect" = {"name" : "Breath", "animation_time": 1.0, "usage_number": 1, "side_effect" : "banish"}
	}
}
