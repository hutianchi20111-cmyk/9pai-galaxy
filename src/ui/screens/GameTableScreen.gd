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
@onready var item_container = $ItemContainer

var nine_cards: Array[CardData] = []
var card_buttons: Array[Button] = []
var current_joker: String = ""
var is_revealed = false
var is_player_turn = false

var item_system = ItemSystem.new()

func _ready():
	draw_button.pressed.connect(_on_draw_pressed)
	item_button.pressed.connect(_on_item_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	confirm_button.visible = false
	
	EventBus.round_started.connect(_on_round_started)
	EventBus.turn_started.connect(_on_turn_started)
	EventBus.character_drunk.connect(_on_character_drunk)
	EventBus.alcohol_changed.connect(_on_alcohol_changed)
	EventBus.favorability_changed.connect(_on_favorability_changed)
	
	setup_game()

func setup_game():
	RoundManager.setup_participants(GameManager.current_level)
	setup_character_panels()
	setup_nine_cards()
	update_ui()
	
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
			
			# 道具牌特殊标记
			if card.type == "厕所牌":
				btn.modulate = Color(0.8, 1.0, 0.8)
		
		card_grid.add_child(btn)
		card_buttons.append(btn)
	
	is_revealed = true
	confirm_button.visible = true
	draw_button.disabled = true
	item_button.disabled = true
	update_item_buttons()

func update_ui():
	cups_label.text = "当前杯数: %d杯" % GameManager.current_cups
	alcohol_label.text = "酒类型: %s" % GameManager.alcohol_names.get(GameManager.current_alcohol_type, "基础款")
	round_label.text = "回合: %d" % RoundManager.current_round

func update_item_buttons():
	# 清除旧的道具按钮
	for child in item_container.get_children():
		child.queue_free()
	
	# 显示当前道具
	var items = item_system.get_items()
	for i in range(items.size()):
		var item = items[i]
		var btn = Button.new()
		btn.text = "%s %s" % [item.data.icon, item.data.name]
		btn.pressed.connect(_on_item_used.bind(i))
		item_container.add_child(btn)
	
	item_button.disabled = items.is_empty() or not is_player_turn

func _on_confirm_pressed():
	is_revealed = false
	confirm_button.visible = false
	
	VisualEffects.play_shuffle_effect(card_grid)
	
	for btn in card_buttons:
		btn.text = "???"
		btn.disabled = false
	
	nine_cards.shuffle()
	print("9张牌已翻面打乱")

func _on_draw_pressed():
	if not is_player_turn:
		return
	
	draw_button.disabled = true
	item_button.disabled = true
	
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
	
	var btn = card_buttons[index]
	VisualEffects.play_card_draw_effect(btn)
	btn.text = "%s\n%s" % [card.name, card.suit]
	btn.disabled = true
	
	# 如果是道具牌，添加到玩家道具
	if card.type == "厕所牌":
		item_system.add_item("toilet")
		update_item_buttons()
	
	# 执行效果
	var executor = RoundManager.get_current_character()
	var result = CardExecutor.execute(card, executor, RoundManager.participants)
	
	# 显示效果反馈
	if result and result.has("type"):
		match result.type:
			"drink", "together", "position", "random":
				_show_effect_popup("%s 喝了 %d 酒量" % [result.get("target", "某人"), result.get("amount", 0)])
			"group":
				_show_effect_popup("所有人喝了 %d 酒量" % result.get("amount", 0))
			"upgrade":
				_show_effect_popup("酒类型更换为: %s" % GameManager.alcohol_names.get(GameManager.current_alcohol_type))
			"toilet":
				_show_effect_popup("酒量减半！")
	
	update_ui()
	
	await get_tree().create_timer(1.5).timeout
	
	for button in card_buttons:
		for conn in button.get_signal_connection_list("pressed"):
			button.pressed.disconnect(conn.callable)
	
	RoundManager.end_turn()

func _on_item_pressed():
	if not is_player_turn:
		return
	
	# 显示道具选择（简化：直接使用第一个）
	if item_system.has_items():
		_use_item(0)

func _on_item_used(index: int):
	_use_item(index)

func _use_item(index: int):
	var character = RoundManager.get_current_character()
	if item_system.use_item(index, character):
		update_ui()
		update_item_buttons()
		_show_effect_popup("使用道具: %s" % item_system.player_items[index].data.name if index < item_system.player_items.size() else "")
		await get_tree().create_timer(1.0).timeout
		RoundManager.end_turn()

func _show_effect_popup(text: String):
	var popup = Label.new()
	popup.text = text
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.position = Vector2(960, 400)
	popup.add_theme_font_size_override("font_size", 32)
	add_child(popup)
	
	var tween = popup.create_tween()
	tween.tween_property(popup, "position:y", 350, 0.5)
	tween.tween_property(popup, "modulate:a", 0, 0.5)
	tween.tween_callback(popup.queue_free)

func _on_round_started(round_num: int):
	update_ui()

func _on_turn_started(character: CharacterData):
	turn_label.text = "当前回合: " + character.name
	update_ui()
	
	# 高亮当前角色
	var participants = RoundManager.participants
	for i in range(min(character_panels.size(), participants.size())):
		var panel = character_panels[i]
		if participants[i] == character:
			VisualEffects.play_turn_indicator(panel)
			panel.modulate = Color(1.2, 1.2, 1.0)
		else:
			panel.modulate = Color(1.0, 1.0, 1.0)
	
	if character.is_player:
		is_player_turn = true
		draw_button.disabled = false
		item_button.disabled = not item_system.has_items()
	else:
		is_player_turn = false
		draw_button.disabled = true
		item_button.disabled = true
		await get_tree().create_timer(1.0).timeout
		npc_auto_play(character)

func npc_auto_play(character: CharacterData):
	var ai = AIBase.new(character, RoundManager.participants)
	
	# 决策：抽牌还是使用道具
	var decision = ai.make_decision()
	if decision == "item" and ai.should_use_item():
		# 简化：NPC不使用道具
		pass
	
	# 选择卡牌
	var available_indices = []
	for i in range(card_buttons.size()):
		if nine_cards[i] != null and not card_buttons[i].disabled:
			available_indices.append(i)
	
	if available_indices.is_empty():
		refill_cards()
		return
	
	# AI根据决断属性选择目标（影响选牌策略）
	var selected_index
	if character.decisiveness == "随机型":
		selected_index = available_indices[randi() % available_indices.size()]
	else:
		# 其他类型也暂时随机（可扩展）
		selected_index = available_indices[randi() % available_indices.size()]
	
	await get_tree().create_timer(0.5).timeout
	_on_card_clicked(selected_index)

func refill_cards():
	print("补牌")
	_show_effect_popup("补牌！")
	
	var all_cards = CardDatabase.get_base_cards()
	all_cards.shuffle()
	
	for i in range(9):
		nine_cards[i] = all_cards[i]
		card_buttons[i].text = "???"
		card_buttons[i].disabled = false
		card_buttons[i].modulate = Color(1, 1, 1)
		if all_cards[i].type == "厕所牌":
			card_buttons[i].modulate = Color(0.8, 1.0, 0.8)

func _on_character_drunk(character_id: String):
	print("游戏结束！", character_id, "喝醉了")
	_show_effect_popup("%s 喝醉了！" % character_id)
	await get_tree().create_timer(2.0).timeout
	go_to_settlement()

func _on_alcohol_changed(character_id: String, current: int, max_val: int):
	update_ui()
	
	# 找到对应面板播放动画
	for i in range(RoundManager.participants.size()):
		if RoundManager.participants[i].id == character_id and i < character_panels.size():
			VisualEffects.play_drink_effect(character_panels[i], 1)
			break

func _on_favorability_changed(character_id: String, value: int):
	# 找到对应面板播放动画
	for i in range(RoundManager.participants.size()):
		if RoundManager.participants[i].id == character_id and i < character_panels.size():
			VisualEffects.play_favor_up_effect(character_panels[i])
			break

func go_to_settlement():
	GameManager.change_state(GameManager.GameState.SETTLEMENT)
	get_tree().change_scene_to_file("res://src/ui/screens/SettlementScreen.tscn")
