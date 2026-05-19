extends Node3D

@export var pivot: Node3D
@export var speed_rotation_max: float = 720
@export var invert_rotation: bool
@export_group("debug")
@export var actual_rotation: float

func set_rotation_percent(percent: float):
	actual_rotation = speed_rotation_max * percent
	
func _process(delta: float) -> void:
	var multiple: float = -1 if invert_rotation else 1
	pivot.rotate_x(deg_to_rad(actual_rotation * delta * multiple))
