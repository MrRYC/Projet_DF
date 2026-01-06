extends Node
class_name SlotEffectRegistry

static func apply(effect: Dictionary, player) -> void:
	var id: String = str(effect.get("id", ""))
	match id:
		"Block":
			player.block += int(effect.get("value", 0))
		"Dodge":
			player.dodge += int(effect.get("value", 0))
		"Feint":
			print("Feinte executée")
		_:
			push_warning("Effet inconnu: %s" % id)
