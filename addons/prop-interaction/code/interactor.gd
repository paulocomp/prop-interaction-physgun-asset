################################################################################
#
# Class: Interactor
# Purpose: []
#
# Signals:
#   -
#
# Attributes:
#   - origin: RayOriginMode     > Determines whether object detection originates 
#                                 from the screen center or the cursor position.
#                                 Other modes can be added in the future.
#   - reach: float              > Defines the maximum distance at which objects
#                                 can be detected by the DSS raycast.
#   - ray_mask: int             > DSS raycast collision mask for interaction
#                                 with Props. 
#   - input_actions: Dictionary > 
#   - input_state: Dictionary   > 
#   - detected_prop: Prop       >
#   - current_prop: Prop        >
#
# Methods:
#   - get_input_state()     >
#   - _update_input_state() >
#   - _detect_prop()        >
#   - _cast_ray()           > 
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

@export var input_actions : Dictionary = {
	"grab_action": "",
	"spin_action": "",
	"throw_action": "",
	"approx_action": "",
	"recede_action": "",
}

@export var input_state : Dictionary = {
	"grab_pressed": false,
	"grab_just_pressed": false,
	"grab_released": false,
	
	"spin_pressed": false,
	"spin_just_pressed": false,
	"spin_released": false,
	
	"throw_pressed": false,
	"throw_just_pressed": false,
	"throw_released": false,
	
	"approx_pressed": false,
	"approx_just_pressed": false,
	"approx_released": false,
	
	"recede_pressed": false,
	"recede_just_pressed": false,
	"recede_released": false,
}

var detected_prop : Prop
var current_prop : Prop


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventAction:
		var action = event.action
		
		if action == input_actions["grab_action"]:
			_update_input_state("grab", event)
		elif action == input_actions["spin_action"]:
			_update_input_state("spin", event)
		elif action == input_actions["throw_action"]:
			_update_input_state("throw", event)
		elif action == input_actions["approx_action"]:
			_update_input_state("approx", event)
		elif action == input_actions["recede_action"]:
			_update_input_state("recede", event)
	
	if event is InputEventMouseMotion:
		# for the spin
		pass


func get_input_state(action_name: String) -> bool:
	return input_state.get(action_name + "_pressed", false)


func _update_input_state(action_name: String, event: InputEventAction) -> void:
	input_state[action_name + "_pressed"] = event.pressed
	input_state[action_name + "_just_pressed"] = event.pressed and not event.echo
	input_state[action_name + "_released"] = not event.pressed


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


func _cast_ray(start_pos: Vector3, end_pos: Vector3):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
	var result = space_state.intersect_ray(query)
	
	return result
