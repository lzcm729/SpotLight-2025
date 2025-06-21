extends Node

# 黑洞层列表
var black_hole_layers: Array[Sprite2D] = []
# 摄像机引用
var camera: Camera2D
# 基础位置（黑洞中心）
var base_position: Vector2
# 基础缩放（用于计算缩放偏移）
var base_scales: Array[Vector2] = []
# 基础透明度（用于计算透明度偏移）
var base_modulates: Array[Color] = []
# 视差效果参数
@export var parallax_strength: float = 0.1  # 视差强度 - 进一步降低到0.1
@export var scale_effect_strength: float = 0.05  # 缩放效果强度
@export var rotation_effect_strength: float = 0.02  # 旋转效果强度
@export var alpha_effect_strength: float = 0.1  # 透明度效果强度
@export var debug_mode: bool = false  # 调试模式

func _ready():
	# 获取所有黑洞层
	_get_black_hole_layers()
	# 获取摄像机
	_get_camera()
	# 记录基础位置、缩放和透明度
	if black_hole_layers.size() > 0:
		base_position = black_hole_layers[0].position
		# 记录每层的基础缩放和透明度
		for layer in black_hole_layers:
			base_scales.append(layer.scale)
			base_modulates.append(layer.modulate)
		
		if debug_mode:
			print("BlackHoleLayers: 找到 ", black_hole_layers.size(), " 个黑洞层")
			print("BlackHoleLayers: 基础位置: ", base_position)
			for i in range(black_hole_layers.size()):
				var layer = black_hole_layers[i]
				print("BlackHoleLayers: 层 ", i, " - ", layer.name, " - 缩放: ", layer.scale)

func _get_black_hole_layers():
	# 获取所有子节点中的Sprite2D（黑洞层）
	for child in get_children():
		if child is Sprite2D:
			black_hole_layers.append(child)
	
	# 按深度排序（从远到近，scale越大越远）
	black_hole_layers.sort_custom(func(a, b): return a.scale.x > b.scale.x)

func _get_camera():
	# 方法1: 通过组查找SpaceShip
	var space_ships = get_tree().get_nodes_in_group("SpaceShip")
	if space_ships.size() > 0:
		var space_ship = space_ships[0]
		camera = space_ship.get_node_or_null("Camera2D")
		if camera:
			if debug_mode:
				print("BlackHoleLayers: 通过组找到摄像机")
			return
	
	# 方法2: 通过Universe节点查找
	var universe = get_parent().get_node_or_null("Universe")
	if universe:
		var space_ship_in_universe = universe.get_node_or_null("SpaceShip")
		if space_ship_in_universe:
			camera = space_ship_in_universe.get_node_or_null("Camera2D")
			if camera:
				if debug_mode:
					print("BlackHoleLayers: 通过Universe找到摄像机")
				return
	
	# 方法3: 直接查找Camera2D组
	var cameras = get_tree().get_nodes_in_group("Camera2D")
	if cameras.size() > 0:
		camera = cameras[0]
		if debug_mode:
			print("BlackHoleLayers: 通过Camera2D组找到摄像机")
		return
	
	print("BlackHoleLayers: 警告 - 未找到摄像机")

func _get_depth_multiplier(layer_index: int) -> float:
	# 根据层的索引和实际大小计算深度倍数
	# 越近的层（索引越大，scale越小）深度倍数越大
	if black_hole_layers.size() <= 1:
		return 1.0
	
	# 获取当前层的缩放
	var current_scale = black_hole_layers[layer_index].scale.x
	
	# 获取最大和最小缩放值
	var max_scale = black_hole_layers[0].scale.x  # 最远层
	var min_scale = black_hole_layers[black_hole_layers.size() - 1].scale.x  # 最近层
	
	# 计算当前层在深度范围内的位置（0=最远，1=最近）
	var depth_ratio = 0.0
	if max_scale != min_scale:
		depth_ratio = (max_scale - current_scale) / (max_scale - min_scale)
	
	# 使用更温和的非线性函数
	var depth_multiplier = pow(depth_ratio, 0.8)  # 使用更温和的幂函数
	
	# 确保深度倍数在合理范围内，并进一步限制最大值
	depth_multiplier = clamp(depth_multiplier, 0.05, 0.5)  # 降低最大值到0.5
	
	return depth_multiplier

func _process(_delta):
	if not camera or black_hole_layers.size() == 0:
		return
	
	# 获取摄像机位置
	var camera_position = camera.global_position
	
	# 计算摄像机相对于基础位置的偏移
	var camera_offset = camera_position - base_position
	
	# 更新每个黑洞层的位置、缩放、旋转和透明度
	for i in range(black_hole_layers.size()):
		var layer = black_hole_layers[i]
		var depth_multiplier = _get_depth_multiplier(i)
		
		# 计算视差偏移（反向移动，创造深度感）
		# 越近的层偏移越大，越远的层偏移越小
		var parallax_offset = -camera_offset * parallax_strength * depth_multiplier
		
		# 应用位置偏移
		layer.position = base_position + parallax_offset
		
		# 应用缩放效果（距离越远，缩放越小）
		if i < base_scales.size():
			var scale_offset = camera_offset.length() * scale_effect_strength * depth_multiplier
			var new_scale = base_scales[i] * (1.0 - scale_offset * 0.0001)  # 降低缩放因子
			layer.scale = new_scale
		
		# 应用旋转效果（轻微的旋转增加动态感）
		var rotation_offset = camera_offset.x * rotation_effect_strength * depth_multiplier * 0.001  # 降低旋转因子
		layer.rotation = rotation_offset
		
		# 应用透明度效果（距离越远，透明度越低）
		if i < base_modulates.size():
			var alpha_offset = camera_offset.length() * alpha_effect_strength * depth_multiplier * 0.0005  # 降低透明度因子
			var new_alpha = clamp(base_modulates[i].a - alpha_offset, 0.0, 1.0)
			layer.modulate = Color(base_modulates[i].r, base_modulates[i].g, base_modulates[i].b, new_alpha)
		
		if debug_mode and i == 0:  # 只显示第一层的调试信息
			print("BlackHoleLayers: 摄像机位置: ", camera_position, " 偏移: ", camera_offset, " 视差偏移: ", parallax_offset, " 深度倍数: ", depth_multiplier)
