extends Node

signal left_hand_joystick_update(L_joystick: Vector2)
signal right_hand_joystick_update(R_joystick: Vector2)
signal left_hand_trigger_update(L_Trigger: float)
signal right_hand_trigger_update(R_Trigger: float)

@export var left_hand: XRController3D
@export var right_hand: XRController3D
@export var left_joystick_label_debug: Label3D
@export var right_joystick_label_debug: Label3D
@export var left_trigger_label_debug: Label3D
@export var right_trigger_label_debug: Label3D

var previous_right_joystick_state: Vector2
var previous_left_joystick_state: Vector2
var previous_right_trigger_state: float
var previous_left_trigger_state: float

func _process(delta: float) -> void:
	var R_joystick: Vector2 = get_right_joystick_2d_value()
	if previous_right_joystick_state != R_joystick:
		previous_right_joystick_state = R_joystick
		right_hand_joystick_update.emit(R_joystick)
	if right_joystick_label_debug != null :
		right_joystick_label_debug.text = "R_joystick:" + str(R_joystick)
		
	var L_joystick: Vector2 = get_left_joystick_2d_value()
	if previous_left_joystick_state != L_joystick:
		previous_left_joystick_state = L_joystick
		left_hand_joystick_update.emit(L_joystick)
	if left_joystick_label_debug != null :
		left_joystick_label_debug.text = "L_joystick:" + str(L_joystick)
		
	var R_Trigger: float = get_right_trigger_value()
	right_hand_trigger_update.emit(R_Trigger)
	if right_joystick_label_debug != null :
		right_joystick_label_debug.text = "R_Trigger:" + str(R_Trigger)
		
	var L_Trigger: float = get_left_trigger_value()
	left_hand_trigger_update.emit(L_Trigger)
	if left_joystick_label_debug != null :
		left_joystick_label_debug.text = "R_Trigger:" + str(L_Trigger)
		
	# --- Listen to the JOYSTICKS ---
	# RIGHT
func get_right_joystick_2d_value() -> Vector2:
	if not right_hand:
		return Vector2.ZERO
	
	for name in ["primary", "thumbstick", "joystick", "secondary"]:
		var value = right_hand.get_vector2(name)
		if value.length() > 0.01:   # small deadzone
			return value
	return Vector2.ZERO
	
	# LEFT
func get_left_joystick_2d_value() -> Vector2:
	if not left_hand:
		return Vector2.ZERO
	
	for name in ["primary", "thumbstick", "joystick", "secondary"]:
		var value = left_hand.get_vector2(name)
		if value.length() > 0.01:
			return value
	return Vector2.ZERO
	
	# --- Listen to TRIGGERS ---
	# LEFT
func get_left_trigger_value() -> float:
	if not left_hand:
		return 0.0
	return left_hand.get_float("trigger")
	
	# RIGHT
func get_right_trigger_value() -> float:
	if not right_hand:
		return 0.0
	return right_hand.get_float("trigger")
