extends Resource
class_name PLAYERDECK

const CARDS = {
	"Jab_Card_01":{
		"title" : "Jab",
		"id" : "Jab_Card_01",
		"description" : "Coup de poing",
		"image" : "res://assets/fighting_style/boxing/Jab_Card.png",
		"animation_time" : 1.0,
		"attack" : 1,
		"reach" : "single_enemy",
		"slot_number" : 0,
		"effect_per_slot" : {}
	}, 
	"Jab_Card_02":{
		"title" : "Jab",
		"id" : "Jab_Card_02",
		"description" : "Coup de poing",
		"image" : "res://assets/fighting_style/boxing/Jab_Card.png",
		"animation_time" : 1.0,
		"attack" : 1,
		"reach" : "single_enemy",
		"slot_number" : 0,
		"effect_per_slot" : {}
	}, 
	"Jab_Card_03":{
		"title" : "Jab",
		"id" : "Jab_Card_03",
		"description" : "Coup de poing",
		"image" : "res://assets/fighting_style/boxing/Jab_Card.png",
		"animation_time" : 1.0,
		"attack" : 1,
		"reach" : "single_enemy",
		"slot_number" : 0,
		"effect_per_slot" : {}
	}, 
	"Jab_Card_04":{
		"title" : "Jab",
		"id" : "Jab_Card_04",
		"description" : "Coup de poing",
		"image" : "res://assets/fighting_style/boxing/Jab_Card.png",
		"animation_time" : 1.0,
		"attack" : 1,
		"reach" : "single_enemy",
		"slot_number" : 0,
		"effect_per_slot" : {}
	}, 
	"Cross_Card_01":{
		"title" : "Cross",
		"id" : "Cross_Card_01",
		"description" : "Coup de poing bras faible",
		"image" : "res://assets/fighting_style/boxing/Cross_Card.png",
		"animation_time" : 1.0,
		"attack" : 1,
		"reach" : "single_enemy",
		"slot_number" : 0,
		"effect_per_slot" : {}
	}, 
	"Cross_Card_02":{
		"title" : "Cross",
		"id" : "Cross_Card_02",
		"description" : "Coup de poing bras faible",
		"image" : "res://assets/fighting_style/boxing/Cross_Card.png",
		"animation_time" : 1.0,
		"attack" : 1,
		"reach" : "single_enemy",
		"slot_number" : 0,
		"effect_per_slot" : {}
	}, 
	"Power_Cross_Card_01":{
		"title" : "P-Cross",
		"id" : "Power_Cross_Card_01",
		"description" : "Coup de poing bras faible",
		"image" : "res://assets/fighting_style/boxing/P-Cross_Card.png",
		"animation_time" : 1.0,
		"attack" : 1,
		"reach" : "single_enemy",
		"slot_number" : 1,
		"effect_per_slot" : {
				0 : "Block_Augment",
			}
	}, 
	"Hook_Card_01":{
		"title" : "Hook",
		"id" : "Hook_Card_01",
		"description" : "Crochet simple",
		"image" : "res://assets/fighting_style/boxing/Hook_Card.png",
		"animation_time" : 1.2,
		"attack" : 2,
		"reach" : "single_enemy",
		"slot_number" : 2,
		"effect_per_slot" : {
				0 : "Dodge_Augment",
				#1 : "Dodge",
			}
	}, 
	"Uppercut_Card_01":{
		"title" : "Uppercut",
		"id" : "Uppercut_Card_01",
		"description" : "Uppercut simple",
		"image" : "res://assets/fighting_style/boxing/Uppercut_Card.png",
		"animation_time" : 1.5,
		"attack" : 3,
		"reach" : "single_enemy",
		"slot_number" : 1,
		"effect_per_slot" : {
				0 : "Breath_Augment",
			}
	}
}
