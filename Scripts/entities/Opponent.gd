extends Node2D
class_name OPPONENT

#variables du script
var defense_controller: DefenseController
var data: OPPONENT_DATA
var current_hp: int = 0
var extra_damage: int = 0
var cards_played_counter: int = 0
var attack_order: int = 0
var attack_order_copy: int = 0
var action_type
var is_action_performed: bool = true
var is_dead: bool = false
var preview_block_reserved: int = 0
var preview_hp_damage: int = 0

func init_from_data(d: OPPONENT_DATA) -> void:
	data = d
	current_hp = d.max_hp
	$Image.texture = d.image
	update_health()

	defense_controller = $DefensiveActionsController

###########################################################################
#                             HEALTH MANAGEMENT                           #
###########################################################################

func take_damage(amount) -> int:
	if defense_controller.try_to_block():
		check_block()
		update_intent(defense_controller.get_block())
		return 0

	current_hp -= amount
	EventBus.combo_meter_increased.emit()
	
	if current_hp <= 0:
		is_dead = true
		extra_damage = current_hp*-1
		#Animation étourdi

	update_health()
	return extra_damage

func check_block() -> void:
	if defense_controller.get_block() == 0:
		# Animation block lost (last charge consumed)
		pass

###########################################################################
#                             ACTIONS MANAGEMENT                          #
###########################################################################

func update_attack_order() -> void:
	if self.attack_order_copy == 0 :
		self.attack_order_copy = self.attack_order

	$Attack_Threshold/ThresholdLabel.text = str(self.attack_order)

func update_intent(value) -> void:
	if value == 0:
		$Intent.text = str(self.data.action_type.keys()[self.action_type])
	else:
		$Intent.text = str(self.data.action_type.keys()[self.action_type])+" : "+str(value)

func on_player_card_played():
	cards_played_counter += 1
	
	if cards_played_counter == self.attack_order:
		#Animation de l'ennemi prêt
		return
	elif cards_played_counter < self.attack_order:
		#Animation idle
		return

func set_defensive_action():
	if self.is_action_performed:
		return
	
	match self.data.action_type.keys()[self.action_type]:
		"SIMPLE_BLOCK": 
			defense_controller.set_block(1)
			self.is_action_performed = true
		"DOUBLE_BLOCK": 
			defense_controller.set_block(2)
			self.is_action_performed = true
		_:
			# Intent non défensif => pas de block
			pass

	update_opponent_pips_block()
	#Animaion block gain

func perform_action() -> void:
	if is_dead:
		return
	
	match self.data.action_type.keys()[self.action_type]:
		"ATTACK":
			EventBus.ai_attack_performed.emit(self.data.damage)
			#Animation attack
		"CANCEL_COMBO":
			EventBus.ai_cancel_combo_performed.emit()
			#Animation cancel
		"BUFF":
			print(str(self.data.display_name)+" "+str(action_type)+" activé")
			#Animation buff

	self.is_action_performed = true

###########################################################################
#                              PIPS MANAGEMENT                            #
###########################################################################

func update_health() -> void:
	$HealthPips.set_health(current_hp, data.max_hp)

func set_incoming_preview(broken_blocks: int, hp_damage: int) -> void:
	$HealthPips.set_block_preview_broken(max(0, broken_blocks))
	$HealthPips.set_preview_damage(max(0, hp_damage))

func consume_damage_preview(damage: int) -> void:
	$HealthPips.consume_damage_preview(damage, defense_controller.has_block())

func update_opponent_pips_block() -> void:
	$HealthPips.set_charges(defense_controller.get_block(),defense_controller.get_dodge(),defense_controller.get_feint())

func clear_previewed_damage() -> void:
	$HealthPips.clear_previewed_damage()

###########################################################################
#                            DIMM MANAGEMENT                              #
###########################################################################

func apply_attacker_color() -> void:
	$Image.modulate = Color(1.0, 0.548, 0.495, 1.0)

func apply_player_target_color() -> void:
	$Image.modulate = Color(0.038, 0.735, 0.796, 1.0)

#Modification de l'image
func apply_dim() -> void:
	$Image.modulate = Color(0.073, 0.073, 0.073, 0.294)

func remove_dim() -> void:
	$Image.modulate = Color(1.0, 1.0, 1.0)

###########################################################################
#                           DEATH MANAGEMENT                              #
###########################################################################

func death_check() -> void:
	if extra_damage >= self.data.overkill_limit :
		overkill_animation()
	elif current_hp <= 0 :
		die()

func overkill_animation() -> void:
	print("animation overkill")
	die()

func die() -> void:
	self.queue_free() # ou animation de mort

###########################################################################
#                           NEW TURN MANAGEMENT                           #
###########################################################################
func reset_for_new_turn()-> void:
	extra_damage = 0
	cards_played_counter = 0
	is_action_performed = false
	clear_previewed_damage()
	defense_controller.reset_for_new_turn()
	$HealthPips.set_charges(0,0,0)

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################



#func _on_block_changed(_value) -> void:
	#defense_controller.get_block()
	#update_opponent_pips_block()
