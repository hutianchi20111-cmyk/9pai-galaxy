extends Control

@onready var result_label = $ResultLabel
@onready var keys_container = $KeysContainer
@onready var favorability_label = $FavorabilityLabel
@onready var continue_button = $ContinueButton
@onready var back_button = $BackButton

func _ready():
	continue_button.pressed.connect(_on_continue_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	calculate_result()

func calculate_result():
	var participants = RoundManager.participants
	var drunk_npc = null
	var keys = []
	
	# 检查谁喝醉了
	for p in participants:
		if p.is_drunk():
			if not p.is_player:
				drunk_npc = p
				# 获得酒后胡话钥匙
				keys.append({
					"name": p.name + "的酒后胡话",
					"level": "低级"
				})
			
			# 检查好感度条件
			if p.favorability > 20:
				if p.is_drunk():
					keys.append({
						"name": p.name + "的酒后真言",
						"level": "高级"
					})
				else:
					keys.append({
						"name": p.name + "的好言相告",
						"level": "中级"
					})
	
	# 显示结果
	if drunk_npc:
		result_label.text = drunk_npc.name + " 喝醉了！"
	else:
		result_label.text = "无人喝醉，游戏结束"
	
	# 显示获得的钥匙
	for key in keys:
		var label = Label.new()
		label.text = "🗝️ %s (%s)" % [key.name, key.level]
		keys_container.add_child(label)
	
	# 显示好感度变化
	var favor_text = "好感度变化：\n"
	for p in participants:
		if not p.is_player:
			favor_text += "%s: %d\n" % [p.name, p.favorability]
	favorability_label.text = favor_text

func _on_continue_pressed():
	# 进入剧情对话（简化：直接返回招待所）
	GameManager.change_state(GameManager.GameState.HOSTEL)
	get_tree().change_scene_to_file("res://src/ui/screens/HostelScreen.tscn")

func _on_back_pressed():
	GameManager.change_state(GameManager.GameState.HOSTEL)
	get_tree().change_scene_to_file("res://src/ui/screens/HostelScreen.tscn")
