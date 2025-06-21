extends Node

@export var mouse_cursor: Texture2D
@export var mouse_cursor_circle: Texture2D

# 鼠标光标节点
var cursor_sprite: Sprite2D
var circle_sprite: Sprite2D
var is_clicking: bool = false
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
	
	# 初始化鼠标位置
	last_mouse_pos = get_viewport().get_mouse_position()

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
			cursor_sprite.visible = true
		else:
			# 鼠标在视口内正常移动
			last_mouse_pos = current_mouse_pos
	else:
		# 鼠标离开视口
		if mouse_entered:
			mouse_entered = false
			cursor_sprite.visible = false
	
	# 更新光标位置（HUD层中的位置）
	if mouse_entered and cursor_sprite:
		cursor_sprite.position = last_mouse_pos
	
	# 如果正在点击，更新圆圈位置
	if is_clicking and mouse_entered and circle_sprite:
		circle_sprite.position = last_mouse_pos

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 鼠标按下时显示圆圈
				_show_click_circle(event.position)
			else:
				# 鼠标松开时隐藏圆圈
				_hide_click_circle()
	elif event is InputEventMouseMotion:
		# 处理鼠标移动事件，确保位置同步
		if mouse_entered:
			last_mouse_pos = event.position

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

# 清理函数
func _exit_tree():
	# 恢复系统鼠标
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
