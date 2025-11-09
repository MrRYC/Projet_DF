extends Node2D
class_name OPPONENT

var data: OPPONENT_DATA
var current_hp : int
var extra_damage : int = 0
var cards_played_counter: int = 0
var attack_order : int = 0
var attack_order_copy : int = 0
var action_type
var action_performed = true
var block : int = 0
var cancel_combo : bool = false

func init_from_data(d: OPPONENT_DATA):
	data = d
	current_hp = d.max_hp
	$Image.texture = d.image
	update_health()

###########################################################################
#                             HEALTH MANAGEMENT                           #
###########################################################################

func take_damage(amount):
	
	if self.block != 0:
		defensive_action()
		update_intent(self.block)
	else:
		current_hp -= amount

	if current_hp < 0:
		current_hp = 0
		extra_damage += amount
		#Animation étourdi

	update_health()
	
	return extra_damage

func defensive_action():
	self.block -= 1
	
	if self.block == 0:
		#Animation block lost
		pass

func update_health():
	$HealthLabel.text = str(current_hp)

###########################################################################
#                             ACTIONS MANAGEMENT                          #
###########################################################################

func update_attack_order():
	if self.attack_order_copy == 0 :
		self.attack_order_copy = self.attack_order

	$Attack_Threshold/ThresholdLabel.text = str(self.attack_order)

func update_intent(value):
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
	if self.action_performed:
		return
	
	match self.data.action_type.keys()[self.action_type]:
		"SIMPLE_BLOCK": 
			self.block = 1
			self.action_performed = true
		"DOUBLE_BLOCK": 
			self.block = 2
			self.action_performed = true

	#Animaion block gain

func perform_action():
	match self.data.action_type.keys()[self.action_type]:
		"ATTACK":
			EventBus.ai_attack_performed.emit(self.data.damage)
			print(str(self.data.display_name)+" "+str(self.data.action_type.keys()[self.action_type])+" : "+str(self.data.damage))
			#Animation attack
		"CANCEL_COMBO":
			self.cancel_combo = true
			print(str(self.data.display_name)+" Cancel Combo activé = "+str(self.cancel_combo))
			#ANimation cancel
		"BUFF":
			print(str(self.data.display_name)+" "+str(action_type)+" activé")
			#Animation buff

###########################################################################
#                            DIMM MANAGEMENT                              #
###########################################################################

# fonctions concrètes d'application/removal du layer sombre
func apply_dim_to():
	$Image.texture = self.data.dimmed_image

func remove_dim_from():
	$Image.texture = self.data.image

###########################################################################
#                           DEATH MANAGEMENT                              #
###########################################################################

func death_check():
	if extra_damage >= self.data.overkill_limit :
		overkill_animation()
		return true
	elif current_hp == 0 :
		die()
		return true
	else:
		return false

func overkill_animation():
	print("animation overkill")
	die()

func die():
	self.queue_free() # ou animation de mort
