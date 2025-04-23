extends Node

#signals from Card to CardManager
signal hovered()
signal hovered_off()

#signals from InputManager to CardManager
signal left_mouse_clicked()
signal left_mouse_released()

#signals from BattleManager to CardManager and InputManager
signal attack_phase_signal()
signal defense_phase_signal()

#signals from BattleManager to UserInterface
signal turn_increased(int)
signal combat_phase_changed(String)
signal combat_in_progress(bool)

#signals from BattleManager to Player
signal player_health_updated(int)

#signals from CardManager to CardTargetSelector
signal aim_started()
signal aim_ended()
