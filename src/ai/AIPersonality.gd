extends Node
# AI性格系统

enum AIType { GUIDE, STEADY, AGGRESSIVE, CONTROL }

var ai_type: AIType
var character: CharacterData

func _init(p_type: AIType, p_character: CharacterData):
	ai_type = p_type
	character = p_character

func modify_decision(base_decision: String) -> String:
	# 根据AI类型修改决策
	match ai_type:
		AIType.GUIDE:
			# 引导型：放水，确保玩家通关
			return _guide_behavior(base_decision)
		AIType.STEADY:
			# 稳健型：优先保证生存
			return _steady_behavior(base_decision)
		AIType.AGGRESSIVE:
			# 激进型：追求击杀
			return _aggressive_behavior(base_decision)
		AIType.CONTROL:
			# 控制型：打断玩家
			return _control_behavior(base_decision)
		_:
			return base_decision

func _guide_behavior(decision: String) -> String:
	# 引导型AI：玩家血量低时降低攻击
	var player = _get_player()
	if player and player.get_alcohol_percent() < 0.3:
		# 故意抽低伤害牌或选择低杯数
		print(character.name, "(引导型): 玩家血量低，降低攻击")
	return decision

func _steady_behavior(decision: String) -> String:
	# 稳健型：血量低时使用道具或保守
	if character.get_alcohol_percent() < 0.4:
		print(character.name, "(稳健型): 血量低，保守策略")
	return decision

func _aggressive_behavior(decision: String) -> String:
	# 激进型：血量低时反而更激进
	if character.get_alcohol_percent() < 0.3:
		print(character.name, "(激进型): 血量低，死撑激进")
	return decision

func _control_behavior(decision: String) -> String:
	# 控制型：打断玩家combo（简化版）
	print(character.name, "(控制型): 控制策略")
	return decision

func _get_player() -> CharacterData:
	# 获取玩家角色
	for p in RoundManager.participants:
		if p.is_player:
			return p
	return null
