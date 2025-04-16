extends Node

#signaux
signal defense_phase_signal

#constantes
const START_HAND_SIZE = 4 #main de départ maximum

#variables de référence vers un autre Node
@onready var phase_button_ref = $"../UserInterface/PhaseButton"
@onready var player_hand_ref = $"../PlayerHand"
@onready var deck_pile_ref = $"../DeckPile"
@onready var discard_pile_ref = $"../DiscardPile"
@onready var combat_zone_ref = $"../CombatZone"

#variables du script
var is_attack_phase = true
var is_defensive_phase = false
var is_end_phase = false
var current_phase = "Attack Phase"
var new_hand_max_size = START_HAND_SIZE
var nb_turn = 1
var player_max_health
var current_player_health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(START_HAND_SIZE):
		deck_pile_ref.draw_card()
	
	#Player Health equals to all the players cards (deck + hand + discard)
	count_player_card_in_game()
	player_max_health = current_player_health
	$"../UserInterface/PlayerHealthLabel".text = str(current_player_health, " / ", player_max_health)

func _on_phase_button_pressed() -> void:
	if is_attack_phase == true:
		combat_zone_ref.execute_actions()
		defensive_phase()
	elif is_defensive_phase == true:
		emit_signal("defense_phase_signal")
		end_phase()
	else:
		end_turn()
		new_turn()
		attack_phase()

###########################################################################
#                             TURN MANAGEMENT                             #
###########################################################################

func update_max_hand_size():
	new_hand_max_size = START_HAND_SIZE #To be adapt based on skill cards effect
	return new_hand_max_size

func new_turn():
	deck_pile_ref.new_turn(update_max_hand_size())
	nb_turn += 1
	$"../UserInterface/TurnLabel".text = "Turn " + str(nb_turn)

func end_turn():
	player_hand_ref.discard_hand()

###########################################################################
#                            PLAYER MANAGEMENT                            #
###########################################################################

func count_player_card_in_game():
	current_player_health = deck_pile_ref.player_deck.size() + player_hand_ref.player_hand.size() + discard_pile_ref.player_discard.size()

###########################################################################
#                            DAMAGE MANAGEMENT                            #
###########################################################################

#func attack_phase_calculator(attack_card, opponent):
	#pass
#
#func defense_phase_calculator(defense_effect, attacker, base_damage):
	#pass

###########################################################################
#                            PHASES MANAGEMENT                            #
###########################################################################

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
