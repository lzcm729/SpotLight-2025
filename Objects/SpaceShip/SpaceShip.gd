extends RigidBody2D
class_name SpaceShip

# 信号
signal health_changed(new_health: float, old_health: float)
signal energy_changed(new_energy: float, old_energy: float)
signal health_depleted
signal energy_depleted

# 飞船属性
var health: float = 100.0
var energy: float = 100.0

# 属性上限
var max_health: float = 100.0
var max_energy: float = 100.0

var black_hole: BlackHole
var _current_thrust: float = 0.0               # 当前累积推力
var _is_eaten: bool = false  # 是否被黑洞吞噬
var _is_controlled: bool = false  # 是否由玩家控制
var _grabbed_pickable: Pickable = null

@export var tangential_speed: float = 100 # 切向速度
@export var radial_speed: float = -100    # 径向"下落"速度
@export var max_power: float = 750000            # 最大推力（Impulse 上限）
@export var thrust_acceleration: float = 250000  # 推力增长速率 (Impulse 增量/s)
@export var energy_consumption_rate: float = 5.0  # 能量消耗速率 (per second)
@export var pickup_attract_speed: float = 100.0  # 吸附速度

@onready var _grab_line : Line2D = $GrabLine

func _ready() -> void:
	black_hole = get_tree().get_first_node_in_group("BlackHole")
	# 将摄像机也添加到组中
	var camera_node = get_node_or_null("Camera2D")
	if camera_node:
		camera_node.add_to_group("Camera2D")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		var world_pos = get_global_mouse_position()
		var pick_radius = 32.0

		var circle = CircleShape2D.new()
		circle.radius = pick_radius

		var q = PhysicsShapeQueryParameters2D.new()
		q.shape = circle
		q.transform = Transform2D(0, world_pos)
		q.collide_with_bodies = true

		var hits = get_world_2d().direct_space_state.intersect_shape(q)
		for hit in hits:
			if hit.collider is Pickable:
				_grabbed_pickable = hit.collider
				_grabbed_pickable.linear_velocity = Vector2.ZERO
				_grab_line.visible = true
				break


func _physics_process(delta: float) -> void:
	_rotate_towards_pointer()
	_move_method_2(delta)
	if _grabbed_pickable:
		# 更新连线两端点
		_grab_line.points = [
			Vector2.ZERO,
			to_local(_grabbed_pickable.global_position)
		]
		var dir = (global_position - _grabbed_pickable.global_position)
		var dist = dir.length()
		if dist < 10.0:
			_grabbed_pickable.BePickUp(self)
			_grabbed_pickable = null
			_grab_line.visible = false
		else:
			_grabbed_pickable.linear_velocity = dir.normalized() * pickup_attract_speed
	else:
		_grab_line.visible = false


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# 如果飞船已经被黑洞吞噬，则不再施加任何力
	if _is_eaten: return
	if _is_controlled: return

	var offset = state.transform.origin - black_hole.position
	if offset.length() <= 0: return

	# 计算径向和切向单位向量
	var radial = offset.normalized()
	# var tangential = radial.rotated(PI / 2)  # 切向向量是径向向量逆时针旋转90度

	# 拆出"已有轨道分量"
	var v_radial = radial * state.linear_velocity.dot(radial)
	# var v_tang = tangential * state.linear_velocity.dot(tangential)
	# var user_velocity = state.linear_velocity - (v_radial + v_tang)
	var user_velocity = state.linear_velocity - v_radial

	# # 合成螺旋速度
	# var orbital_velocity = tangential * tangential_speed \
	# 					 + radial * _get_current_radial_speed()

	var radial_velocity = radial * _get_current_radial_speed()

	# 施加合成的螺旋速度
	state.linear_velocity = user_velocity + radial_velocity


func _get_current_radial_speed() -> float:
	# 返回当前的径向速度
	# 和黑洞距离有关
	var offset = position - black_hole.position
	var distance = offset.length()
	# 距离越近，径向速度越大
	var percentage = clamp(distance / black_hole.GetAttractionRadius(), 0.0, 1.0)
	# 计算径向速度
	return radial_speed * (1.0 - percentage)


