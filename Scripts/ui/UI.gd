extends Node

func turn_update(turn):
	$TurnLabel.text = str("Turn ",turn)
	
func player_health_update(current_health,max_health):
	$PlayerHealthLabel.text = str(current_health, " / ", max_health)

func update_phase_button(current_phase):
	$PhaseButton.text = current_phase

func enable_phase_button(is_phase_ended):
	if !is_phase_ended:
		$PhaseButton.disabled = true
	else:
		$PhaseButton.disabled = false

func update_refresh_button(is_attack_phase):
	if is_attack_phase:
		$RefreshActionZoneButton.disabled = false
	else:
		$RefreshActionZoneButton.disabled = true
