extends Node
class_name DefenseController

#signaux
signal block_changed(value: int)
signal dodge_activated(status: bool)

#variables du script
var block_charges: int = 0
var is_dodge_activated: bool = false

###########################################################################
#                          GESTION DE L'ESQUIVE                           #
###########################################################################

func get_block() -> int:
	return block_charges

func set_block(value: int) -> void:
	var new_value:int = max(0, value)
	if new_value == block_charges:
		return
	block_charges = new_value
	block_changed.emit(block_charges)

func grant_block(charges: int) -> void:
	if charges <= 0:
		return
	set_block(block_charges + charges)

func has_block() -> bool:
	return block_charges > 0

func try_block_hit() -> bool:
	if block_charges <= 0:
		return false
	set_block(block_charges - 1)
	return true

###########################################################################
#                          GESTION DE L'ESQUIVE                           #
###########################################################################

func get_dodge() -> bool:
	return is_dodge_activated

func set_dodge(status: bool) -> void:
	is_dodge_activated = status
	dodge_activated.emit(is_dodge_activated)

###########################################################################
#                            RESET DES VALEURS                            #
###########################################################################

func reset_for_new_turn() -> void:
	set_block(0)
	set_dodge(false)
