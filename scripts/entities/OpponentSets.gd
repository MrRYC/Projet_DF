extends Resource
class_name OPPONENTS_SETS

const SETS = {
	#"Girl" : {
		#"opponents_per_set" : {
			#1 : "res://scripts/entities/opponents/girl_fighter.tres"
		#}
	#}, 
	#"2_Girls" : {
		#"opponents_per_set" : {
			#1 : "res://scripts/entities/opponents/girl_fighter.tres",
			#2 : "res://scripts/entities/opponents/girl_fighter.tres"
		#}
	#}, 
	#"3_Girls" : {
		#"opponents_per_set" : {
			#1 : "res://scripts/entities/opponents/girl_fighter.tres",
			#2 : "res://scripts/entities/opponents/girl_fighter.tres",
			#3 : "res://scripts/entities/opponents/girl_fighter.tres"
		#}
	#}, 
	"Duo" : {
		"opponents_per_set" : {
			1 : "res://scripts/entities/opponents/girl_fighter.tres",
			2 : "res://scripts/entities/opponents/men_fighter.tres"
		}
	},
}
