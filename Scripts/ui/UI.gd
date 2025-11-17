extends Node 

const max_value : float = 12.0

@onready var ring_progress_bar : TextureProgressBar = $ActionTimer
@onready var timer = $ActionTimer/FightingTimer
@onready var timer_label = $ActionTimer/TimerLabel

var combo_meter : int = 0
var multiplicator : float = 0.0

func _ready() -> void:
	EventBus.turn_increased.connect(_on_turn_increased)
	EventBus.processing.connect(_on_processing)
	EventBus.activate_action_timer.connect(_on_action_time)
	timer.timeout.connect(_on_action_timer_timeout)

	_on_action_button_pressed() 

func _process(_delta: float) -> void:
	if timer.time_left > 0:
		update_action_ui()

###########################################################################
#                         ACTION TIMER MANAGEMENT                         #
###########################################################################

func update_action_ui():
	var time = timer.time_left
	var seconds = int(time)
	var milliseconds = round(int((time - seconds) * 100))
	ring_progress_bar.value = time
	timer_label.text = "%02d : %02d" % [seconds, milliseconds]

###########################################################################
#                         COMBO METER MANAGEMENT                         #
###########################################################################

func update_combo_meter(value):
	combo_meter += value
	$ComboMeter.text = combo_meter

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
	timer_label.text = str(max_value)
	ring_progress_bar.max_value = max_value
	timer.wait_time = max_value
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
	timer_label.text = str(int(max_value)," : 00")
	ring_progress_bar.texture_under = load("res://assets/resources/ui/timer_ring_blue.png")
	timer.stop()
	$EmptyActionZoneButton.disabled = true
	EventBus.action_timer_timeout.emit(true)
