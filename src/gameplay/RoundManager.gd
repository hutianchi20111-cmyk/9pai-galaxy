extends Node
# 回合管理器

var participants: Array[CharacterData] = []
var current_turn_index: int = 0
var current_round: int = 0

signal round_started(round_num)
signal turn_started(character)
signal turn_ended(character)
signal all_participants_set

func setup_participants(level_id: int):
	participants.clear()
	
	# 添加玩家
	participants.append(CharacterDB.create_player())
	
	# 根据关卡添加NPC
	match level_id:
		1:
			# 第1关：1玩家 + 1NPC（白光影）
			participants.append(CharacterDB.get_npc("bai_guang_ying"))
		2:
			# 第2关：1玩家 + 2NPC
			participants.append(CharacterDB.get_npc("character_A"))
			participants.append(CharacterDB.get_npc("bai_guang_ying"))
		_:
			# 第3关+：1玩家 + 3NPC
			participants.append(CharacterDB.get_npc("character_A"))
			participants.append(CharacterDB.get_npc("character_B"))
			participants.append(CharacterDB.get_npc("bai_guang_ying"))
	
	# 过滤掉null的NPC
	participants = participants.filter(func(p): return p != null)
	
	current_turn_index = 0
	current_round = 0
	
	all_participants_set.emit()
	print("设置参与者：", participants.size(), "人")

func start_round():
	current_round += 1
	current_turn_index = 0
	round_started.emit(current_round)
	print("===== 第", current_round, "轮开始 =====")
	start_turn()

func start_turn():
	if participants.is_empty():
		return
	
	var character = participants[current_turn_index]
	turn_started.emit(character)
	print("轮到: ", character.name)

func end_turn():
	if participants.is_empty():
		return
	
	var character = participants[current_turn_index]
	turn_ended.emit(character)
	
	current_turn_index += 1
	
	# 检查是否一轮结束
	if current_turn_index >= participants.size():
		# 一轮结束，检查是否有人喝醉
		if check_anyone_drunk():
			return
		# 开始新一轮
		start_round()
	else:
		# 下一个角色
		start_turn()

func check_anyone_drunk() -> bool:
	for p in participants:
		if p.is_drunk():
			print(p.name, " 喝醉了！游戏结束")
			EventBus.character_drunk.emit(p.id)
			return true
	return false

func get_current_character() -> CharacterData:
	if participants.is_empty():
		return null
	return participants[current_turn_index]

func get_alive_participants() -> Array[CharacterData]:
	return participants.filter(func(p): return not p.is_drunk())
