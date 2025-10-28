const CARDS = {
	"Jab_Card":{
		"title" = "Jab",
		"description" = "Coup de poing",
		"image" = "res://assets/fighting_style/boxing/Jab_Card.png",
		"animation_time" = 1.0,
		"attack" = 1,
		"reach" = "single_enemy",
		"slot_flip_effect" = {},
	}, 
	"Cross_Card":{
		"title" = "Cross",
		"description" = "Coup de poing bras faible",
		"image" = "res://assets/fighting_style/boxing/Cross_Card.png",
		"animation_time" = 1.0,
		"attack" = 1,
		"reach" = "single_enemy",
		"slot_number" = 1,
		"slot_flip_effect" = {
				"title" : "Block",
				"effect" : "add_block",
				"side_effect" : null,
				"condition" : null,
				"time_cost" : 0.5,
				"value" : 1,
				"uses" : null
			}
	}, 
	"Hook_Card":{
		"title" = "Hook",
		"description" = "Crochet simple",
		"image" = "res://assets/fighting_style/boxing/Hook_Card.png",
		"animation_time" = 1.2,
		"attack" = 2,
		"reach" = "single_enemy",
		"slot_number" = 2,
		"slot_flip_effect" = {
				"title" : "Dodge",
				"effect" : "add_dodge",
				"side_effect" : "inactive",
				"condition" : null,
				"time_cost" : 0.6,
				"value" : 1,
				"uses" : 2
			}
	}, 
	"Uppercut_Card":{
		"title" = "Uppercut",
		"description" = "Uppercut simple",
		"image" = "res://assets/fighting_style/boxing/Uppercut_Card.png",
		"animation_time" = 1.5,
		"attack" = 3,
		"reach" = "single_enemy",
		"slot_number" = 1,
		"slot_flip_effect" = {
				"title" : "Breath",
				"effect" : "add_breath",
				"side_effect" : "exhaust",
				"time_cost" : 1.0,
				"value" : 1,
				"uses" : 1,
			}#, slot 2
			#{
				#"title" : "Block",
				#"effect" : "add_block",
				#"value" : 1,
				#"e_usage_number": -1,
				#"e_side_effect" : "none"
				#"condition": [
					#{"fn": "owner_endurance_at_least", "value": 10} # ex condition
				#],
			#}
	}
}
