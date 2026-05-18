extends Node
@export var character: CharacterBody3D

func _ready() -> void:
	if character == null:
		push_warning("Character not found!")
		
func _process(delta: float) -> void:
	var position: Vector3 = character.position
	position = position + Vector3(0,0,-1) * delta
	character.position = position
