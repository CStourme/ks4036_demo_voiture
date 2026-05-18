extends Node

signal joystick_update(joystick: Vector2)

@export var inputmap_rotate_left: String = "rotate_left"
@export var inputmap_rotate_right: String = "rotate_right"
@export var inputmap_move_forward: String = "move_forward"
@export var inputmap_move_backward: String = "move_backward"


func _process(delta: float) -> void:
	var joystick: Vector2 = Input.get_vector(
		inputmap_rotate_left,
		inputmap_rotate_right,
		inputmap_move_backward,
		inputmap_move_forward)
		
	joystick_update.emit(joystick)
