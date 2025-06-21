extends Control
class_name Guide


@onready var guide1:Sprite2D = $Guide1
@onready var guidetext: Label = $GuideText


#指引显示和消失的函数
func change_guide_show_state(guide_id:int,show:bool):
	self.visible = true
	match guide_id:
		1:
			guide1.visible = show
			guidetext.visible = show
			guidetext.text = "滑动鼠标更改方向"


func hide_guide():
	self.visible = false
