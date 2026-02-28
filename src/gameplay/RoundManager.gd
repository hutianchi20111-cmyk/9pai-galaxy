extends Node
# 回合管理器 - 全局单例

const CharacterData = preload("res://src/characters/CharacterData.gd")

var participants: Array = []
var current_turn_index: int = 0
var current_round: int = 0

signal round_started(round_num)
signal turn_started(character)
signal turn_ended(character)
signal all_participants_set

func _ready():
	print("RoundManager 初始化")

func reset():
	participants.clear()
	current_turn_index = 0
	current_round = 0

func setup_participants(level_id: int):
	reset()
	
	# 添加玩家
	var player = CharacterData.new()
	player.id = "player"
	player.name = "玩家"
	player.is_player = true
	player.alcohol_capacity = 20
	player.max_alcohol = 20
	participants.append(player)
	
	# 添加NPC
	participants.append(create_npc("npc_a", "NPC A", 12))
	participants.append(create_npc("npc_b", "NPC B", 10))
	participants.append(create_npc("npc_c", "NPC C", 11))
	
	current_turn_index = 0
	current_round = 0
	
	all_participants_set.emit()
	print("设置参与者：", participants.size(), "人")

func create_npc(id: String, name: String, alcohol: int):
	var npc = CharacterData.new()
	npc.id = id
	npc.name = name
	npc.alcohol_capacity = alcohol
	npc.max_alcohol = alcohol
	npc.decisiveness = ["依赖型", "好奇型", "挑战型", "随机型"][randi() % 4]
	npc.courage = ["激进", "均衡", "保守", "投机"][randi() % 4]
	return npc

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
	print("轮到: ", character.name, " (", "玩家" if character.is_player else "NPC", ")")

func end_turn():
	if participants.is_empty():
		return
	
	var character = participants[current_turn_index]
	turn_ended.emit(character)
	
	current_turn_index += 1
	
	if current_turn_index >= participants.size():
		if check_anyone_drunk():
			return
		start_round()
	else:
		start_turn()

func check_anyone_drunk() -> bool:
	for p in participants:
		if p.is_drunk():
			print(p.name, " 喝醉了！游戏结束")
			EventBus.character_drunk.emit(p.id)
			return true
	return false

func get_current_character():
	if participants.is_empty():
		return null
	return participants[current_turn_index]

func get_alive_participants() -> Array:
	return participants.filter(func(p): return not p.is_drunk())
