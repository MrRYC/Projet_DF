extends Node
class_name DefenseController

#signaux
signal block_changed(value: int)
signal dodge_changed(value: int)
signal feint_changed(value: int)

#variables du script
var block_charges: int = 0
var dodge_charges: int = 0
var feint_charges: int = 0

###########################################################################
#                           GESTION DU BLOCAGE                            #
###########################################################################

func get_block() -> int:
	return block_charges

func set_block(value: int) -> void:
	block_charges = value
	block_changed.emit(block_charges)

func add_block(value: int) -> void:
	block_charges += value
	block_changed.emit(block_charges)

func has_block() -> bool:
	return block_charges > 0

func try_to_block() -> bool:
	if !has_block():
		return false
	set_block(block_charges - 1)
	return true

###########################################################################
#                          GESTION DE L'ESQUIVE                           #
###########################################################################

func get_dodge() -> int:
	return dodge_charges

func set_dodge(value: int) -> void:
	dodge_charges = value
	dodge_changed.emit(dodge_charges)

func add_dodge(value: int) -> void:
	dodge_charges += value
	dodge_changed.emit(dodge_charges)

func has_dodge() -> bool:
	return dodge_charges > 0

func try_to_evade() -> bool:
	if !has_dodge():
		return false
	set_dodge(dodge_charges - 1)
	return true

###########################################################################
#                          GESTION DES FEINTES                           #
###########################################################################

func get_feint() -> int:
	return feint_charges

func set_feint(value: int) -> void:
	feint_charges = value
	feint_changed.emit(feint_charges)

func add_feint(value: int) -> void:
	feint_charges += value
	feint_changed.emit(feint_charges)

func has_feint() -> bool:
	return feint_charges > 0

func try_to_feint() -> bool:
	if !has_feint():
		return false
	set_feint(feint_charges - 1)
	return true

###########################################################################
#                            RESET DES VALEURS                            #
###########################################################################

func reset_for_new_turn() -> void:
	set_block(0)
	set_dodge(0)
	set_feint(0)
