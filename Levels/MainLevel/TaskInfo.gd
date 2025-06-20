extends Control

@onready var grid_container: GridContainer = $GridContainer
@export var task_manager: TaskManager
@export var task_icon_scene: PackedScene

# 存储生成的图标节点
var task_icons: Dictionary = {}

func _ready() -> void:
	# 连接TaskManager的信号
	if task_manager:
		task_manager.item_status_changed.connect(_on_item_status_changed)
		# 生成所有道具图标
		generate_task_icons()

# 生成所有道具图标
func generate_task_icons():
	if not task_icon_scene or not task_manager:
		print("TaskIcon场景或TaskManager未设置")
		return
	
	# 清空现有图标
	clear_task_icons()
	
	# 为每个道具生成图标
	var item_index = 1
	for item_id in task_manager.item_table.keys():
		var task_icon = task_icon_scene.instantiate()
		grid_container.add_child(task_icon)
		
		# 使用TaskIcon的test_show_id函数设置编号
		if task_icon.has_method("test_show_id"):
			task_icon.test_show_id(item_index)
		
		# 使用TaskIcon的change_get_state函数设置获取状态
		if task_icon.has_method("change_get_state"):
			task_icon.change_get_state(task_manager.item_table[item_id])
		
		# 存储图标引用
		task_icons[item_id] = task_icon
		item_index += 1

# 更新任务图标状态
func update_task_icon_status(task_icon: Node, is_obtained: bool):
	# 使用TaskIcon的change_get_state函数
	if task_icon.has_method("change_get_state"):
		task_icon.change_get_state(is_obtained)

# 清空任务图标
func clear_task_icons():
	for icon in task_icons.values():
		if is_instance_valid(icon):
			icon.queue_free()
	task_icons.clear()

# 处理道具状态变化信号
func _on_item_status_changed(item_id: int, is_obtained: bool):
	if task_icons.has(item_id):
		update_task_icon_status(task_icons[item_id], is_obtained)
		print("更新道具图标: ", item_id, " -> ", "已获取" if is_obtained else "未获取")
	
