extends Node2D

@onready var exit_button = $Control/BtnList/Exit

func _ready():
	pass

func _on_exit_button_pressed():
	# 退出游戏功能
	get_tree().quit()


func _on_exit_pressed() -> void:
	pass # Replace with function body.
