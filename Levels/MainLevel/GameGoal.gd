extends Control
class_name GameGoal

signal game_goal_closed
@onready var v_box_container: VBoxContainer = $Bg/VBoxContainer
@onready var v_box_container_2: VBoxContainer = $Bg/VBoxContainer2


func show_game_goal():
	#get_tree().paused = true
	v_box_container.visible = true
	v_box_container_2.visible = false
	self.visible = true
	
func show_game_goal_2():
	v_box_container.visible = false
	v_box_container_2.visible = true
	self.visible = true


func hide_game_goal():
	#隐藏的时候游戏恢复
	#get_tree().paused = false
	self.visible = false
	#发送关闭的信号
	emit_signal("game_goal_closed")


func _on_bg_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_game_goal()
