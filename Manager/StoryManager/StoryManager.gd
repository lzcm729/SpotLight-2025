extends Node
#故事管理器

@export var space_ship : SpaceShip

#主界面的控制
@export var daughter_info : Control
@export var space_ship_state : Control
@export var dialog:Dialog
@export var guide:Guide

var boom = preload("res://Objects/Pickable/Boom/Boom.tscn")

#游戏进度
enum GameStage {
	STAGE_1_INTRO,      # 第一阶段：背景介绍，新手教程
	STAGE_2_EXPLORATION, # 第二阶段：初次执行任务
}

# 当前游戏阶段
var current_stage: GameStage = GameStage.STAGE_1_INTRO

# 游戏进度表 - 每个阶段的故事内容
var story_progress: Dictionary = {
	GameStage.STAGE_1_INTRO: {
		"name": "宇宙的呼唤",
		"description": "小女孩在宇宙中醒来，发现自己在一个神秘的太空环境中",
		"story_function": "play_intro_story",
		"completed": false
	},
	GameStage.STAGE_2_EXPLORATION: {
		"name": "探索未知",
		"description": "开始探索周围的环境，发现各种神秘物体",
		"story_function": "play_exploration_story",
		"completed": false
	},
}

func _ready():
	# 开始当前阶段的故事
	play_current_stage_story()


# 播放当前阶段的故事
func play_current_stage_story():
	var stage_data = story_progress[current_stage]
	if stage_data:
		var function_name = stage_data["story_function"]
		if has_method(function_name):
			call(function_name)
		else:
			print("StoryManager: 未找到故事函数: ", function_name)

# 进入下一个阶段
func advance_to_next_stage():
	var current_index = current_stage
	var next_index = current_index + 1
	
	if next_index < GameStage.size():
		current_stage = next_index
		story_progress[current_index]["completed"] = true
		play_current_stage_story()
		print("StoryManager: 进入新阶段: ", story_progress[current_stage]["name"])
	else:
		print("StoryManager: 游戏已完成所有阶段")

# 获取当前阶段信息
func get_current_stage_info() -> Dictionary:
	return story_progress[current_stage]


# ==================== 故事函数 ====================

# 第一阶段故事：介绍
func play_intro_story():
	##禁用所有的UI展示，只在星空中漂浮  
	daughter_info.visible = false
	space_ship_state.visible = false
	guide.hide_guide()

	#教学禁用相关操控
	space_ship._can_rotate = false
	space_ship._can_impulse = false

	await get_tree().create_timer(1.0).timeout
	
	dialog.set_dialog_visible(true)
	var dialog1 = ["在吗，约翰森","很抱歉打扰你的日常巡航，宇航局有紧急任务需要你协助","飞船的自由航行功能已解锁，你现在可以自由的控制飞船的航行方向"]
	dialog.start_dialog(dialog1)
	await dialog.dialog_completed
	space_ship._can_rotate = true
	guide.change_guide_show_state(1,true)
	
	# 当旋转角度>90度时，进入下一阶段
	# 记录初始角度
	var start_angle := space_ship.rotation
	var total_rotation := 0.0
	# 等待旋转差超过 90°
	while total_rotation < PI/2:
		total_rotation += abs(space_ship.rotation - start_angle)
		await get_tree().process_frame


	await get_tree().create_timer(2.0).timeout
	guide.hide_guide()


	var dialog2 = ["宇航局监测到，80年后黑洞将吞没地球","为了避免这一灾难，我们委托你带着新研制的反物质炸弹前往黑洞","它接近你了，你可以接住它"]
	dialog.set_dialog_visible(true)
	dialog.start_dialog(dialog2)
	await dialog.dialog_completed
	guide.change_guide_show_state(2,true)
	
	var instance = boom.instantiate() as Pickable
	instance.tangential_speed = 0
	instance.radial_speed = 0
	# 放置在(-1620,620)位置
	instance.global_position = Vector2(-1620, 620)
	add_child(instance)
	await instance.pick

	print("StoryManager: 反物质炸弹已被拾取，进入下一阶段")
	
	# 销毁炸弹
	var boom_instance = get_tree().get_first_node_in_group("Boom")
	if boom_instance:
		boom_instance.Destroy()
	
	# 显示下一阶段的提示
	guide.hide_guide()
	dialog.set_dialog_visible(true)
	var dialog3 = ["很好，你已经成功拾取了反物质炸弹","现在你可以前往黑洞，使用炸弹摧毁它","注意你剩余的燃料","出发吧，光荣的战士"]
	dialog.start_dialog(dialog3)
	await dialog.dialog_completed
	guide.change_guide_show_state(3,true)
	space_ship._can_impulse = true
	space_ship_state.visible = true

	await space_ship.start_impulsed
	guide.hide_guide()




# 第二阶段故事：探索
func play_exploration_story():
	print("StoryManager: 播放探索故事 - 探索未知")
	# 在这里添加具体的探索故事逻辑
