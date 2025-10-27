extends Node2D
class_name CARD

#variables du script
var slots: Array = []             # définitions de slots (depuis CardDB)
var state: Dictionary = {}        # état persistant propre à cette carte (counters/flags)
var slot_uses: Dictionary = {}    # suivi usages par slot_id

var starting_position #position de départ de la carte utilisée dans la funct update_hand_positions du script PlayerHand
enum card_area { IN_DECK, IN_HAND, IN_ACTION_ZONE, IN_DISCARD, IN_WOUND, IN_EXHAUST } # 0 = IN_DECK, 1 = IN_HAND, 2 = IN_ACTION_ZONE, 3 = IN_DISCARD, 4 = IN_WOUND, 5 = IN_EXHAUST
var card_current_area : card_area = card_area.IN_DECK

var id : String
var animation_time : float
var attack : int
var reach : String #single or multi target
var target #retourne ennemi ciblé
var is_flipped = false

###########################################################################
#                          CARD CONFIGURATION                             #
###########################################################################

func setup_card(data: Dictionary):
	if data.has("title"):
		$Name.text = data["title"]
		
	if data.has("animation_time"):
		animation_time = data["animation_time"]
		$Time.text = str(data["animation_time"])
		
	if data.has("attack"):
		attack = data["attack"] 
		$Attack.text = str(data["attack"])
		
	if data.has("reach"):
		reach = data["reach"]
		
	if data.has("slots"):
		slots = data["slots"]
		
	if data.has("state_init"):
		# Copie pour éviter mutation partagée
		state = data["state_init"].duplicate(true)
	else:
		state = {}
		
	slot_uses.clear()
	for c_slot in slots:
		if c_slot.has("id") and c_slot.has("uses"):
			slot_uses[c_slot["id"]] = int(c_slot["uses"])

#func verify_condition(context:Dictionary) -> bool:
	## Exemple: coût en endurance / autres checks.
	## Tu peux réutiliser ton système existant (ne rien casser).
	#return true

###########################################################################
#                               CARD USAGE                                #
###########################################################################

func resolve_card(context:Dictionary) -> void:
	for c_slot in slots:
		if ! _slot_is_usable(c_slot): 
			continue
		if not _conditions_ok(c_slot, context):
			continue
		_apply_slot_effects(c_slot, context)
		_apply_slot_side_effects(c_slot, context)

	emit_signal("card_effect_applied", self, context)

func _slot_is_usable(c_slot: Dictionary) -> bool:
	if c_slot.has("id") and slot_uses.has(c_slot["id"]):
		return slot_uses[c_slot["id"]] > 0
	return true

func _conditions_ok(c_slot: Dictionary, context: Dictionary) -> bool:
	if !c_slot.has("conditions"):
		return true
	for cond in c_slot["conditions"]:
		if !_check_condition(cond, context):
			return false
	return true

func _check_condition(cond: Dictionary, context: Dictionary) -> bool:
	var fn: String = str(cond.get("fn", ""))
	match fn:
		"owner_endurance_at_least":
			var need := int(cond.get("value", 0))
			var owner_endurance := int(context.get("owner_endurance", 0))
			return owner_endurance >= need
		# ajoute ici d’autres conditions utiles
		_:
			return true

func _apply_slot_effects(c_slot: Dictionary, context: Dictionary) -> void:
	if !c_slot.has("effects"):
		return
	for effect in c_slot["effects"]:
		_apply_effect_fn(effect, context)

func _apply_slot_side_effects(c_slot: Dictionary, context: Dictionary) -> void:
	if c_slot.has("id") and slot_uses.has(c_slot["id"]):
		slot_uses[c_slot["id"]] = max(0, slot_uses[c_slot["id"]] - 1)
	if c_slot.has("side_effects"):
		for effect in c_slot["side_effects"]:
			_apply_effect_fn(effect, context)

func _apply_effect_fn(effect: Dictionary, context: Dictionary) -> void:
	var fn: String = str(effect.get("fn", ""))
	match fn:
		# --------- Effets positifs
		"add_attack":
			var v := int(effect.get("value", 0))
			context["attack_bonus"] = int(context.get("attack_bonus", 0)) + v
		"apply_status":
			var status := str(effect.get("status", ""))
			var stacks := int(effect.get("stacks", 1))
			if !context.has("statuses"):
				context["statuses"] = {}
			context["statuses"][status] = int(context["statuses"].get(status, 0)) + stacks

		# --------- Effets secondaires / coûts
		"exhaust_after_use":
			emit_signal("card_exhaust_requested", self)
		"discard_after_use":
			emit_signal("card_discard_requested", self)
		"decrement_counter":
			var key := str(effect.get("counter", ""))
			var minv := int(effect.get("min", 0))
			if key != "":
				state[key] = max(minv, int(state.get(key, 0)) - 1)

		# Ajoute ici d’autres “fn” (perte d’endurance, self debuff, etc.)
		_:
			pass

# Optionnel: reset en début de tour (si besoin)
func on_turn_start() -> void:
	# Ex: reset d’un flag temporaire
	pass

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_area_2d_mouse_entered() -> void:
	EventBus.hovered.emit(self)

func _on_area_2d_mouse_exited() -> void:
	EventBus.hovered_off.emit(self)
