extends Node
@export var car_movement: CharacterBody3D
@export var speed_forward_ms: float = 0.3
@export_range(-1,1,0.1) var joystick_intensity: float = 0
@export var speed_rotate_degree: float = 90
@export_range(-1,1,0.1) var joystick_rotation_intensity: float = 0

func _ready() -> void:
	if car_movement == null:
		push_warning("Character not found!")
		
func set_joystick_forward(percent: float):
	joystick_intensity = percent
		
func set_joystick_rotate(percent: float):
	joystick_rotation_intensity = percent
		
func set_joystick_with_vector2(joystick: Vector2):
	joystick_rotation_intensity = joystick.x
	joystick_intensity = joystick.y

func _process(delta: float) -> void:
	var position: Vector3 = car_movement.position
	var direction_forward: Vector3 = -car_movement.basis.z
	direction_forward.y = 0
	position = position + direction_forward * speed_forward_ms * joystick_intensity * delta
	car_movement.position = position
	car_movement.rotate_y(deg_to_rad(speed_rotate_degree) * delta * -joystick_rotation_intensity)
