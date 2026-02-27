extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var continue_button = $VBoxContainer/ContinueButton
@onready var settings_button = $VBoxContainer/SettingsButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	
	# 检查是否有存档
	continue_button.disabled = SaveManager.current_save.current_level <= 1

func _on_start_pressed():
	print("开始新游戏")
	GameManager.change_state(GameManager.GameState.HOSTEL)
	get_tree().change_scene_to_file("res://src/ui/screens/HostelScreen.tscn")

func _on_continue_pressed():
	print("继续游戏")
	GameManager.change_state(GameManager.GameState.HOSTEL)
	get_tree().change_scene_to_file("res://src/ui/screens/HostelScreen.tscn")

func _on_settings_pressed():
	print("打开设置")
