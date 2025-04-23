extends Node2D

const ARC_POINTS = 8

@onready var area_2d : Area2D = $Area2D
@onready var card_arc : Line2D = $CanvasLayer/CardArc

var current_card
var targeting : bool = false

#func _ready() -> void:
	#Events.c
