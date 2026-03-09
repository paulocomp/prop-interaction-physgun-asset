class_name GrabBehaviour
extends PropBehaviour

@export var spring_strength: float = 120.0
@export var grab_damping: float = 15.0
@export var hover_height: float = 0.3
@export var min_distance: float = 1.0
@export var max_distance: float = 3.0
@export var min_hover: float = 0.1
@export var max_hover: float = 3.0

var _grab_dist: float = 2.0
var _grab_target_dist: float = 2.0
var _current_hover: float = 0.3
var _target_hover: float = 0.3
var _initialized: bool = false


func execute() -> void:
	if prop.is_spinning:
		return
	
	if prop.interactor_ref.get_action_state(prop.trigger, "released"):
		_initialized = false
		prop.request_interaction_end()
		return
	
	if not _initialized:
		_target_hover = hover_height
		_current_hover = hover_height
		_initialized = true
	
	if prop.interactor_ref.get_action_state("approx", "just_pressed"):
		_approx_object()
	if prop.interactor_ref.get_action_state("recede", "just_pressed"):
		_recede_object()
	
	var origin_mode := prop.interactor_ref.origin
	var pos := Vector3.ZERO
	
	match origin_mode:
		prop.interactor_ref.RayOriginMode.CURSOR_MODE:
			_target_hover = clamp(_target_hover, min_hover, max_hover)
			_current_hover = lerp(_current_hover, _target_hover, 0.2)
			pos = _calculate_target_pos()
		prop.interactor_ref.RayOriginMode.CAMERA_MODE:
			_grab_target_dist = clamp(
				_grab_target_dist, 
				min_distance, 
				max_distance
			)
			_grab_dist = lerp(_grab_dist, _grab_target_dist, 0.1)
			pos = Vector3.INF
		_:
			return
	
	_create_joint(_grab_dist, grab_damping, spring_strength, pos)


func _create_joint(
		dist: float, 
		damping: float, 
		strength: float, 
		target_pos: Vector3 = Vector3.INF
	) -> void:
	
	if target_pos == Vector3.INF and camera != null:
		target_pos = camera.global_transform.origin - \
		camera.global_transform.basis.z * dist
	
	var diff: Vector3 = target_pos - prop.target_body.global_transform.origin
	var vel: Vector3 = prop.target_body.linear_velocity
	var force: Vector3 = (diff * strength) - (vel * damping)
	
	prop.target_body.apply_central_force(force)


func _calculate_target_pos() -> Vector3:
	var mouse_pos = prop.interactor_ref.get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var normal = camera.project_ray_normal(mouse_pos)
	var rest_y = prop.target_rest_pos_y + _current_hover
	var plane = Plane(Vector3.UP, rest_y)
	var intersection = plane.intersects_ray(from, normal)
	
	if intersection:
		return intersection
	return prop.target_body.global_position


func _approx_object() -> void:
	_target_hover += 0.3
	_grab_target_dist -= 0.5


func _recede_object() -> void:
	_target_hover -= 0.3
	_grab_target_dist += 0.5
