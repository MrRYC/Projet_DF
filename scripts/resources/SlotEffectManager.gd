extends Node
class_name SlotEffectRegistry

static func apply(effect: Dictionary, player) -> void:
	var id: String = str(effect.get("id", ""))
	match id:
		"Block":
			player.defense_controller.add_block(int(effect.get("value", 0)))
			player.update_player_pips_block()
		"Dodge":
			player.defense_controller.add_block(int(effect.get("value", 0)))
		"Feint":
			print("Feinte executée")
		_:
			push_warning("Effet inconnu: %s" % id)
