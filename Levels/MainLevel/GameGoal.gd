extends Control
class_name GameGoal

signal game_goal_closed


func show_game_goal():
	#展示的时候游戏暂停
	get_tree().paused = true
	self.visible = true


func hide_game_goal():
	#隐藏的时候游戏恢复
	get_tree().paused = false
	self.visible = false
	#发送关闭的信号
	emit_signal("game_goal_closed")


func _on_bg_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_game_goal()
