class_name ThrowBehaviour
extends PropBehaviour

@export var throw_force: float = 8.0


func execute() -> void:
	throw(throw_force)
	prop.request_interaction_end()


func throw(force: float) -> void:
	var dir: Vector3 = -camera.global_transform.basis.z
	prop.target_body.linear_velocity = Vector3.ZERO
	prop.target_body.apply_central_impulse(dir.normalized() * force)
