extends Node

@export var mouse_cursor: Texture2D
@export var mouse_cursor_circle: Texture2D
@export var mouse_cursor_wrong_grab:Texture2D
@export var space_ship:SpaceShip

# 鼠标光标节点
var cursor_sprite: Sprite2D
var circle_sprite: Sprite2D
var wrong_grab_sprite: Sprite2D  # 错误抓取光标
var is_clicking: bool = false
var is_right_clicking: bool = false  # 右键点击状态
var last_mouse_pos: Vector2
var mouse_entered: bool = true
@export var hud_layer: CanvasLayer

func _ready():
	# 隐藏系统鼠标
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# 创建鼠标光标
	_create_mouse_cursor()
	
	# 创建点击圆圈
	_create_click_circle()
	
	# 创建错误抓取光标
	_create_wrong_grab_cursor()
	
	# 初始化鼠标位置
	last_mouse_pos = get_viewport().get_mouse_position()
	
	# 连接space_ship的抓取失败信号
	if space_ship:
		space_ship.grab_failed.connect(_on_space_ship_grab_failed)
		print("MouseManager: 已连接SpaceShip的grab_failed信号")
	else:
		print("MouseManager: 警告 - space_ship未设置")

func _create_mouse_cursor():
	# 创建鼠标光标精灵
	cursor_sprite = Sprite2D.new()
	cursor_sprite.texture = mouse_cursor
	cursor_sprite.z_index = 1000  # 确保在最上层
	
	# 添加到HUD层
	hud_layer.add_child(cursor_sprite)
	print("MouseManager: 鼠标光标已添加到HUD层")

func _create_click_circle():
	# 创建点击圆圈精灵
	circle_sprite = Sprite2D.new()
	circle_sprite.texture = mouse_cursor_circle
	circle_sprite.z_index = 999  # 在光标下方
	circle_sprite.modulate.a = 0.0  # 初始透明
	
	# 添加到HUD层
	hud_layer.add_child(circle_sprite)

func _create_wrong_grab_cursor():
	# 创建错误抓取光标精灵
	wrong_grab_sprite = Sprite2D.new()
	wrong_grab_sprite.texture = mouse_cursor_wrong_grab
	wrong_grab_sprite.z_index = 1001  # 在普通光标上方
	wrong_grab_sprite.modulate.a = 0.0  # 初始透明
	
	# 添加到HUD层
	hud_layer.add_child(wrong_grab_sprite)
	print("MouseManager: 错误抓取光标已添加到HUD层")

func _process(_delta):
	# 获取当前鼠标位置（相对于视口）
	var current_mouse_pos = get_viewport().get_mouse_position()
	
	# 检查鼠标是否在视口内
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_in_viewport = current_mouse_pos.x >= 0 and current_mouse_pos.x < viewport_size.x and \
						   current_mouse_pos.y >= 0 and current_mouse_pos.y < viewport_size.y
	
	# 处理鼠标进入/离开视口
	if mouse_in_viewport:
		if not mouse_entered:
			# 鼠标重新进入视口，重置位置
			mouse_entered = true
			last_mouse_pos = current_mouse_pos
			# 只有在没有显示错误抓取光标时才显示普通光标
			if cursor_sprite and not is_right_clicking:
				cursor_sprite.visible = true
		else:
			# 鼠标在视口内正常移动
			last_mouse_pos = current_mouse_pos
	else:
		# 鼠标离开视口
		if mouse_entered:
			mouse_entered = false
			cursor_sprite.visible = false
			wrong_grab_sprite.visible = false
	
	# 更新光标位置（HUD层中的位置）
	if mouse_entered and cursor_sprite:
		cursor_sprite.position = last_mouse_pos
	
	# 如果正在点击，更新圆圈位置
	if is_clicking and mouse_entered and circle_sprite:
		circle_sprite.position = last_mouse_pos
	
	# 如果正在右键点击，更新错误抓取光标位置
	if is_right_clicking and mouse_entered and wrong_grab_sprite:
		wrong_grab_sprite.position = last_mouse_pos

