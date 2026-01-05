extends Node

#signals from CardData to CardManager
signal hovered()
signal hovered_off()

#signals from IntentMarker to ActionZone
signal opponent_marker_hovered(opponent:OPPONENT)
signal opponent_marker_hovered_off()
signal player_marker_hovered(target)
signal player_marker_hovered_off()

#signals from ActionZone to IntentMarker
signal card_removed_from_action_zone(bool)

#signals from InputManager to CardManager
signal left_mouse_clicked()
signal left_mouse_released()

#signals from TurnManager to CardManager, OpponentManager & DeckPile
signal new_turn(int, bool)  #bool = true si premier tour

#signals from TurnManager to UserInterface et DeckPile
signal turn_increased(int)

#signals from TurnManager to UserInterface
signal activate_action_timer()

#signals from TurnManager to UserInterface, InputManager, ActionZone, DeckPile & UserInterface
signal processing(bool)

#signals from TurnManager to Player
signal player_health_updated(int)

#signals from UserInterface to Playerhand and ActionZone
signal action_timer_timeout(bool)

#signals from CardManager to CardTargetSelector
signal aim_started()
signal aim_ended()

#signals from CardManager to TurnManager
signal card_played()

#signals from DeckPile to DiscardPile
signal shuffle_back_discard(bool)

#signals from DeckPile to TurnManager
signal deck_loaded(int)

#signals from Opponent_Manager to TurnManager
signal matchup_over()

#signals from Opponent to TurnManager
signal ai_attack_performed(int)
signal ai_cancel_combo_performed()

#signals from Opponent to UserInterface
signal combo_meter_cancelled()
signal combo_meter_increased()
signal combo_meter_altered(int)

#signals from Player to PlayerHand
signal dim_player()
signal undim_player()
signal drop_combo_cards()

#signals from SoundManager to UserInterface
signal track_played(String)

#signals between Player and Opponents
signal player_incoming_damage_updated(amount: int)
signal opponent_incoming_damage_updated()
signal player_defense_updated()
