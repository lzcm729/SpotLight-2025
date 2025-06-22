extends Node
#故事管理器

@export var space_ship : SpaceShip

#主界面的控制
@export var daughter_info : Control
@export var space_ship_state : Control
@export var dialog:Dialog
@export var guide:Guide
@onready var skip_guide: Button = $"../HUD/SkipGuide"
@onready var game_goal: GameGoal = $"../HUD/GameGoal"

var boom = preload("res://Objects/Pickable/Boom/Boom.tscn")

#游戏进度
enum GameStage {
	STAGE_1_INTRO,      # 第一阶段：背景介绍，新手教程
	STAGE_2_DAUGHTER, # 第二阶段：初次执行任务
	STAGE_3_BLACK_HOLE, # 第三阶段：黑洞
}

# 当前游戏阶段
var current_stage: GameStage = GameStage.STAGE_1_INTRO

# 游戏进度表 - 每个阶段的故事内容
var story_progress: Dictionary = {
	GameStage.STAGE_1_INTRO: {
		"name": "公司在召唤",
		"description": "日常巡航任务，却收到了要你协助的紧急任务",
		"story_function": "play_intro_story",
		"completed": false
	},
	GameStage.STAGE_2_DAUGHTER: {
		"name": "和女儿的约定",
		"description": "得知你要去很久，女儿给你打来了星际电话",
		"story_function": "play_daughter_story",
		"completed": false
	},
	GameStage.STAGE_3_BLACK_HOLE: {
		"name": "黑洞的威胁",
		"description": "黑洞的威胁，你需要摧毁它",
		"story_function": "play_black_hole_story",
		"completed": false
	},
}

func _ready():
	# 开始当前阶段的故事
	play_current_stage_story()

# 飞船平滑移动到指定位置
func move_space_ship_to_position(target_position: Vector2, duration: float = 3.0):
	print("StoryManager: 飞船开始移动到位置 ", target_position)
	# space_ship.freeze = true
	space_ship.linear_velocity = Vector2.ZERO  # 停止飞船的线速度
	
	# 创建Tween进行平滑移动
	var tween = create_tween()
	tween.tween_property(space_ship, "global_position", target_position, duration)
	
	# 等待移动完成
	await tween.finished
	# space_ship.freeze = false
	print("StoryManager: 飞船移动完成")

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
	dialog.start_dialog(dialog1, 1)
	await dialog.dialog_completed
	space_ship._can_rotate = true
	guide.change_guide_show_state(1,true)
	
	# 当旋转角度>90度时，进入下一阶段
	# 记录初始角度
	var start_angle := space_ship.rotation
	# 等待旋转差超过 90°
	while abs(space_ship.rotation - start_angle) < PI/2:
		await get_tree().process_frame

	guide.hide_guide()

	var dialog2 = ["宇航局监测到，80年后黑洞将吞没地球","为了避免这一灾难，我们委托你带着新研制的反物质炸弹前往黑洞","它接近你了，你可以接住它"]
	dialog.set_dialog_visible(true)
	dialog.start_dialog(dialog2, 1)
	await dialog.dialog_completed
	guide.change_guide_show_state(2,true)
	
	var instance = boom.instantiate() as Pickable
	instance.tangential_speed = 0
	instance.radial_speed = 0
	# 放置在(-1620,620)位置
	instance.global_position = space_ship.position + Vector2(-100, 0)
	add_child(instance)
	await instance.pick

	print("StoryManager: 反物质炸弹已被拾取，进入下一阶段")
	
	# 显示下一阶段的提示
	guide.hide_guide()
	dialog.set_dialog_visible(true)
	var dialog3 = ["很好，你已经成功拾取了反物质炸弹","现在你可以前往黑洞，使用炸弹摧毁它","注意你剩余的燃料","出发吧，光荣的战士"]
	dialog.start_dialog(dialog3, 1)
	await dialog.dialog_completed
	guide.change_guide_show_state(3,true)
	space_ship._can_impulse = true
	space_ship_state.visible = true

	await space_ship.start_impulsed
	instance.Destroy()
	guide.hide_guide()
	advance_to_next_stage()

# 第二阶段故事：探索
func play_daughter_story():
	print("StoryManager:播放和女儿的童话记录")
	await get_tree().create_timer(1.0).timeout

	space_ship.fire_left.emitting = true
	space_ship.fire_right.emitting = true
	space_ship._can_impulse = false
	space_ship._can_rotate = false
	space_ship.rotation = PI / 2  # 初始朝向



	# 将飞船平滑移动到指定位置
	await move_space_ship_to_position(Vector2(-3400, 550))
	
	#女儿打电话来了
	dialog.set_dialog_visible(true)
	var dialog1 = ["爸爸，听得到吗","妈妈说你要去很远的地方","你可以早点回来吗"]
	dialog.start_dialog(dialog1, 2)
	await dialog.dialog_completed
	dialog.set_dialog_visible(false)

	await get_tree().create_timer(2.0).timeout

	advance_to_next_stage()

# 第三阶段故事：黑洞
func play_black_hole_story():
	print("StoryManager:播放黑洞的故事")
	space_ship.global_position = Vector2(-150, 400)

	# 平滑移动到指定位置
	await move_space_ship_to_position(Vector2(100, 400), 3.0)

	_spawn_boom_according_ship(Vector2(100, -100))
	
	space_ship._can_impulse = true
	space_ship._can_rotate = true

	daughter_info.visible = true
	space_ship_state.visible = true

	#播放游玩目标
	game_goal.show_game_goal()
	await game_goal.game_goal_closed
	
	



func _on_skip_guide_pressed() -> void:
	space_ship.global_position = Vector2(-150, 400)
	await move_space_ship_to_position(Vector2(100, 400), 3.0)
	story_progress[1]["completed"] = true
	story_progress[2]["completed"] = true
	current_stage = 2
	play_current_stage_story()
	dialog.skip_dialog()
	space_ship._can_impulse = false
	space_ship._can_rotate = false
	
	skip_guide.visible = false
	guide.hide_guide()

	daughter_info.visible = true
	space_ship_state.visible = true
	

func _spawn_boom_according_ship(offset: Vector2):
	var instance = boom.instantiate() as Pickable
	instance.tangential_speed = 0
	instance.radial_speed = 0
	instance.global_position = space_ship.position + offset
	add_child(instance)
