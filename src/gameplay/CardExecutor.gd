extends Node
# 卡牌效果执行器

signal effect_executed(card_type, result)

func execute(card: CardData, executor: CharacterData, participants: Array[CharacterData]):
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

func execute_target_card(card: CardData, executor: CharacterData, participants: Array[CharacterData]):
	print("指定牌：", executor.name, "指定某人喝酒")
	# 简化版：随机选一个活着的其他角色
	var targets = participants.filter(func(p): return p != executor and not p.is_drunk())
	if targets.is_empty():
		return
	var target = targets[randi() % targets.size()]
	var damage = GameManager.calculate_alcohol_damage(GameManager.current_cups)
	target.drink(damage)
	print(target.name, "喝了", damage, "酒量")
	EventBus.alcohol_changed.emit(target.id, target.alcohol_capacity, target.max_alcohol)
	return {"type": "drink", "target": target.id, "amount": damage}

func execute_together_card(card: CardData, executor: CharacterData, participants: Array[CharacterData]):
	print("合饮牌：", executor.name, "邀请合饮")
	var targets = participants.filter(func(p): return p != executor and not p.is_drunk())
	if targets.is_empty():
		return
	var target = targets[randi() % targets.size()]
	var half_cups = max(1, GameManager.current_cups / 2)
	var damage = GameManager.calculate_alcohol_damage(half_cups)
	
	executor.drink(damage)
	target.drink(damage)
	
	# 提升好感度
	if not executor.is_player and target.is_player:
		executor.change_favorability(5)
		EventBus.favorability_changed.emit(executor.id, executor.favorability)
	elif executor.is_player and not target.is_player:
		target.change_favorability(5)
		EventBus.favorability_changed.emit(target.id, target.favorability)
	
	print(executor.name, "和", target.name, "各喝了", damage, "酒量")
	return {"type": "together", "target": target.id, "amount": damage}

func execute_upgrade_card(card: CardData, executor: CharacterData):
	print("升级牌：更换酒类型")
	GameManager.set_alcohol_type(card.suit)
	return {"type": "upgrade", "suit": card.suit}

func execute_position_card(card: CardData, executor: CharacterData, participants: Array[CharacterData]):
	print("定位牌：对应座位的人喝")
	# 简化：随机选一个
	if participants.is_empty():
		return
	var target = participants[randi() % participants.size()]
	var damage = GameManager.calculate_alcohol_damage(GameManager.current_cups)
	target.drink(damage)
	return {"type": "position", "target": target.id, "amount": damage}

func execute_toilet_card(card: CardData, executor: CharacterData):
	print("厕所牌：可保留，使用后酒量减半")
	# 简化：直接使用
	executor.alcohol_capacity = int(executor.alcohol_capacity / 2)
	EventBus.alcohol_changed.emit(executor.id, executor.alcohol_capacity, executor.max_alcohol)
	return {"type": "toilet", "halved": true}

func execute_set_drink_card(card: CardData, executor: CharacterData):
	print("定饮牌：自己喝一杯，然后可重新指定杯数")
	var damage = GameManager.calculate_alcohol_damage(1)
	executor.drink(damage)
	# 简化：杯数+1
	GameManager.current_cups = min(GameManager.current_cups + 1, 6)
	return {"type": "set_drink", "self_damage": damage, "new_cups": GameManager.current_cups}

func execute_quiz_card(card: CardData, executor: CharacterData, participants: Array[CharacterData]):
	print("猜谜牌：触发问答")
	# 简化版：随机决定谁喝
	if randf() > 0.5:
		var damage = GameManager.calculate_alcohol_damage(GameManager.current_cups)
		executor.drink(damage)
		return {"type": "quiz", "drinker": executor.id, "correct": false}
	else:
		# 提升好感度
		if not executor.is_player:
			executor.change_favorability(10)
			EventBus.favorability_changed.emit(executor.id, executor.favorability)
		return {"type": "quiz", "drinker": null, "correct": true}

func execute_group_drink_card(card: CardData, executor: CharacterData, participants: Array[CharacterData]):
	print("痛饮牌：所有人平分")
	var alive = participants.filter(func(p): return not p.is_drunk())
	if alive.is_empty():
		return
	var per_person = max(1, GameManager.current_cups / alive.size())
	var damage = GameManager.calculate_alcohol_damage(per_person)
	
	for p in alive:
		p.drink(damage)
		EventBus.alcohol_changed.emit(p.id, p.alcohol_capacity, p.max_alcohol)
	
	# 提升共同好感度（较低）
	for p in alive:
		if not p.is_player:
			p.change_favorability(2)
	
	return {"type": "group", "amount": damage, "targets": alive.size()}

func execute_random_card(card: CardData, executor: CharacterData, participants: Array[CharacterData]):
	print("随机牌：投骰子")
	var dice = randi() % 6 + 1
	var targets = participants.filter(func(p): return not p.is_drunk())
	if targets.is_empty():
		return
	var target = targets[randi() % targets.size()]
	var damage = GameManager.calculate_alcohol_damage(dice)
	target.drink(damage)
	return {"type": "random", "dice": dice, "target": target.id, "amount": damage}

func execute_joker_card(card: CardData, executor: CharacterData):
	print("9王牌：", executor.name, "成为9王")
	return {"type": "joker", "joker_id": executor.id}
