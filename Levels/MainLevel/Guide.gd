extends Control
class_name Guide

@onready var guide3: TextureRect = $Guide3
@onready var guide2: TextureRect = $Guide2
@onready var guide1:TextureRect = $Guide1
@onready var guidetext: Label = $GuideText

# 鼠标点击检测变量
var mouse_clicked: bool = false
var left_clicked: bool = false
var right_clicked: bool = false

func _ready():
	# 设置输入处理
	set_process_input(true)

func _input(event):
	# 检测鼠标点击
	if event is InputEventMouseButton:
		if event.pressed:
			# 鼠标按下
			mouse_clicked = true
			
			if event.button_index == MOUSE_BUTTON_LEFT:
				left_clicked = true
				print("Guide: 检测到鼠标左键点击")
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				right_clicked = true
				print("Guide: 检测到鼠标右键点击")
		else:
			# 鼠标松开
			if event.button_index == MOUSE_BUTTON_LEFT:
				left_clicked = false
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				right_clicked = false

# 检查鼠标是否被点击
func is_mouse_clicked() -> bool:
	return mouse_clicked

# 检查鼠标左键是否被点击
func is_left_clicked() -> bool:
	return left_clicked

# 检查鼠标右键是否被点击
func is_right_clicked() -> bool:
	return right_clicked

# 重置鼠标点击状态
func reset_mouse_click():
	mouse_clicked = false
	left_clicked = false
	right_clicked = false

# 隐藏所有guide分组节点的函数
func hide_all_guide_group_nodes():
	# 获取所有分组为"guide"的节点
	var guide_nodes = get_tree().get_nodes_in_group("guide")
	
	# 循环隐藏所有guide分组节点
	for node in guide_nodes:
		node.visible = false


#指引显示和消失的函数
func change_guide_show_state(guide_id:int,show:bool):
	self.visible = true
	match guide_id:
		1:
			guide1.visible = show
			guidetext.visible = show
			guidetext.text = "滑动鼠标更改方向"
		2:
			guide2.visible = show
			guidetext.visible = show
			guidetext.text = "对着炸弹点击鼠标右键，抓过来"
		3:
			guide3.visible = show
			guidetext.visible = show
			guidetext.text = "点击鼠标左键，加速前进"


func hide_guide():
	hide_all_guide_group_nodes()
	self.visible = false
