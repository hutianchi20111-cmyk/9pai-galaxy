extends Node
# 事件总线 - 全局事件管理

signal game_started
signal game_ended
signal round_started(round_num)
signal turn_started(character_id)
signal card_drawn(card_data)
signal card_played(card_data, character_id)
signal character_drunk(character_id)
signal alcohol_changed(character_id, current, max)
signal favorability_changed(character_id, value)
signal dialog_started(npc_id, dialog_id)
signal dialog_ended
signal scene_changed(scene_name)
signal nine_cards_revealed(cards)
signal nine_cards_shuffled
