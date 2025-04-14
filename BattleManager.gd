extends Node

#signaux
signal defense_phase_signal

#constantes

#variables de référence vers un autre Node
var phase_button_ref
var card_manager_ref
var player_hand_ref
var deck_pile_ref
var discard_pile_ref
var discard_pile_label_ref
var player_health_label_ref

#variables du script
var is_attack_phase = true
var is_defensive_phase = false
var is_end_phase = false
var current_phase = "Attack Phase"
var start_hand_size = 4 #main de départ maximum
var max_hand_size
var nb_turn = 1
var player_health = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	phase_button_ref = $"../UserInterface/PhaseButton"
	card_manager_ref = $"../CardManager"
	player_hand_ref = $"../PlayerHand"
	deck_pile_ref = $"../DeckPile"
	discard_pile_ref = $"../DiscardPile"
	player_health_label_ref = $"../UserInterface/PlayerHealthLabel"
	
	max_hand_size = start_hand_size
	
	for i in range(start_hand_size):
		deck_pile_ref.draw_card()
	
	#Player Health equals to all the players cards (deck + hand + discard)
	count_player_card_in_game()
	player_health_label_ref.text = str(player_health)

func _on_phase_button_pressed() -> void:
	if is_attack_phase == true:
		defensive_phase()
	elif is_defensive_phase == true:
		end_phase()
	else:
		end_turn()
		new_turn()
		attack_phase()
		nb_turn += 1
		$"../UserInterface/TurnLabel".text = "Turn " + str(nb_turn)

func new_turn():
	deck_pile_ref.new_turn(max_hand_size)

func end_turn():
	player_hand_ref.discard_hand()

func count_player_card_in_game():
	player_health = deck_pile_ref.player_deck.size() + player_hand_ref.player_hand.size() + discard_pile_ref.player_discard.size()

func attack_phase():
	current_phase = "Attack Phase"
	phase_button_ref.text = current_phase
	is_attack_phase = true
	is_end_phase = false

func defensive_phase():
	current_phase = "Defensive Phase"
	phase_button_ref.text = current_phase
	is_defensive_phase = true
	is_attack_phase = false
	defense_phase_signal.emit(current_phase, nb_turn)

func end_phase():
	current_phase = "End Phase"
	phase_button_ref.text = current_phase
	is_end_phase = true
	is_defensive_phase = false

#func attack_phase_calculator(attack_card, opponent):
	#pass
#
#func defense_phase_calculator(defense_effect, attacker, base_damage):
	#pass
