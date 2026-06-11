extends Node3D

@export var move_speed: float = 8.0
@export var turn_speed: float = 1.8
@export var acceleration: float = 18.0
@export var deceleration: float = 24.0
@export var steer_lerp_speed: float = 10.0

var _current_speed: float = 0.0
var _steer_input: float = 0.0


func _physics_process(delta: float) -> void:
	var throttle := Input.get_action_strength("movebackward") - Input.get_action_strength("moveforward")
	var steer_target := Input.get_action_strength("moveleft") - Input.get_action_strength("moveright")

	if throttle != 0.0:
		_current_speed = move_toward(_current_speed, throttle * move_speed, acceleration * delta)
	else:
		_current_speed = move_toward(_current_speed, 0.0, deceleration * delta)

	_steer_input = move_toward(_steer_input, steer_target, steer_lerp_speed * delta)

	rotate_y(_steer_input * turn_speed * delta)
	var forward := -global_transform.basis.z
	global_position += forward * _current_speed * delta
