extends Node
# 游戏主管理器

enum GameState { MENU, HOSTEL, GAME_TABLE, SETTLEMENT, DIALOG }

var current_state = GameState.MENU
var current_level = 1
var game_round = 0
var current_cups = 2
var current_alcohol_type = "basic"

var alcohol_coefficients = {
	"basic": 1.0,
	"club": 1.2,
	"heart": 0.8,
	"diamond": 1.0,
	"spade": 1.5
}

var alcohol_names = {
	"basic": "基础款",
	"club": "火星烈酒",
	"heart": "星云甜酒",
	"diamond": "小行星啤酒",
	"spade": "黑洞伏特加"
}

var participants = []
var current_turn_index = 0

func _ready():
	print("GameManager 初始化完成")

func start_game(level: int):
	current_level = level
	game_round = 0
	current_turn_index = 0
	
	# 根据关卡设置初始杯数
	current_cups = min(2 + (level - 1), 6)
	current_alcohol_type = "basic"
	
	print("开始关卡 ", level, "，初始杯数: ", current_cups)
	EventBus.game_started.emit()

func change_state(new_state: GameState):
	current_state = new_state
	match new_state:
		GameState.MENU:
			EventBus.scene_changed.emit("MainMenu")
		GameState.HOSTEL:
			EventBus.scene_changed.emit("HostelScreen")
		GameState.GAME_TABLE:
			EventBus.scene_changed.emit("GameTableScreen")
		GameState.SETTLEMENT:
			EventBus.scene_changed.emit("SettlementScreen")
		GameState.DIALOG:
			EventBus.scene_changed.emit("DialogScreen")

func calculate_alcohol_damage(cups: int) -> int:
	var coefficient = alcohol_coefficients.get(current_alcohol_type, 1.0)
	return int(cups * coefficient)

func set_alcohol_type(suit: String):
	match suit:
		"club": current_alcohol_type = "club"
		"heart": current_alcohol_type = "heart"
		"diamond": current_alcohol_type = "diamond"
		"spade": current_alcohol_type = "spade"
		_: current_alcohol_type = "basic"

func get_next_participant() -> Dictionary:
	if participants.is_empty():
		return {}
	
	var participant = participants[current_turn_index]
	current_turn_index = (current_turn_index + 1) % participants.size()
	
	if current_turn_index == 0:
		game_round += 1
		EventBus.round_started.emit(game_round)
	
	return participant
