################################################################################
#
# Class: Interactor
# Purpose: []
#
# Attributes:
#   - origin: RayOriginMode > Determines whether object detection originates 
#                             from the screen center or the cursor position.
#                             Other modes can be added in the future.
#   - reach: float          > Defines the maximum distance at which objects can
#                             be detected by the raycast.
#   - detected_prop: Prop   >
#   - current_prop: Prop    >
#
# Methods:
#   - _detect_prop() >
#   - _cast_ray()    > 
#
################################################################################

class_name Interactor
extends Node3D

enum RayOriginMode {
	CURSOR_MODE,
	CAMERA_MODE,
}

@export var origin : RayOriginMode = RayOriginMode.CAMERA_MODE
@export var reach : float = 6.0
@export var ray_mask : int = 3

var detected_prop : Prop
var current_prop : Prop


func _detect_prop(ray_origin: Vector2) -> Dictionary:
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(ray_origin)
	var normal = camera.project_ray_normal(ray_origin)
	var to = from + normal * reach
	var result = _cast_ray(from, to)
	
	if result:
		var node = result.collider as Node
		
		while node != null:
			if node is Prop:
				return {
					"collider": node as Prop,
					"position": result.position
				}
			node = node.get_parent()
		
		return {
			"collider": null,
			"position": null
		}
	
	return {
		"collider": null,
		"position": null
	}


func _cast_ray(start_pos: Vector3, end_pos: Vector3):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
	var result = space_state.intersect_ray(query)
	
	return result
