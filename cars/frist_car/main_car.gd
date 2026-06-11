extends CharacterBody3D

@export var move_speed: float = 8.0
@export var turn_speed: float = 1.8
@export var acceleration: float = 18.0
@export var deceleration: float = 24.0
@export var steer_lerp_speed: float = 10.0
@export var gravity: float = 9.8
@export var ground_check_distance: float = 3.0

var _current_speed: float = 0.0
var _steer_input: float = 0.0
var _ground_debug: String = "none"


func _ready() -> void:
	safe_margin = 0.02
	floor_stop_on_slope = true


func _physics_process(delta: float) -> void:
	var throttle := Input.get_action_strength("movebackward") - Input.get_action_strength("moveforward")
	var steer_target := Input.get_action_strength("moveleft") - Input.get_action_strength("moveright")
	var has_road_below := _has_road_below()

	if throttle != 0.0:
		_current_speed = move_toward(_current_speed, throttle * move_speed, acceleration * delta)
	else:
		_current_speed = move_toward(_current_speed, 0.0, deceleration * delta)

	_steer_input = move_toward(_steer_input, steer_target, steer_lerp_speed * delta)

	rotate_y(_steer_input * turn_speed * delta)

	if has_road_below and is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= gravity * delta

	var forward := -global_transform.basis.z
	velocity.x = forward.x * _current_speed
	velocity.z = forward.z * _current_speed
	move_and_slide()
	print("is_on_floor=", is_on_floor(), " road_below=", has_road_below, " ground=", _ground_debug)


func _has_road_below() -> bool:
	var space_state := get_world_3d().direct_space_state
	var from := global_position + Vector3.UP * 0.2
	var to := global_position + Vector3.DOWN * ground_check_distance
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]

	var hit := space_state.intersect_ray(query)
	if hit.is_empty():
		_ground_debug = "none"
		return false

	var collider := hit["collider"] as Node
	_ground_debug = "%s at %s" % [collider.get_path(), hit["position"]]

	while collider != null:
		if "Road" in collider.name:
			return true
		collider = collider.get_parent()

	return false
