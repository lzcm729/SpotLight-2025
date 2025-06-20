extends Node

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

# 血量相关方法
func get_health() -> float:
	return health

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

func heal_to_full() -> void:
	set_health(max_health)

# 能量相关方法
func get_energy() -> float:
	return energy

func get_energy_percentage() -> float:
	return (energy / max_energy) * 100.0

func set_energy(new_energy: float) -> void:
	var old_energy = energy
	energy = clamp(new_energy, 0.0, max_energy)
	
	if energy != old_energy:
		energy_changed.emit(energy, old_energy)
		
		if energy <= 0.0:
			energy_depleted.emit()

func add_energy(amount: float) -> void:
	set_energy(energy + amount)

func reduce_energy(amount: float) -> void:
	set_energy(energy - amount)

func restore_energy_to_full() -> void:
	set_energy(max_energy)

# 设置属性上限
func set_max_health(new_max: float) -> void:
	max_health = new_max
	if health > max_health:
		set_health(max_health)

func set_max_energy(new_max: float) -> void:
	max_energy = new_max
	if energy > max_energy:
		set_energy(max_energy)

# 重置所有属性
func reset_all() -> void:
	set_health(max_health)
	set_energy(max_energy)

# 检查状态
func is_health_full() -> bool:
	return health >= max_health

func is_energy_full() -> bool:
	return energy >= max_energy

func is_health_low() -> bool:
	return health <= max_health * 0.25

func is_energy_low() -> bool:
	return energy <= max_energy * 0.25
