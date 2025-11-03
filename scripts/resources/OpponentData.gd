extends Resource
class_name OPPONENT_DATA

#Variables de la ressource
@export var display_name: String
@export var max_hp: int
@export var sprite: Texture2D
@export var attack_damage: int

#Gestion du timing d'attaque
enum behaviors { ATTACK_AT_THE_END, ATTACK_AT_THRESHOLD } # 0 = Attaque à la fin du tour, 1 = Attaque après x cartes jouées
@export var behavior_type : behaviors
@export var cards_threshold: int
@export var attack_performed: bool = false
