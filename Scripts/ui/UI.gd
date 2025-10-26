extends Node 

func _ready() -> void:
	EventBus.turn_increased.connect(_on_turn_increased)
	EventBus.combat_in_progress.connect(_on_combat_in_progress)

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_turn_increased(turn):
	$TurnLabel.text = str("Turn ",turn)

func _on_combat_in_progress(is_action_phase_ended):
	if !is_action_phase_ended:
		$ActionButton.disabled = true
		$EmptyActionZoneButton.disabled = true
	else:
		$ActionButton.disabled = false
		$EmptyActionZoneButton.disabled = false
