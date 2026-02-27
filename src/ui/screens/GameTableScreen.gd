extends Control

# 游戏桌主界面

@onready var character_panels = $CharacterPanels.get_children()
@onready var card_grid = $CardGrid
@onready var draw_button = $DrawButton
@onready var item_button = $ItemButton
@onready var confirm_button = $ConfirmButton
@onready var cups_label = $CupsLabel
@onready var alcohol_label = $AlcoholLabel
@onready var round_label = $RoundLabel

var nine_cards: Array[CardData] = []
var current_joker: String = ""
var is_revealed = false

func _ready():
	draw_button.pressed.connect(_on_draw_pressed)
	item_button.pressed.connect(_on_item_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	confirm_button.visible = false
	
	setup_characters()
	setup_nine_cards()
	update_ui()
	
	EventBus.round_started.connect(_on_round_started)

func setup_characters():
	# 设置4个角色面板（简化版）
	var participant_names = ["NPC A", "NPC B", "玩家", "NPC C"]
	for i in range(min(character_panels.size(), participant_names.size())):
		var panel = character_panels[i]
		var name_label = panel.get_node_or_null("NameLabel")
		if name_label:
			name_label.text = participant_names[i]

func setup_nine_cards():
	# 生成9张牌
	nine_cards.clear()
	
	# 从基础牌中随机选9张
	var all_cards = CardDatabase.get_base_cards()
	all_cards.shuffle()
	
	for i in range(min(9, all_cards.size())):
		nine_cards.append(all_cards[i])
	
	# 创建卡牌按钮
	for i in range(9):
		var btn = Button.new()
		btn.name = "Card%d" % i
		btn.custom_minimum_size = Vector2(120, 160)
		btn.disabled = true
		
		if i < nine_cards.size():
			var card = nine_cards[i]
			btn.text = "%s\n%s" % [card.name, card.suit]
			btn.set_meta("card_index", i)
			btn.set_meta("card_id", card.id)
		
		card_grid.add_child(btn)
	
	# 显示翻开状态
	is_revealed = true
	confirm_button.visible = true
	draw_button.disabled = true
	item_button.disabled = true
	
	EventBus.nine_cards_revealed.emit(nine_cards)

func update_ui():
	cups_label.text = "当前杯数: %d杯" % GameManager.current_cups
	alcohol_label.text = "酒类型: %s" % GameManager.alcohol_names.get(GameManager.current_alcohol_type, "基础款")
	round_label.text = "回合: %d" % GameManager.game_round

func _on_confirm_pressed():
	# 翻面打乱
	is_revealed = false
	confirm_button.visible = false
	draw_button.disabled = false
	item_button.disabled = false
	
	# 打乱牌面显示
	for btn in card_grid.get_children():
		btn.text = "???"
		btn.disabled = false
		btn.pressed.connect(_on_card_clicked.bind(btn))
	
	nine_cards.shuffle()
	EventBus.nine_cards_shuffled.emit()
	print("9张牌已翻面打乱")

func _on_card_clicked(btn):
	var index = btn.get_meta("card_index", -1)
	if index >= 0 and index < nine_cards.size():
		var card = nine_cards[index]
		print("抽到牌: ", card.name)
		
		# 显示抽到的牌
		btn.text = "%s\n%s" % [card.name, card.suit]
		btn.disabled = true
		
		# 执行卡牌效果
		execute_card_effect(card)
		
		EventBus.card_drawn.emit(card)

func execute_card_effect(card: CardData):
	match card.type:
		"指定牌":
			print("指定牌效果：指定他人喝酒")
		"合饮牌":
			print("合饮牌效果：合饮")
		"升级牌":
			GameManager.set_alcohol_type(card.suit)
			update_ui()
			print("升级酒类型为: ", card.alcohol_type)
		"定位牌":
			print("定位牌效果：对应座位的人喝")
		"厕所牌":
			print("厕所牌：可保留道具")
		"定饮牌":
			print("定饮牌：自己喝并重新指定杯数")
		"猜谜牌":
			print("猜谜牌：触发剧情")
		"痛饮牌":
			print("痛饮牌：所有人平分")
		"随机牌":
			print("随机牌：投骰子")
		"9王牌":
			current_joker = card.id
			print("成为9王")

func _on_draw_pressed():
	print("选择抽牌")

func _on_item_pressed():
	print("选择使用道具牌")

func _on_round_started(round_num: int):
	update_ui()
