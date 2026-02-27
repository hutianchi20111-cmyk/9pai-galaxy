extends Node
# 存档管理器

const SAVE_PATH = "user://save.json"

var current_save = {
	"current_level": 1,
	"unlocked_characters": ["bai_guang_ying"],
	"player_attributes": {
		"alcohol_capacity": 20,
		"insight": 1,
		"attraction": 1
	},
	"npc_favorability": {},
	"story_keys": [],
	"unlocked_advanced_cards": []
}

func _ready():
	load_game()

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(current_save))
		file.close()
		print("游戏已保存")

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(content)
			if parsed:
				current_save = parsed
				print("存档已加载")

func get_current_level() -> int:
	return current_save.current_level

func set_current_level(level: int):
	current_save.current_level = level
	save_game()

func unlock_character(character_id: String):
	if not current_save.unlocked_characters.has(character_id):
		current_save.unlocked_characters.append(character_id)
		save_game()

func is_character_unlocked(character_id: String) -> bool:
	return current_save.unlocked_characters.has(character_id)
