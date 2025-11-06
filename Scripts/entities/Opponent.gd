extends Node2D
class_name OPPONENT

var data: OPPONENT_DATA
var current_hp : int
var extra_damage : int = 0
var cards_played_counter: int = 0
var action
var action_performed = true
var block : int = 0
var cancel_combo : bool = false

func init_from_data(d: OPPONENT_DATA):
	data = d
	current_hp = d.max_hp
	$Sprite2D.texture = d.sprite
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

func update_intent(value):
	if value == 0:
		$Intent.text = str(self.data.action_type.keys()[self.action])
	else:
		$Intent.text = str(self.data.action_type.keys()[self.action])+" : "+str(value)

func on_player_card_played():
	cards_played_counter += 1
	
	if cards_played_counter == self.data.attack_threshold:
		#Animation de l'ennemi prêt
		pass
	elif cards_played_counter < self.data.attack_threshold:
		#Animation idle
		return

func set_defensive_action():
	if self.action_performed:
		return
	
	match self.data.action_type.keys()[self.action]:
		"SIMPLE_BLOCK": 
			self.block = 1
			self.action_performed = true
		"DOUBLE_BLOCK": 
			self.block = 2
			self.action_performed = true

	#Animaion block gain

func perform_action():
	match self.data.action_type.keys()[self.action]:
		"ATTACK":
			EventBus.ai_attack_performed.emit(self.data.damage)
			print(str(self.data.display_name)+" "+str(self.data.action_type.keys()[self.action])+" : "+str(self.data.damage))
			#Animation attack
		"CANCEL_COMBO":
			self.cancel_combo = true
			print(str(self.data.display_name)+" Cancel Combo activé = "+str(self.cancel_combo))
			#ANimation cancel
		"BUFF":
			print(str(self.data.display_name)+" "+str(action)+" activé")
			#Animation buff

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
	queue_free() # ou animation de mort
