extends RigidBody2D
class_name SpaceShip


# 飞船属性
var health: float = 100.0
var energy: float = 100.0

# 属性上限
var max_health: float = 100.0
var max_energy: float = 100.0

# 信号
signal health_changed(new_health: float, old_health: float)
signal energy_changed(new_energy: float, old_energy: float)
signal health_depleted
signal energy_depleted

@export var tangential_speed: float = 100 # 切向速度
@export var radial_speed: float = -100    # 径向“下落”速度
@export var max_power: float = 750000            # 最大推力（Impulse 上限）
@export var thrust_acceleration: float = 250000  # 推力增长速率 (Impulse 增量/s)
@export var energy_consumption_rate: float = 5.0  # 能量消耗速率 (per second)

var black_hole: BlackHole
var _current_thrust: float = 0.0               # 当前累积推力
var _is_eaten: bool = false  # 是否被黑洞吞噬

func _ready() -> void:
	black_hole = get_tree().get_first_node_in_group("BlackHole")
		

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _is_eaten:
		# 如果飞船已经被黑洞吞噬，则不再施加任何力
		return
	var offset = state.transform.origin - black_hole.position
	if offset.length() <= 0: return
	# 计算径向和切向单位向量
	var radial = offset.normalized()
	var tangential = radial.rotated(PI / 2)  # 切向向量是径向向量逆时针旋转90度

	# 拆出“已有轨道分量”
	var v_radial = radial * state.linear_velocity.dot(radial)
	var v_tang = tangential * state.linear_velocity.dot(tangential)
	var user_velocity = state.linear_velocity - (v_radial + v_tang)

	# 合成螺旋速度
	var orbital_velocity = tangential * tangential_speed \
						 + radial * _get_current_radial_speed()

	# 施加合成的螺旋速度
	state.linear_velocity = user_velocity + orbital_velocity


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
func _physics_process(_delta: float) -> void:
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


func _on_拾取范围_body_entered(body: Node2D) -> void:
	if body is Pickable:
		var is_boom = body.check_is_boom()
		if is_boom:
			reduce_health(10)

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


func add_health(amount: float) -> void:
	set_health(health + amount)

func reduce_health(amount: float) -> void:
	set_health(health - amount)


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
