extends Node
# 卡牌效果执行器 - 全局单例

const CharacterData = preload("res://src/characters/CharacterData.gd")
const CardData = preload("res://src/cards/CardData.gd")

signal effect_executed(card_type, result)

func _ready():
	print("CardExecutor 初始化")

func execute(card, executor, participants: Array):
	print("执行卡牌: ", card.name, " 类型: ", card.type)
	
	match card.type:
		"指定牌":
			return execute_target_card(card, executor, participants)
		"合饮牌":
			return execute_together_card(card, executor, participants)
		"升级牌":
			return execute_upgrade_card(card, executor)
		"定位牌":
			return execute_position_card(card, executor, participants)
		"厕所牌":
			return execute_toilet_card(card, executor)
		"定饮牌":
			return execute_set_drink_card(card, executor)
		"猜谜牌":
			return execute_quiz_card(card, executor, participants)
		"痛饮牌":
			return execute_group_drink_card(card, executor, participants)
		"随机牌":
			return execute_random_card(card, executor, participants)
		"9王牌":
			return execute_joker_card(card, executor)
		_:
			print("未知卡牌类型: ", card.type)
			return null

func execute_target_card(card, executor, participants: Array):
	var targets = participants.filter(func(p): return p != executor and not p.is_drunk())
	if targets.is_empty():
		return null
	var target = targets[randi() % targets.size()]
	var damage = GameManager.calculate_alcohol_damage(GameManager.current_cups)
	target.drink(damage)
	print(target.name, "喝了", damage, "酒量")
	EventBus.alcohol_changed.emit(target.id, target.alcohol_capacity, target.max_alcohol)
	return {"type": "drink", "target": target.id, "target_name": target.name, "amount": damage}

func execute_together_card(card, executor, participants: Array):
	var targets = participants.filter(func(p): return p != executor and not p.is_drunk())
	if targets.is_empty():
		return null
	var target = targets[randi() % targets.size()]
	var half_cups = max(1, GameManager.current_cups / 2)
	var damage = GameManager.calculate_alcohol_damage(half_cups)
	
	executor.drink(damage)
	target.drink(damage)
	
	if not executor.is_player and target.is_player:
		executor.change_favorability(5)
		EventBus.favorability_changed.emit(executor.id, executor.favorability)
	elif executor.is_player and not target.is_player:
		target.change_favorability(5)
		EventBus.favorability_changed.emit(target.id, target.favorability)
	
	return {"type": "together", "target": target.name, "amount": damage}

func execute_upgrade_card(card, executor):
	GameManager.set_alcohol_type(card.suit)
	return {"type": "upgrade", "suit": card.suit, "alcohol_type": GameManager.alcohol_names.get(GameManager.current_alcohol_type)}

func execute_position_card(card, executor, participants: Array):
	if participants.is_empty():
		return null
	var target = participants[randi() % participants.size()]
	var damage = GameManager.calculate_alcohol_damage(GameManager.current_cups)
	target.drink(damage)
	return {"type": "position", "target": target.name, "amount": damage}

func execute_toilet_card(card, executor):
	executor.alcohol_capacity = int(executor.alcohol_capacity / 2)
	EventBus.alcohol_changed.emit(executor.id, executor.alcohol_capacity, executor.max_alcohol)
	return {"type": "toilet", "halved": true}

func execute_set_drink_card(card, executor):
	var damage = GameManager.calculate_alcohol_damage(1)
	executor.drink(damage)
	GameManager.current_cups = min(GameManager.current_cups + 1, 6)
	return {"type": "set_drink", "self_damage": damage, "new_cups": GameManager.current_cups}

func execute_quiz_card(card, executor, participants: Array):
	if randf() > 0.5:
		var damage = GameManager.calculate_alcohol_damage(GameManager.current_cups)
		executor.drink(damage)
		return {"type": "quiz", "drinker": executor.name, "correct": false}
	else:
		if not executor.is_player:
			executor.change_favorability(10)
			EventBus.favorability_changed.emit(executor.id, executor.favorability)
		return {"type": "quiz", "correct": true}

func execute_group_drink_card(card, executor, participants: Array):
	var alive = participants.filter(func(p): return not p.is_drunk())
	if alive.is_empty():
		return null
	var per_person = max(1, GameManager.current_cups / alive.size())
	var damage = GameManager.calculate_alcohol_damage(per_person)
	
	for p in alive:
		p.drink(damage)
		EventBus.alcohol_changed.emit(p.id, p.alcohol_capacity, p.max_alcohol)
	
	for p in alive:
		if not p.is_player:
			p.change_favorability(2)
	
	return {"type": "group", "amount": damage, "targets": alive.size()}

func execute_random_card(card, executor, participants: Array):
	var dice = randi() % 6 + 1
	var targets = participants.filter(func(p): return not p.is_drunk())
	if targets.is_empty():
		return null
	var target = targets[randi() % targets.size()]
	var damage = GameManager.calculate_alcohol_damage(dice)
	target.drink(damage)
	return {"type": "random", "dice": dice, "target": target.name, "amount": damage}

func execute_joker_card(card, executor):
	return {"type": "joker", "joker_name": executor.name}
