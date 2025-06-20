extends Node
class_name	TaskManager

# 信号：道具状态改变时发送
signal item_status_changed(item_id: int, is_obtained: bool)

# 道具表：存储道具ID和获取状态
var item_table: Dictionary = {
	1: false,  # 道具1
	2: false,  # 道具2
	3: false,  # 道具3
	4: false,  # 道具4
	5: false,  # 道具5
	6: false   # 道具6
}

func _ready():
	# 连接所有pickable分组的道具pick信号
	connect_pickable_signals()

# 连接pickable分组的道具信号
func connect_pickable_signals():
	var pickable_items = get_tree().get_nodes_in_group("Float")
	for item in pickable_items:
		# 连接pick信号
		if item.has_signal("pick"):
			item.pick.connect(_on_item_picked_up.bind(item))

# 处理道具拾起信号
func _on_item_picked_up(item_id: int, item: Node):
	if item_table.has(item_id):
		# 设置道具为已获取状态
		set_item_status(item_id, true)
		print("道具被拾起，更新状态: 道具", item_id)
	else:
		print("道具ID不存在: ", item_id)

# 设置道具状态
func set_item_status(item_id: int, is_obtained: bool):
	if item_table.has(item_id):
		var old_status = item_table[item_id]
		item_table[item_id] = is_obtained
		
		# 如果状态发生变化，发送信号
		if old_status != is_obtained:
			emit_signal("item_status_changed", item_id, is_obtained)
	else:
		print("道具ID不存在: ", item_id)
