extends Control

@export var space_ship: SpaceShip

@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var upgrade_card_1: UpgradeCard = $HBoxContainer/UpgradeCard1
@onready var upgrade_card_2: UpgradeCard = $HBoxContainer/UpgradeCard2
@onready var upgrade_card_3: UpgradeCard = $HBoxContainer/UpgradeCard3

func _ready() -> void:
	space_ship = get_tree().get_first_node_in_group("SpaceShip")
	# 连接飞船升级信号
	if space_ship:
		space_ship.level_up.connect(_on_space_ship_level_up)
	

#写一下可以升级的内容
var upgradable_content = [
	{
		"name": "牵引光束范围扩大",
		"description": "牵引光束范围增加2000像素",
		"type": "grab_range",
		"value": 2000.0,
		"upgrade_func": "upgrade_increase_grab_range"
	},
	{
		"name": "血量强化", 
		"description": "最大血量增加20点",
		"type": "max_health",
		"value": 20.0,
		"upgrade_func": "upgrade_increase_max_health"
	},
	{
		"name": "能源扩容",
		"description": "最大能源增加20点", 
		"type": "max_energy",
		"value": 20.0,
		"upgrade_func": "upgrade_increase_max_energy"
	},
	{
		"name": "推力上限提升",
		"description": "最大推力增加50000",
		"type": "max_power",
		"value": 50000.0,
		"upgrade_func": "upgrade_increase_max_power"
	},
	{
		"name": "推力加速度提升",
		"description": "推力加速度增加50000",
		"type": "thrust_acceleration",
		"value": 50000.0,
		"upgrade_func": "upgrade_increase_thrust_acceleration"
	}
]



# 飞船升级时触发
func _on_space_ship_level_up(new_level: int) -> void:
	print("LevelUpReward: 飞船升级到等级 ", new_level)
	space_ship.upgrade_change_movement_method_3()
	show_upgrade_interface()

# 生成升级选项
func generate_upgrade_options() -> void:
	print("LevelUpReward: 生成升级选项")
	
	# 随机选择3个升级
	var selected_upgrades = get_random_upgrades(3)
	
	# 为每个选中的升级设置卡片内容
	set_upgrade_cards(selected_upgrades)

# 获取随机升级选项
func get_random_upgrades(count: int) -> Array:
	var available_upgrades = upgradable_content.duplicate()
	var selected_upgrades = []
	
	# 确保不会选择超过可用升级数量的选项
	count = min(count, available_upgrades.size())
	
	for i in range(count):
		if available_upgrades.size() > 0:
			var random_index = randi() % available_upgrades.size()
			selected_upgrades.append(available_upgrades[random_index])
			available_upgrades.remove_at(random_index)
	
	return selected_upgrades

# 设置升级卡片内容
func set_upgrade_cards(upgrades: Array) -> void:
	var cards = [upgrade_card_1, upgrade_card_2, upgrade_card_3]
	
	for i in range(min(upgrades.size(), cards.size())):
		var card = cards[i]
		var upgrade = upgrades[i]
		
		if card:
			# 设置卡片信息
			card.update_card_info(upgrade.description, upgrade.name)
			
			# 断开之前的连接（如果有的话）
			if card.upgrade_selected.is_connected(_on_upgrade_card_selected):
				card.upgrade_selected.disconnect(_on_upgrade_card_selected)
			
			# 连接选择按钮信号
			card.upgrade_selected.connect(_on_upgrade_card_selected.bind(upgrade))
			
			# 显示卡片
			card.visible = true
		else:
			print("错误：升级卡片 ", i + 1, " 未找到")
	
	# 隐藏多余的卡片
	for i in range(upgrades.size(), cards.size()):
		if cards[i]:
			cards[i].visible = false

# 处理升级卡片选择事件
func _on_upgrade_card_selected(upgrade: Dictionary) -> void:
	print("选择了升级: ", upgrade.name)
	
	# 应用升级效果
	apply_upgrade(upgrade)
	
	# 关闭升级界面
	close_upgrade_interface()

# 关闭升级界面
func close_upgrade_interface() -> void:
	# 隐藏升级界面
	self.visible = false
	
	# 恢复游戏
	get_tree().paused = false
	
	print("升级界面已关闭")

# 显示升级界面
func show_upgrade_interface() -> void:
	# 暂停游戏
	get_tree().paused = true
	
	# 显示升级界面
	self.visible = true
	
	# 生成升级选项
	generate_upgrade_options()

# 应用升级效果
func apply_upgrade(upgrade: Dictionary) -> void:
	if not space_ship:
		print("错误：飞船引用为空")
		return
	
	print("应用升级: ", upgrade.name)
	
	# 使用反射调用对应的升级函数
	if upgrade.has("upgrade_func") and space_ship.has_method(upgrade.upgrade_func):
		space_ship.call(upgrade.upgrade_func, upgrade.value)
	else:
		print("错误：升级函数不存在 ", upgrade.get("upgrade_func", "未知"))



	
