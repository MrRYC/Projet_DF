const CARDS = {
	"Jab_Card":{
		"title" = "Jab",
		"animation_time" = 1.0,
		"attack" = 1,
		"reach" = "single_enemy",
		"slots" = [],
	}, 
	"Cross_Card":{
		"title" = "Cross",
		"animation_time" = 1.0,
		"attack" = 1,
		"reach" = "single_enemy",
		"slots" = [
			{
				"id" : "Block",
				"effect" : "add_block",
				"value" : 1,
				"uses" : -1,
				"side_effect" : "none"
			}#, slot 2
			#{
				#"id" : "Block",
				#"effect" : "add_block",
				#"value" : 1,
				#"e_usage_number": -1,
				#"e_side_effect" : "none"
			#}
		]
		
	}, 
	"Hook_Card":{
		"title" = "Hook",
		"animation_time" = 1.2,
		"attack" = 2,
		"reach" = "single_enemy",
		"slots" = [
			{
				"id" : "Dodge",
				"effect" : "add_dodge",
				"value" : 1,
				"uses" : 2,
				"side_effect" : "wound"
			}
		]
	}, 
	"Uppercut_Card":{
		"title" = "Uppercut",
		"animation_time" = 1.5,
		"attack" = 3,
		"reach" = "single_enemy",
		"slots" = [
			{
				"id" : "Breath",
				"effect" : "add_breath",
				"value" : 1,
				#"conditions": [
					#{"fn": "owner_endurance_at_least", "value": 10} # ex condition
				#],
				"uses" : 1,
				"side_effect" : "exhaust"
			}
		]
	}
}
