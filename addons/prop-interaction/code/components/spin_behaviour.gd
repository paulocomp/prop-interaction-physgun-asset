class_name SpinBehaviour
extends PropBehaviour

@export var spin_sensitivity: float = 0.2
@export var max_spin_speed: float = 6.0
@export var spin_damping: float = 8.0
@export var release_damping: float = 14.0 

var _prop_pre_spin_pos: Vector3 = Vector3.ZERO
var _cursor_pre_spin_pos: Vector2 = Vector2.ZERO


func execute() -> void:
	# GUARD CLAUSE FROM OTHER COMPONENTS
	if prop.interactor_ref.get_action_state("grab", "released") \
	or prop.interactor_ref.get_action_state("throw", "just_pressed"):
		return
	
	var origin_mode := prop.interactor_ref.origin
	
	# WHEN SPIN STARTS
	if prop.interactor_ref.get_action_state("spin", "just_pressed"):
		_prop_pre_spin_pos = prop.target_body.global_position
		_cursor_pre_spin_pos = \
			prop.interactor_ref.get_viewport().get_mouse_position()
		
		prop.target_body.global_position = _prop_pre_spin_pos
		prop.target_body.linear_velocity = Vector3.ZERO
		
	if prop.interactor_ref.get_action_state("spin", "pressed"):
		if origin_mode == prop.interactor_ref.RayOriginMode.CURSOR_MODE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			prop.target_body.gravity_scale = 0.0
			prop.target_body.linear_velocity = Vector3.ZERO
			prop.is_spinning = true
		prop.request_camera_block()
		_apply_spin_torque(spin_sensitivity, max_spin_speed, spin_damping)
	
	# WHEN SPIN ENDS
	if prop.interactor_ref.get_action_state("spin", "released"):
		if origin_mode == prop.interactor_ref.RayOriginMode.CURSOR_MODE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.warp_mouse(_cursor_pre_spin_pos)
			prop.target_body.gravity_scale = 1.0
		prop.request_camera_release()
		prop.target_body.angular_damp = release_damping
		prop.is_spinning = false


func _apply_spin_torque(sensitivity: float, speed: float, damping: float):
	var body: RigidBody3D = prop.target_body
	var interactor: Interactor = prop.interactor_ref
	var mouse_delta: Vector2 = interactor.get_mouse_delta()
	var torque: Vector3 = _mouse_to_torque(mouse_delta, sensitivity)
	var ang_vel: Vector3 = body.angular_velocity
	
	body.apply_torque(torque)
	
	if ang_vel.length() > speed:
		body.angular_velocity = ang_vel.normalized() * speed
	body.angular_damp = damping


func _mouse_to_torque(mouse_delta: Vector2, sensitivity: float) -> Vector3:
	return Vector3(
		mouse_delta.y,
		mouse_delta.x,
		0.0
	) * sensitivity
