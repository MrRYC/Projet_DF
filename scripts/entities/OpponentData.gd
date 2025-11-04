extends Resource
class_name OPPONENT_DATA

#Variables de la ressource
@export var display_name: String
@export var max_hp: int
@export var overkill_limit:int = 0
@export var sprite: Texture2D

#Gestion de l'IA
enum action_type { EMPTY, ATTACK, DEFEND, BUFF } # 0 = Attaque à la fin du tour, 1 = Attaque après x cartes jouées
@export var action_1 : action_type
@export var action_2 : action_type
@export var action_3 : action_type
@export var action_4 : action_type
var list_of_actions : Array = []
@export var damage : int

#Gestion du timing d'attaque
enum behaviors { ATTACK_AT_THE_END, ATTACK_AT_THRESHOLD } # 0 = Attaque à la fin du tour, 1 = Attaque après x cartes jouées
@export var behavior_type : behaviors
@export var attack_threshold: int
var threshold_countdown: int = 0
var attack_performed: bool = false

func init_action_list():
	list_of_actions = [action_1, action_2, action_3, action_4]
