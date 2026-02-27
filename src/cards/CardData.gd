extends Resource
class_name CardData

@export var id: String
@export var name: String
@export var suit: String
@export var rank: String
@export var type: String
@export var effect: String
@export var effect_type: String
@export var interaction: String
@export var count: int = 1

# 特殊字段
@export var target: String = ""
@export var keepable: bool = false
@export var dice: bool = false
@export var quiz: bool = false
@export var dialog: bool = false
@export var coefficient: float = 1.0
@export var alcohol_type: String = ""
@export var position: String = ""
@export var can_set_cups: bool = false
@export var self_drink: bool = false

func _init(p_id = "", p_name = "", p_suit = "", p_rank = "", p_type = "", p_effect = ""):
	id = p_id
	name = p_name
	suit = p_suit
	rank = p_rank
	type = p_type
	effect = p_effect
