const CARDS = {# Name, Cost, Attack, Slots, Effects
	"Jab_Card":{
		"name" = "Jab",
		"cost" = 1,
		"attack" = 5,
		"slots" = 0,
		"effects" = {} #effects : type, value (bonus or malus) and cost or regen point
	}, 
	"Direct_Card":{
		"name" = "Direct",
		"cost" = 2,
		"attack" = 10,
		"slots" = 1,
		"effects" = {"type": "block", "value": 1, "endurance_cost": 10}
	}, 
	"Hook_Card":{
		"name" = "Hook",
		"cost" = 3,
		"attack" = 15,
		"slots" = 0,
		"effects" = {}
	}, 
	"Hypercut_Card":{
		"name" = "Hypercut",
		"cost" = 4,
		"attack" = 25,
		"slots" = 0,
		"effects" = {}
	}
}