func _input(event):
	if event is InputEventMouseMotion:
		# 更新鼠标位置
		last_mouse_pos = event.position
		
		# 更新光标位置
		if cursor_sprite and cursor_sprite.visible:
			cursor_sprite.position = last_mouse_pos
		if wrong_grab_sprite and wrong_grab_sprite.visible:
			wrong_grab_sprite.position = last_mouse_pos
		
		# 如果鼠标刚进入视口，显示光标
		if not mouse_entered:
			mouse_entered = true
			if cursor_sprite and not is_right_clicking:
				cursor_sprite.visible = true
			print("MouseManager: 鼠标进入视口")
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_show_click_circle(last_mouse_pos)
			else:
				_hide_click_circle()
		
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				# 右键按下时，由外部接口决定是否显示错误抓取光标
				pass
			else:
				_hide_wrong_grab_cursor()

func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		mouse_entered = false
		if cursor_sprite:
			cursor_sprite.visible = false
		if wrong_grab_sprite:
			wrong_grab_sprite.visible = false
		print("MouseManager: 鼠标离开视口")

func _show_click_circle(pos: Vector2):
	is_clicking = true
	if circle_sprite:
		circle_sprite.position = pos
	
	# 创建显示动画
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(circle_sprite, "modulate:a", 1.0, 0.1)
	tween.tween_property(circle_sprite, "scale", Vector2(1.2, 1.2), 0.1)
	
	# 然后缩小回正常大小
	tween.tween_property(circle_sprite, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.1)

func _hide_click_circle():
	is_clicking = false
	
	# 创建隐藏动画
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(circle_sprite, "modulate:a", 0.0, 0.2)
	tween.tween_property(circle_sprite, "scale", Vector2(0.8, 0.8), 0.2)

func _show_wrong_grab_cursor(pos: Vector2):
	is_right_clicking = true
	if wrong_grab_sprite:
		wrong_grab_sprite.position = pos
	
	# 隐藏原来的鼠标光标
	if cursor_sprite:
		cursor_sprite.visible = false
	
	# 创建显示动画
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(wrong_grab_sprite, "modulate:a", 1.0, 0.1)
	tween.tween_property(wrong_grab_sprite, "scale", Vector2(1.2, 1.2), 0.1)
	
	# 然后缩小回正常大小
	tween.tween_property(wrong_grab_sprite, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.1)
	
	print("MouseManager: 显示错误抓取光标")

func _hide_wrong_grab_cursor():
	is_right_clicking = false
	
	# 显示原来的鼠标光标
	if cursor_sprite and mouse_entered:
		cursor_sprite.visible = true
	
	# 创建隐藏动画
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(wrong_grab_sprite, "modulate:a", 0.0, 0.2)
	tween.tween_property(wrong_grab_sprite, "scale", Vector2(0.8, 0.8), 0.2)
	
	print("MouseManager: 隐藏错误抓取光标")

# 设置鼠标光标纹理
func set_mouse_cursor(texture: Texture2D):
	mouse_cursor = texture
	if cursor_sprite:
		cursor_sprite.texture = texture

# 设置点击圆圈纹理
func set_click_circle(texture: Texture2D):
	mouse_cursor_circle = texture
	if circle_sprite:
		circle_sprite.texture = texture

# 设置错误抓取光标纹理
func set_wrong_grab_cursor(texture: Texture2D):
	mouse_cursor_wrong_grab = texture
	if wrong_grab_sprite:
		wrong_grab_sprite.texture = texture

# 清理函数
func _exit_tree():
	# 恢复系统鼠标
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# ===== 外部接口函数 =====

# 显示错误抓取光标（红叉）
func show_wrong_grab_cursor():
	if wrong_grab_sprite and mouse_entered:
		_show_wrong_grab_cursor(last_mouse_pos)

# 隐藏错误抓取光标（红叉）
func hide_wrong_grab_cursor():
	_hide_wrong_grab_cursor()

# 检查错误抓取光标是否正在显示
func is_wrong_grab_cursor_visible() -> bool:
	return is_right_clicking and wrong_grab_sprite and wrong_grab_sprite.visible

# 获取当前鼠标位置
func get_mouse_position() -> Vector2:
	return last_mouse_pos

# ===== 信号处理函数 =====

# 处理SpaceShip抓取失败信号
func _on_space_ship_grab_failed():
	print("MouseManager: 收到SpaceShip抓取失败信号，显示红叉光标")
	show_wrong_grab_cursor()