func GetDistanceToBlackHole() -> float:
	# 返回当前与黑洞的距离
	return position.distance_to(black_hole.position)


# 使用WASD给飞船施加力
func _move_method_1(_delta: float) -> void:
	var dir = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1

	# 只有在有输入且有能量时才产生推力
	if dir != Vector2.ZERO and energy > 0.0:
		dir = dir.normalized()

		# 累积推力
		_current_thrust = clamp(_current_thrust + thrust_acceleration * _delta, 0.0, max_power)
		print("当前推力: ", _current_thrust)

		# 消耗能量
		var used = energy_consumption_rate * _delta
		modify_energy(-used)

		# 施加推力
		var force = dir * _current_thrust * _delta
		apply_central_impulse(force)
	else:
		# 重置推力
		_current_thrust = 0.0

# 使用鼠标点击给飞船施加力
func _move_method_2(_delta: float) -> void:
	# 当鼠标左键按下且有能量时，飞船朝鼠标世界坐标方向移动
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and energy > 0.0:
		var target = get_global_mouse_position()
		var dir = target - global_position
		if dir.length() > 0:
			dir = dir.normalized()
			# 累积推力
			_current_thrust = clamp(_current_thrust + thrust_acceleration * _delta, 0.0, max_power)
			print("当前推力: ", _current_thrust)
			# 消耗能量
			var used = energy_consumption_rate * _delta
			modify_energy(-used)

			# 施加冲量
			var force = dir * _current_thrust * _delta
			# 相对于黑洞中心的径向/切向单位向量
			var radial = (global_position - black_hole.position).normalized()
			var tangential = radial.rotated(PI / 2)

			# 分解、削弱切向分量
			var f_radial = radial * force.dot(radial)
			var f_tangential = tangential * force.dot(tangential) * 0.1 # 调节切向分量的强度（越小摆动越弱）
			apply_central_impulse(f_radial + f_tangential)
	else:
		# 未按鼠标或没能量时重置推力
		_current_thrust = 0.0

# 使用鼠标点击改变飞船位置
func _move_method_3(_delta: float) -> void:
	var move_speed = 200.0  # 移动速度
	# 当鼠标左键按下且有能量时，飞船朝鼠标世界坐标方向移动
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and energy > 0.0:
		_is_controlled = true  # 标记为由玩家控制
		var target = get_global_mouse_position()
		var offset = target - position
		if offset.length() > 0:
			position += offset.normalized() * move_speed * _delta
	else:
		_is_controlled = false  # 如果没有按下鼠标左键，则不再控制飞船


# 飞船朝向指针方向
func _rotate_towards_pointer() -> void:
	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - global_position
	if dir.length() > 0:
		rotation = dir.angle() + PI/2


func _on_拾取范围_body_entered(body: Node2D) -> void:
	if body is Pickable:
		# 执行拾取逻辑
		body.BePickUp(self)
	else:
		print("无法拾取: ", body.name)

#################################下面的血量能源相关

func get_health_percentage() -> float:
	return (health / max_health) * 100.0


func set_health(new_health: float) -> void:
	var old_health = health
	health = clamp(new_health, 0.0, max_health)
	
	if health != old_health:
		health_changed.emit(health, old_health)
		
		if health <= 0.0:
			health_depleted.emit()


func modify_health(amount: float) -> void:
	set_health(health + amount)


func get_energy_percentage() -> float:
	return (energy / max_energy) * 100.0


func set_energy(new_energy: float) -> void:
	var old_energy = energy
	energy = clamp(new_energy, 0.0, max_energy)
	
	if energy != old_energy:
		energy_changed.emit(energy, old_energy)
		
		if energy <= 0.0:
			energy_depleted.emit()


func modify_energy(amount: float) -> void:
	set_energy(energy + amount)


# 血量相关方法
func get_health() -> float:
	return health


# 能量相关方法
func get_energy() -> float:
	return energy
