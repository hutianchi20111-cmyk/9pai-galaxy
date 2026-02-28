extends Resource
class_name CharacterData

@export var id: String
@export var name: String
@export var title: String
@export var avatar: String

# 酒量属性
@export var alcohol_capacity: int = 10
@export var max_alcohol: int = 10

# NPC专属属性
@export var favorability: int = 0
@export var decisiveness: String = "依赖型"  # 依赖型/好奇型/挑战型/随机型
@export var courage: String = "均衡"  # 激进/均衡/保守/投机

# AI类型
@export var ai_type: String = "引导型"  # 引导型/稳健型/激进型/控制型

# 是否玩家控制
@export var is_player: bool = false

func _init(p_id = "", p_name = ""):
	id = p_id
	name = p_name

func drink(amount: int) -> bool:
	alcohol_capacity -= amount
	if alcohol_capacity < 0:
		alcohol_capacity = 0
	return alcohol_capacity <= 0

func is_drunk() -> bool:
	return alcohol_capacity <= 0

func change_favorability(amount: int):
	favorability += amount

func get_alcohol_percent() -> float:
	return float(alcohol_capacity) / float(max_alcohol)
