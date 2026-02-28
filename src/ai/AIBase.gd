extends Node
class_name AIBase

var character: CharacterData
var participants: Array[CharacterData]

func _init(p_character: CharacterData, p_participants: Array[CharacterData]):
	character = p_character
	participants = p_participants

func make_decision() -> String:
	# 返回 "draw" 或 "item"
	# 简化：总是抽牌
	return "draw"

func select_target() -> CharacterData:
	# 根据决断属性选择目标
	var alive_others = participants.filter(func(p): return p != character and not p.is_drunk())
	if alive_others.is_empty():
		return null
	
	match character.decisiveness:
		"依赖型":
			# 选好感度最高的
			alive_others.sort_custom(func(a, b): return a.favorability > b.favorability)
		"好奇型":
			# 选吸引力最高的（玩家）
			for p in alive_others:
				if p.is_player:
					return p
			return alive_others[0]
		"挑战型":
			# 选酒量最高的
			alive_others.sort_custom(func(a, b): return a.alcohol_capacity > b.alcohol_capacity)
		"随机型", _:
			return alive_others[randi() % alive_others.size()]
	
	return alive_others[0]

func select_cups() -> int:
	# 根据胆量选择杯数
	var current_cups = GameManager.current_cups
	var alcohol_percent = character.get_alcohol_percent()
	
	match character.courage:
		"激进":
			# 总是加满（6杯），即使血量低也死撑
			return min(6, current_cups + 2)
		"均衡":
			# 适中，血量低时减少
			if alcohol_percent < 0.3:
				return max(1, current_cups - 1)
			return current_cups
		"保守":
			# 减半，血量低时最小
			if alcohol_percent < 0.3:
				return 1
			return max(1, current_cups / 2)
		"投机":
			# 根据目标血量决定
			var target = select_target()
			if target and alcohol_percent < 0.3:
				if target.get_alcohol_percent() < 0.3:
					return min(6, current_cups + 2)  # 目标也低，加满
				else:
					return max(1, current_cups - 1)  # 保守
			return current_cups
		_:
			return current_cups

func should_use_item() -> bool:
	# 判断是否应该使用道具
	var alcohol_percent = character.get_alcohol_percent()
	
	# 血量危险时优先使用防御道具
	if alcohol_percent < 0.3:
		return true
	
	# 有高伤害道具且目标血量低时使用
	var target = select_target()
	if target and target.get_alcohol_percent() < 0.3:
		return true
	
	return false
