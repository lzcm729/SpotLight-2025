extends Control
@onready var energy: Label = $HBoxContainer/VBoxContainer/Energy
@onready var energy_progress: ProgressBar = $HBoxContainer/VBoxContainer/EnergyProgress
@onready var health: Label = $HBoxContainer/VBoxContainer2/Health
@onready var health_progress: ProgressBar = $HBoxContainer/VBoxContainer2/HealthProgress
@onready var level: Label = $HBoxContainer/VBoxContainer3/Level
@onready var level_progress: ProgressBar = $HBoxContainer/VBoxContainer3/LevelProgress

@export var space_ship:SpaceShip

func _ready() -> void:
	# 连接SpaceShipManager的信号
	space_ship.health_changed.connect(_on_health_changed)
	space_ship.energy_changed.connect(_on_energy_changed)
	space_ship.level_up.connect(_on_level_up)
	space_ship.experience_gained.connect(_on_experience_gained)
	
	# 初始化UI显示
	update_health_display()
	update_energy_display()
	update_level_display()

# 更新血量显示
func update_health_display() -> void:
	var current_health = space_ship.get_health()
	var max_health = space_ship.max_health
	var _health_percentage = space_ship.get_health_percentage()
	
	health_progress.max_value = max_health
	health_progress.value = current_health

# 更新能量显示
func update_energy_display() -> void:
	var current_energy = space_ship.get_energy()
	var max_energy = space_ship.max_energy
	var _energy_percentage = space_ship.get_energy_percentage()
	
	energy_progress.max_value = max_energy
	energy_progress.value = current_energy

# 更新等级显示
func update_level_display() -> void:
	var current_level = space_ship.get_level()
	var current_experience = space_ship.get_experience()
	var experience_needed = current_level * 100
	
	level.text = "等级: " + str(current_level)
	level_progress.value = current_experience
	level_progress.max_value = experience_needed

# 血量变化信号处理
func _on_health_changed(_new_health: float, _old_health: float) -> void:
	update_health_display()

# 能量变化信号处理
func _on_energy_changed(_new_energy: float, _old_energy: float) -> void:
	update_energy_display()

# 等级变化信号处理
func _on_level_up(_new_level: int) -> void:
	update_level_display()

# 经验变化信号处理
func _on_experience_gained(_experience: int) -> void:
	update_level_display()
