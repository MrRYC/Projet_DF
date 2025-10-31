extends Node

#signals from Card to CardManager
signal hovered()
signal hovered_off()

#signals from InputManager to CardManager
signal left_mouse_clicked()
signal left_mouse_released()

#signals from TurnManager to UserInterface, InputManager, CardManager & Deck
signal new_turn(int)
signal turn_increased(int)
signal combat_in_progress(bool)

#signals from TurnManager to Player
signal player_health_updated(int)

#signals from CardManager to CardTargetSelector
signal aim_started()
signal aim_ended()

#signals from DeckPile to DiscardPile
signal shuffle_back_discard(bool)
