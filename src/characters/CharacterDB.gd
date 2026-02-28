extends Node
# 角色数据库

var npcs: Dictionary = {}
var player_data: Dictionary = {}

func _ready():
	load_characters()

func load_characters():
	# 加载NPC数据
	var file = FileAccess.open("res://src/data/characters/npc_data.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(content)
		if parsed and parsed.has("npcs"):
			for npc in parsed.npcs:
				npcs[npc.id] = npc
			print("加载了 ", npcs.size(), " 个NPC")

func get_npc(id: String) -> CharacterData:
	if not npcs.has(id):
		return null
	
	var data = npcs[id]
	var character = CharacterData.new()
	character.id = data.id
	character.name = data.name
	character.title = data.get("title", "")
	character.avatar = data.get("avatar", "")
	character.alcohol_capacity = data.attributes.get("alcohol_capacity", 10)
	character.max_alcohol = character.alcohol_capacity
	character.decisiveness = data.attributes.get("decisiveness", "依赖型")
	character.courage = data.attributes.get("courage", "均衡")
	character.ai_type = data.get("ai_type", "引导型")
	return character

func create_player() -> CharacterData:
	var player = CharacterData.new()
	player.id = "player"
	player.name = "玩家"
	player.is_player = true
	
	# 从存档读取属性
	var attrs = SaveManager.current_save.get("player_attributes", {})
	player.alcohol_capacity = attrs.get("alcohol_capacity", 20)
	player.max_alcohol = 999
	return player
