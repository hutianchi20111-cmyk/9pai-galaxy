extends Control

@onready var character_panels = $CharacterPanels.get_children()
@onready var card_grid = $CardGrid
@onready var draw_button = $DrawButton
@onready var item_button = $ItemButton
@onready var confirm_button = $ConfirmButton
@onready var cups_label = $CupsLabel
@onready var alcohol_label = $AlcoholLabel
@onready var round_label = $RoundLabel
@onready var turn_label = $TurnLabel

var nine_cards: Array[CardData] = []
var card_buttons: Array[Button] = []
var current_joker: String = ""
var is_revealed = false
var is_player_turn = false

func _ready():
	draw_button.pressed.connect(_on_draw_pressed)
	item_button.pressed.connect(_on_item_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	confirm_button.visible = false
	
	# 连接事件
	EventBus.round_started.connect(_on_round_started)
	EventBus.turn_started.connect(_on_turn_started)
	EventBus.character_drunk.connect(_on_character_drunk)
	
	setup_game()

func setup_game():
	# 设置参与者
	RoundManager.setup_participants(GameManager.current_level)
	setup_character_panels()
	setup_nine_cards()
	update_ui()
	
	# 延迟开始第一轮
	await get_tree().create_timer(0.5).timeout
	RoundManager.start_round()

func setup_character_panels():
	var participants = RoundManager.participants
	for i in range(character_panels.size()):
		var panel = character_panels[i]
		if i < participants.size():
			var character = participants[i]
			panel.get_node("NameLabel").text = character.name
			panel.get_node("AlcoholLabel").text = "酒量: %d/%d" % [character.alcohol_capacity, character.max_alcohol]
			panel.show()
		else:
			panel.hide()

func setup_nine_cards():
	nine_cards.clear()
	card_buttons.clear()
	
	# 从牌库随机选9张
	var all_cards = CardDatabase.get_base_cards()
	all_cards.shuffle()
	
	for i in range(9):
		var btn = Button.new()
		btn.name = "Card%d" % i
		btn.custom_minimum_size = Vector2(120, 160)
		btn.disabled = true
		
		if i < all_cards.size():
			nine_cards.append(all_cards[i])
			var card = all_cards[i]
			btn.text = "%s\n%s" % [card.name, card.suit]
			btn.set_meta("card_index", i)
		
		card_grid.add_child(btn)
		card_buttons.append(btn)
	
	is_revealed = true
	confirm_button.visible = true
	draw_button.disabled = true
	item_button.disabled = true

func update_ui():
	cups_label.text = "当前杯数: %d杯" % GameManager.current_cups
	alcohol_label.text = "酒类型: %s" % GameManager.alcohol_names.get(GameManager.current_alcohol_type, "基础款")
	round_label.text = "回合: %d" % RoundManager.current_round
	
	# 更新角色面板
	var participants = RoundManager.participants
	for i in range(min(character_panels.size(), participants.size())):
		var panel = character_panels[i]
		var character = participants[i]
		panel.get_node("AlcoholLabel").text = "酒量: %d/%d" % [character.alcohol_capacity, character.max_alcohol]
		
		# 高亮当前回合角色
		if RoundManager.get_current_character() == character:
			panel.modulate = Color(1.2, 1.2, 1.0)
		else:
			panel.modulate = Color(1.0, 1.0, 1.0)

func _on_confirm_pressed():
	is_revealed = false
	confirm_button.visible = false
	
	# 打乱显示
	for btn in card_buttons:
		btn.text = "???"
		btn.disabled = false
	
	nine_cards.shuffle()
	print("9张牌已翻面打乱")

func _on_draw_pressed():
	if not is_player_turn:
		return
	
	# 玩家选择抽牌
	draw_button.disabled = true
	item_button.disabled = true
	
	# 启用卡牌按钮
	for i in range(card_buttons.size()):
		var btn = card_buttons[i]
		if nine_cards[i] != null:
			btn.pressed.connect(_on_card_clicked.bind(i))

func _on_card_clicked(index: int):
	if index < 0 or index >= nine_cards.size():
		return
	
	var card = nine_cards[index]
	if card == null:
		return
	
	print("抽到: ", card.name)
	
	# 显示卡牌
	var btn = card_buttons[index]
	btn.text = "%s\n%s" % [card.name, card.suit]
	btn.disabled = true
	
	# 执行效果
	var executor = RoundManager.get_current_character()
	CardExecutor.execute(card, executor, RoundManager.participants)
	
	update_ui()
	
	# 延迟结束回合
	await get_tree().create_timer(1.0).timeout
	
	# 移除连接
	for button in card_buttons:
		for conn in button.get_signal_connection_list("pressed"):
			button.pressed.disconnect(conn.callable)
	
	RoundManager.end_turn()

func _on_item_pressed():
	if not is_player_turn:
		return
	print("使用道具牌（待实现）")

func _on_round_started(round_num: int):
	update_ui()

func _on_turn_started(character: CharacterData):
	turn_label.text = "当前回合: " + character.name
	update_ui()
	
	if character.is_player:
		is_player_turn = true
		draw_button.disabled = false
		item_button.disabled = false
	else:
		is_player_turn = false
		draw_button.disabled = true
		item_button.disabled = true
		# NPC自动执行
		await get_tree().create_timer(1.0).timeout
		npc_auto_play(character)

func npc_auto_play(character: CharacterData):
	# NPC简化逻辑：随机抽一张可用卡牌
	var available_indices = []
	for i in range(nine_cards.size()):
		if nine_cards[i] != null and not card_buttons[i].disabled:
			available_indices.append(i)
	
	if available_indices.is_empty():
		# 补牌
		refill_cards()
		return
	
	var random_index = available_indices[randi() % available_indices.size()]
	_on_card_clicked(random_index)

func refill_cards():
	print("补牌")
	# 简化：重置所有卡牌
	var all_cards = CardDatabase.get_base_cards()
	all_cards.shuffle()
	
	for i in range(9):
		nine_cards[i] = all_cards[i]
		card_buttons[i].text = "???"
		card_buttons[i].disabled = false

func _on_character_drunk(character_id: String):
	print("游戏结束！", character_id, "喝醉了")
	await get_tree().create_timer(2.0).timeout
	go_to_settlement()

func go_to_settlement():
	# 进入结算
	GameManager.change_state(GameManager.GameState.SETTLEMENT)
	get_tree().change_scene_to_file("res://src/ui/screens/SettlementScreen.tscn")
