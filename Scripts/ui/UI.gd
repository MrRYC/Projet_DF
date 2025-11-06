extends Node 

func _ready() -> void:
	EventBus.turn_increased.connect(_on_turn_increased)
	EventBus.processing.connect(_on_processing)

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
