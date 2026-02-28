extends Node
# 视觉效果系统

class_name VisualEffects

static func play_card_draw_effect(card_button: Button):
	# 抽牌动画
	var tween = card_button.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card_button, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(card_button, "scale", Vector2(1.0, 1.0), 0.2)

static func play_drink_effect(character_panel: Control, amount: int):
	# 喝酒动画 - 面板抖动+变红
	var tween = character_panel.create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(character_panel, "modulate", Color(1.0, 0.5, 0.5), 0.1)
	tween.tween_property(character_panel, "position:x", character_panel.position.x + 10, 0.05)
	tween.tween_property(character_panel, "position:x", character_panel.position.x - 10, 0.05)
	tween.tween_property(character_panel, "position:x", character_panel.position.x, 0.05)
	tween.tween_property(character_panel, "modulate", Color(1.0, 1.0, 1.0), 0.3)

static func play_favor_up_effect(character_panel: Control):
	# 好感度提升动画 - 绿色闪烁
	var tween = character_panel.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(character_panel, "modulate", Color(0.5, 1.0, 0.5), 0.2)
	tween.tween_property(character_panel, "modulate", Color(1.0, 1.0, 1.0), 0.3)

static func play_shuffle_effect(card_grid: GridContainer):
	# 洗牌动画
	for btn in card_grid.get_children():
		var tween = btn.create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(btn, "rotation", randf() * 0.2 - 0.1, 0.1)
		tween.tween_property(btn, "rotation", 0, 0.2)

static func play_turn_indicator(character_panel: Control):
	# 回合指示器动画
	var tween = character_panel.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_loops(3)
	tween.tween_property(character_panel, "scale", Vector2(1.05, 1.05), 0.3)
	tween.tween_property(character_panel, "scale", Vector2(1.0, 1.0), 0.3)
