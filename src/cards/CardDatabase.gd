extends Node
# 卡牌数据库

var base_cards: Array[CardData] = []
var advanced_cards: Array[CardData] = []

func _ready():
	load_cards()

func load_cards():
	# 加载基础卡牌
	var base_file = FileAccess.open("res://src/data/cards/base_cards.json", FileAccess.READ)
	if base_file:
		var content = base_file.get_as_text()
		base_file.close()
		var parsed = JSON.parse_string(content)
		if parsed and parsed.has("cards"):
			for card_data in parsed.cards:
				var card = CardData.new()
				card.id = card_data.get("id", "")
				card.name = card_data.get("name", "")
				card.suit = card_data.get("suit", "")
				card.rank = str(card_data.get("rank", ""))
				card.type = card_data.get("type", "")
				card.effect = card_data.get("effect", "")
				card.effect_type = card_data.get("effect_type", "")
				card.interaction = card_data.get("interaction", "")
				card.target = card_data.get("target", "")
				card.keepable = card_data.get("keepable", false)
				card.dice = card_data.get("dice", false)
				card.quiz = card_data.get("quiz", false)
				card.dialog = card_data.get("dialog", false)
				card.coefficient = card_data.get("coefficient", 1.0)
				card.alcohol_type = card_data.get("alcohol_type", "")
				card.position = card_data.get("position", "")
				card.can_set_cups = card_data.get("can_set_cups", false)
				card.self_drink = card_data.get("self_drink", false)
				base_cards.append(card)
			print("加载了 ", base_cards.size(), " 张基础卡牌")
	
	# 加载进阶卡牌
	var adv_file = FileAccess.open("res://src/data/cards/advanced_cards.json", FileAccess.READ)
	if adv_file:
		var content = adv_file.get_as_text()
		adv_file.close()
		var parsed = JSON.parse_string(content)
		if parsed and parsed.has("cards"):
			for card_data in parsed.cards:
				var card = CardData.new()
				card.id = card_data.get("id", "")
				card.name = card_data.get("name", "")
				card.suit = card_data.get("suit", "")
				card.rank = str(card_data.get("rank", ""))
				card.type = card_data.get("type", "")
				card.effect = card_data.get("effect", "")
				card.effect_type = card_data.get("effect_type", "")
				advanced_cards.append(card)
			print("加载了 ", advanced_cards.size(), " 张进阶卡牌")

func get_base_cards() -> Array[CardData]:
	return base_cards.duplicate()

func get_card_by_id(id: String) -> CardData:
	for card in base_cards:
		if card.id == id:
			return card
	for card in advanced_cards:
		if card.id == id:
			return card
	return null
