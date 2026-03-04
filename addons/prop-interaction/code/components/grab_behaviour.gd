class_name GrabBehaviour
extends PropBehaviour

@export var spring_strength: float = 120.0
@export var grab_damping: float = 15.0
@export var min_distance: float = 1.0
@export var max_distance: float = 3.0

var _grab_dist: float = 2.0


func execute() -> void:
	_apply_grab_force(_grab_dist, grab_damping, spring_strength)


func _apply_grab_force(dist: float, damping: float, strength: float, target_pos: Vector3 = Vector3.INF) -> void:
	if target_pos == Vector3.INF and camera != null:
		target_pos = camera.global_transform.origin + camera.global_transform.basis.z * -dist
	else:
		return
	
	var diff: Vector3 = target_pos - prop.target_body.global_transform.origin
	var force: Vector3 = _spring(diff, prop.target_body.linear_velocity, strength, damping)
	
	prop.target_body.apply_central_force(force)


func _spring(diff: Vector3, vel: Vector3, strength: float, damping: float) -> Vector3:
	return (diff * strength) - (vel * damping)
