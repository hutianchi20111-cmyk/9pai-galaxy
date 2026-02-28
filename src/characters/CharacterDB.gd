extends Node
# 角色数据库 - 全局单例

const CharacterData = preload("res://src/characters/CharacterData.gd")

var npcs: Dictionary = {}

func _ready():
	load_characters()

func load_characters():
	var file = FileAccess.open("res://src/data/characters/npc_data.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(content)
		if parsed and parsed.has("npcs"):
			for npc in parsed.npcs:
				npcs[npc.id] = npc
			print("加载了 ", npcs.size(), " 个NPC")

func create_player():
	var player = CharacterData.new()
	player.id = "player"
	player.name = "玩家"
	player.is_player = true
	player.alcohol_capacity = 20
	player.max_alcohol = 20
	return player
