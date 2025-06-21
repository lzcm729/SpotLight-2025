extends Node

# 外发光shader参数
@export var glow_color: Color = Color(1.0, 0.5, 0.0, 1.0)  # 发光颜色
@export var glow_intensity: float = 2.0  # 发光强度
@export var glow_radius: float = 10.0  # 发光半径
@export var glow_falloff: float = 0.5  # 发光衰减
@export var pulse_speed: float = 1.0  # 脉冲速度
@export var pulse_strength: float = 0.3  # 脉冲强度

# 内部变量
var shader_material: ShaderMaterial
var time: float = 0.0

func _ready():
	# 创建shader材质
	_create_shader_material()
	
	# 如果有父节点是Sprite2D，自动应用shader
	if get_parent() is Sprite2D:
		apply_to_sprite(get_parent() as Sprite2D)

func _create_shader_material():
	# 创建shader代码
	var shader_code = """
	shader_type canvas_item;

	uniform vec4 glow_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
	uniform float glow_intensity : hint_range(0.0, 10.0) = 2.0;
	uniform float glow_radius : hint_range(1.0, 50.0) = 10.0;
	uniform float glow_falloff : hint_range(0.1, 2.0) = 0.5;
	uniform float pulse_speed : hint_range(0.0, 5.0) = 1.0;
	uniform float pulse_strength : hint_range(0.0, 1.0) = 0.3;

	void fragment() {
		vec4 original_color = texture(TEXTURE, UV);
		
		// 计算脉冲效果
		float pulse = 1.0 + pulse_strength * sin(TIME * pulse_speed);
		
		// 计算发光效果
		vec4 glow = vec4(0.0);
		float total_weight = 0.0;
		
		for (float x = -glow_radius; x <= glow_radius; x += 1.0) {
			for (float y = -glow_radius; y <= glow_radius; y += 1.0) {
				vec2 offset = vec2(x, y) / glow_radius;
				float distance = length(offset);
				
				if (distance <= 1.0) {
					vec2 sample_uv = UV + offset / glow_radius;
					vec4 sample_color = texture(TEXTURE, sample_uv);
					
					// 计算权重（距离越远权重越小）
					float weight = 1.0 - pow(distance, glow_falloff);
					weight = max(0.0, weight);
					
					glow += sample_color * weight;
					total_weight += weight;
				}
			}
		}
		
		// 归一化发光效果
		if (total_weight > 0.0) {
			glow /= total_weight;
		}
		
		// 混合原始颜色和发光效果
		vec4 final_glow = glow_color * glow * glow_intensity * pulse;
		COLOR = original_color + final_glow * (1.0 - original_color.a);
	}
	"""
	
	# 创建shader材质
	shader_material = ShaderMaterial.new()
	shader_material.shader = Shader.new()
	shader_material.shader.code = shader_code
	
	# 设置初始参数
	_update_shader_parameters()

func _update_shader_parameters():
	if shader_material:
		shader_material.set_shader_parameter("glow_color", glow_color)
		shader_material.set_shader_parameter("glow_intensity", glow_intensity)
		shader_material.set_shader_parameter("glow_radius", glow_radius)
		shader_material.set_shader_parameter("glow_falloff", glow_falloff)
		shader_material.set_shader_parameter("pulse_speed", pulse_speed)
		shader_material.set_shader_parameter("pulse_strength", pulse_strength)

func _process(delta):
	time += delta
	_update_shader_parameters()

# 应用shader到指定的Sprite2D
func apply_to_sprite(sprite: Sprite2D):
	if shader_material:
		sprite.material = shader_material

# 移除shader
func remove_from_sprite(sprite: Sprite2D):
	sprite.material = null

# 设置发光颜色
func set_glow_color(color: Color):
	glow_color = color
	_update_shader_parameters()

# 设置发光强度
func set_glow_intensity(intensity: float):
	glow_intensity = intensity
	_update_shader_parameters()

# 设置发光半径
func set_glow_radius(radius: float):
	glow_radius = radius
	_update_shader_parameters()

# 设置脉冲效果
func set_pulse(speed: float, strength: float):
	pulse_speed = speed
	pulse_strength = strength
	_update_shader_parameters()

# 获取shader材质（用于手动应用）
func get_shader_material() -> ShaderMaterial:
	return shader_material
