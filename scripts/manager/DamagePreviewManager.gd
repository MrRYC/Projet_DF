extends Node
class_name DamagePreviewManager

@onready var player: PLAYER = $".."
@onready var player_hand: Node2D = $"../../PlayerHand"

var incoming_hits: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.player_incoming_hits_updated.connect(_on_incoming_hits)


###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_incoming_hits(hits:Array)-> void:
	incoming_hits = hits #a voir si utile
	EventBus.card_preview_hits_requested.emit(hits.size())
	
	#provisoire
	var t : int = 0
	for h in incoming_hits:
		t += h["damage"]
	
	player.update_preview(t)
