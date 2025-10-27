const CARDS = {
	"Jab_Card":{
		"c_name" = "Jab",
		"c_animation_time" = 1.0,
		"c_attack" = 1,
		"c_usage_number" = -1,
		"c_reach" = "single_enemy",
		"c_slots" = 0,
		"c_flip_effect" = {} #effects : name, animation_time, nombre d'usage, side_effect(bonus/malus)
	}, 
	"Cross_Card":{
		"c_name" = "Cross",
		"c_animation_time" = 1.0,
		"c_attack" = 1,
		"c_usage_number" = -1,
		"c_reach" = "single_enemy",
		"c_slots" = 1,
		"c_flip_effect" = {"e_name" : "Block", "e_animation_time": 0.5, "e_usage_number": -1, "e_side_effect" : "none"}
	}, 
	"Hook_Card":{
		"c_name" = "Hook",
		"c_animation_time" = 1.2,
		"c_attack" = 2,
		"c_usage_number" = -1,
		"c_reach" = "single_enemy",
		"c_slots" = 0,
		"c_flip_effect" = {"e_name" : "Dodge", "e_animation_time": 0.6, "e_usage_number": 2, "e_side_effect" : "wound"} #replace wound par inactivate after usage_number
	}, 
	"Uppercut_Card":{
		"c_name" = "Uppercut",
		"c_animation_time" = 1.5,
		"c_attack" = 3,
		"c_usage_number" = -1,
		"c_reach" = "single_enemy",
		"c_slots" = 0,
		"c_flip_effect" = {"e_name" : "Breath", "e_animation_time": 1.0, "e_usage_number": 1, "e_side_effect" : "exhaust"}
	}
}
