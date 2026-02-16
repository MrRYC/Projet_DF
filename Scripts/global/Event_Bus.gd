extends Node

#---------------------#
#    USERINTERFACE    #
#---------------------#
#signals from UserInterface to Playerhand and ActionZone
signal action_timer_timeout(bool)

#---------------------#
#    SOUNDMANAGER     #
#---------------------#
#signals from SoundManager to UserInterface
signal track_played(String)

#---------------------#
#      CARDDATA       #
#---------------------#
#signals from CardData to CardManager
signal hovered()
signal hovered_off()

#---------------------#
#     ACTIONZONE      #
#---------------------#
#signals from ActionZone to IntentMarker
signal card_removed_from_action_zone(bool)

#signals from ActionZone to DefensivePips
signal player_defensive_actions_preview(type: String, charge: int)

#---------------------#
#    INPUTMANAGER     #
#---------------------#
#signals from InputManager to CardManager
signal left_mouse_clicked()
signal left_mouse_released()

#---------------------#
#     TURNMANAGER     #
#---------------------#
#signals from TurnManager to CardManager, OpponentManager & DeckPile
signal new_turn(int, bool)  #bool = true si premier tour

#signals from TurnManager to UserInterface et DeckPile
signal turn_increased(int)

#signals from TurnManager to UserInterface
signal activate_action_timer()

#signals from TurnManager to UserInterface, InputManager, Pips & UserInterface
signal processing(bool)

#signals from TurnManager to Player
signal player_health_updated(int)

#---------------------#
#     CARDMANAGER     #
#---------------------#
#signals from CardManager to CardTargetSelector
signal aim_started()
signal aim_ended()

#signals from CardManager to TurnManager
signal card_played()

#---------------------#
#     PLAYERHAND      #
#---------------------#
#signals from PlayerHand to Player
signal cards_in_hand(int)

#---------------------#
#       DECKPILE      #
#---------------------#
#signals from DeckPile to DiscardPile
signal shuffle_back_discard(bool)

#signals from DeckPile to TurnManager
signal deck_loaded(int)

#---------------------#
#        PLAYER       #
#---------------------#
#signals from Player to PlayerHand
signal drop_combo_cards()
signal get_cards_in_hand()

#signals from Player to CardManager
signal fracture_a_random_card()

#signals between Player and Opponents
signal player_incoming_damage_updated(amount: int)

#---------------------#
#       OPPONENT      #
#---------------------#
#signals from Opponent_Manager to TurnManager
signal matchup_over()

#signals from Opponent_Manager to Player
signal dim_player()
signal undim_player()

#signals from Opponent to TurnManager
signal ai_attack_performed(int)
signal ai_cancel_combo_performed()

#signals from Opponent to UserInterface
signal combo_meter_cancelled()
signal combo_meter_increased()
signal combo_meter_altered(int)

#signals between Player and Opponents
signal opponent_incoming_damage_updated()

#---------------------#
#    INTENTMARKER     #
#---------------------#
#signals from IntentMarker to ActionZone
signal opponent_marker_hovered(opponent:OPPONENT)
signal opponent_marker_hovered_off()
signal player_marker_hovered(target)
signal player_marker_hovered_off()
