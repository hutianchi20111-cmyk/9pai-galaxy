extends Node
# 道具牌系统

class_name ItemSystem

# 玩家持有的道具牌
var player_items: Array[Dictionary] = []

# 道具牌定义
const ITEM_CARDS = {
	"toilet": {
		"name": "厕所牌",
		"description": "使用后累积的酒量值减半",
		"effect": "halve_alcohol",
		"icon": "🚻"
	}
}

func add_item(item_id: String):
	if ITEM_CARDS.has(item_id):
		player_items.append({
			"id": item_id,
			"data": ITEM_CARDS[item_id]
		})
		print("获得道具: ", ITEM_CARDS[item_id].name)

func use_item(item_index: int, character: CharacterData) -> bool:
	if item_index < 0 or item_index >= player_items.size():
		return false
	
	var item = player_items[item_index]
	var item_id = item.id
	
	match item_id:
		"toilet":
			# 厕所牌：酒量减半
			character.alcohol_capacity = int(character.alcohol_capacity / 2)
			EventBus.alcohol_changed.emit(character.id, character.alcohol_capacity, character.max_alcohol)
			print(character.name, "使用厕所牌，酒量减半")
		_:
			return false
	
	# 移除使用的道具
	player_items.remove_at(item_index)
	return true

func get_items() -> Array[Dictionary]:
	return player_items.duplicate()

func has_items() -> bool:
	return not player_items.is_empty()
