extends Control
@onready var energy: Label = $HBoxContainer/VBoxContainer/Energy
@onready var energy_progress: ProgressBar = $HBoxContainer/VBoxContainer/EnergyProgress
@onready var health: Label = $HBoxContainer/VBoxContainer2/Health
@onready var health_progress: ProgressBar = $HBoxContainer/VBoxContainer2/HealthProgress

@export var space_ship:SpaceShip

func _ready() -> void:
	# 连接SpaceShipManager的信号
	space_ship.health_changed.connect(_on_health_changed)
	space_ship.energy_changed.connect(_on_energy_changed)
	
	# 初始化UI显示
	update_health_display()
	update_energy_display()

# 更新血量显示
func update_health_display() -> void:
	var current_health = space_ship.get_health()
	var max_health = space_ship.max_health
	var health_percentage = space_ship.get_health_percentage()
	
	health_progress.max_value = max_health
	health_progress.value = current_health

# 更新能量显示
func update_energy_display() -> void:
	var current_energy = space_ship.get_energy()
	var max_energy = space_ship.max_energy
	var energy_percentage = space_ship.get_energy_percentage()
	
	energy_progress.max_value = max_energy
	energy_progress.value = current_energy

# 血量变化信号处理
func _on_health_changed(new_health: float, old_health: float) -> void:
	update_health_display()

# 能量变化信号处理
func _on_energy_changed(new_energy: float, old_energy: float) -> void:
	update_energy_display()
