class_name SpinBehaviour
extends PropBehaviour

@export var spin_sensitivity: float = 0.3
@export var max_spin_speed: float = 6.0
@export var spin_damping: float = 8.0
@export var release_damping: float = 14.0 


func execute() -> void:
	if prop.interactor_ref.get_input_state("grab", "released") or prop.interactor_ref.get_input_state("throw", "just_pressed"):
		return
	
	if prop.interactor_ref.get_input_state("spin", "pressed"):
		prop.request_camera_block()
		_apply_spin_torque(spin_sensitivity, max_spin_speed, spin_damping)
	elif prop.interactor_ref.get_input_state("spin", "released"):
		prop.request_camera_release()
		prop.target_body.angular_damp = release_damping


func _apply_spin_torque(sensitivity: float, speed: float, damping: float):
	var body: RigidBody3D = prop.target_body
	var interactor: Interactor = prop.interactor_ref
	var m_delta: Vector2 = interactor.get_mouse_delta()
	var torque: Vector3 = _mouse_to_torque(m_delta, sensitivity)
	var ang_vel: Vector3 = body.angular_velocity
	
	body.apply_torque(torque)
	
	if ang_vel.length() > speed:
		body.angular_velocity = ang_vel.normalized() * speed
	body.angular_damp = damping

func _mouse_to_torque(m_delta: Vector2, sensitivity: float) -> Vector3:
	return Vector3(
		m_delta.y,
		m_delta.x,
		0.0
	) * sensitivity
