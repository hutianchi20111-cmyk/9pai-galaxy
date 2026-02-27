extends Control

@onready var level_container = $LevelContainer
@onready var character_container = $CharacterContainer
@onready var start_level_button = $StartLevelButton

var selected_level = 1

func _ready():
	start_level_button.pressed.connect(_on_start_level_pressed)
	setup_levels()
	setup_characters()

func setup_levels():
	# 创建16个关卡按钮
	for i in range(1, 17):
		var btn = Button.new()
		btn.text = "第%d关" % i
		btn.disabled = i > SaveManager.get_current_level()
		btn.pressed.connect(_on_level_selected.bind(i))
		level_container.add_child(btn)

func setup_characters():
	# 显示已解锁角色
	var unlocked = SaveManager.current_save.unlocked_characters
	for char_id in unlocked:
		var label = Label.new()
		label.text = char_id
		character_container.add_child(label)

func _on_level_selected(level: int):
	selected_level = level
	print("选择关卡: ", level)

func _on_start_level_pressed():
	print("开始关卡: ", selected_level)
	GameManager.start_game(selected_level)
	GameManager.change_state(GameManager.GameState.GAME_TABLE)
	get_tree().change_scene_to_file("res://src/ui/screens/GameTableScreen.tscn")
