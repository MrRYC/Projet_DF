extends Node 

func _ready() -> void:
	EventBus.turn_increased.connect(_on_turn_increased)
	EventBus.combat_phase_changed.connect(_on_combat_phase_changed)
	EventBus.combat_in_progress.connect(_on_combat_in_progress)

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_turn_increased(turn):
	$TurnLabel.text = str("Turn ",turn)

func _on_combat_phase_changed(current_phase):
	if current_phase == "Attack Phase":
		$RefreshActionZoneButton.disabled = false
	else:
		$RefreshActionZoneButton.disabled = true
	
	$PhaseButton.text = current_phase

func _on_combat_in_progress(is_phase_ended):
	if !is_phase_ended:
		$PhaseButton.disabled = true
	else:
		$PhaseButton.disabled = false
