extends Control

@export var space_ship: SpaceShip



#写一下可以升级的内容
var upgradable_content = [
	{
		"name": "钩子延长",
		"description": "钩子长度增加20%",
		"type": "hook_length",
		"value": 1.2
	},
	{
		"name": "血量强化", 
		"description": "最大血量增加20点",
		"type": "health",
		"value": 20
	},
	{
		"name": "能源扩容",
		"description": "最大能源增加20点", 
		"type": "energy",
		"value": 20
	}
]

func _ready() -> void:
	# 连接飞船升级信号
	if space_ship:
		space_ship.level_up.connect(_on_space_ship_level_up)

# 飞船升级时触发
func _on_space_ship_level_up(new_level: int) -> void:
	print("LevelUpReward: 飞船升级到等级 ", new_level)
	space_ship.upgrade_change_movement_method_3()
	generate_upgrade_options()

# 生成升级选项
func generate_upgrade_options() -> void:
	# 预留：在这里生成升级选项的UI
	print("LevelUpReward: 生成升级选项")
	# TODO: 在这里添加生成升级选项的具体逻辑
	# 例如：随机选择2-3个升级选项显示给玩家选择
