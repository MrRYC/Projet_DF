extends Node 

const max_value : float = 12.0

@onready var ring_progress_bar : TextureProgressBar = $ActionTimer
@onready var timer = $ActionTimer/FightingTimer
@onready var timer_label = $ActionTimer/TimerLabel

var timer_new_max_value : float = max_value
var combo_meter : int = 0
var multiplicator : float = 0.0

func _ready() -> void:
	EventBus.turn_increased.connect(_on_turn_increased)
	EventBus.processing.connect(_on_processing)
	EventBus.activate_action_timer.connect(_on_action_time)
	EventBus.combo_meter_cancelled.connect(_on_combo_meter_cancelled)
	EventBus.combo_meter_increased.connect(_on_combo_meter_increased)
	EventBus.combo_meter_altered.connect(_on_combo_meter_altered)

	timer.timeout.connect(_on_action_timer_timeout)

	_on_action_button_pressed() 

func _process(_delta: float) -> void:
	if timer.time_left > 0:
		update_action_ui()

###########################################################################
#                         ACTION TIMER MANAGEMENT                         #
###########################################################################

func update_max_timer_value(new_value : float):
	if new_value == max_value:
		timer_new_max_value = new_value
	else:
		timer_new_max_value = new_value

func update_action_ui():
	var time = timer.time_left
	var seconds = int(time)
	var milliseconds = round(int((time - seconds) * 100))
	ring_progress_bar.value = time
	timer_label.text = "%02d : %02d" % [seconds, milliseconds]

###########################################################################
#                         COMBO METER MANAGEMENT                         #
###########################################################################

func update_combo_meter():
	$ComboMeter.text = str(combo_meter)

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_turn_increased(turn):
	$TurnLabel.text = str("Turn ",turn)

func _on_processing(processing):
	if processing:
		$ActionButton.disabled = true
		$EmptyActionZoneButton.disabled = true
	else:
		$ActionButton.disabled = false
		$EmptyActionZoneButton.disabled = false

func _on_action_time():
	ring_progress_bar.texture_under = load("res://assets/resources/ui/timer_ring_black.png")
	timer_label.text = str(timer_new_max_value)
	ring_progress_bar.max_value = timer_new_max_value
	timer.wait_time = timer_new_max_value
	timer.start()
	$EmptyActionZoneButton.disabled = false
	EventBus.action_timer_timeout.emit(false)
	
func _on_action_timer_timeout():
	ring_progress_bar.texture_under = load("res://assets/resources/ui/timer_ring_red.png")
	timer_label.text = "Fight"
	timer.stop()
	$EmptyActionZoneButton.disabled = true
	EventBus.action_timer_timeout.emit(true)

func _on_action_button_pressed() -> void:
	timer_label.text = str(int(timer_new_max_value)," : 00")
	ring_progress_bar.texture_under = load("res://assets/resources/ui/timer_ring_blue.png")
	timer.stop()
	$EmptyActionZoneButton.disabled = true
	EventBus.action_timer_timeout.emit(true)

func _on_combo_meter_cancelled():
	combo_meter = 0
	update_combo_meter()
	
func _on_combo_meter_increased():
	combo_meter += 1
	update_combo_meter()

func _on_combo_meter_altered(_value):
	pass
