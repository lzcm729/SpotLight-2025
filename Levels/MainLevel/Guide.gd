extends Control
class_name Guide

@onready var guide2: Sprite2D = $Guide2
@onready var guide1:Sprite2D = $Guide1
@onready var guidetext: Label = $GuideText


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
			guidetext.text = "点击鼠标右键，抓取炸弹"


func hide_guide():
	hide_all_guide_group_nodes()
	self.visible = false
