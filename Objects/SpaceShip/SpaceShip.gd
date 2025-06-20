extends RigidBody2D
class_name SpaceShip

@export var tangential_speed: float = 100 # 切向速度
@export var radial_speed: float = -100    # 径向“下落”速度
var black_hole: BlackHole


func _ready() -> void:
	black_hole = get_tree().get_first_node_in_group("BlackHole")
		

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
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
	var force = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		force.y -= 1
	if Input.is_action_pressed("move_down"):
		force.y += 1
	if Input.is_action_pressed("move_left"):
		force.x -= 1
	if Input.is_action_pressed("move_right"):
		force.x += 1
	if force != Vector2.ZERO:
		force = force.normalized() * 5000.0  # 设置施加的力大小
		apply_central_impulse(force)	


func _on_拾取范围_body_entered(body: Node2D) -> void:
	if body is Pickable:
		# 执行拾取逻辑
		body.BePickUp(self)
	else:
		print("无法拾取: ", body.name)
