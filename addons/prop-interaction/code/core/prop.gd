class_name Prop
extends Node3D

signal req_interaction_start
signal req_interaction_end

signal set_camera_mov_status(active: bool)

@export var body_layer : int = 3
@export var trigger : String = "grab"
@export var target_body : RigidBody3D
@export var behaviour_components : Array[PropBehaviour]

var interactor_ref : Interactor
var target_rest_pos_y : float
var is_spinning := false


func _ready() -> void:
	_get_target_body()
	_setup_components()


func _setup_components() -> void:
	for i in behaviour_components.size():
		behaviour_components[i] = behaviour_components[i].duplicate()
		behaviour_components[i].setup(self)


func _get_target_body() -> void:
	if target_body == null:
		target_body = get_child(0)


func _get_floor_y() -> float:
	var space = target_body.get_world_3d().direct_space_state
	var from = target_body.global_position
	var to = from + Vector3.DOWN * 100.0
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	query.exclude = [target_body.get_rid()]
	
	var result = space.intersect_ray(query)
	if result:
		return result.position.y
	return 0.0


## Evaluates the interaction state each frame based on the interactor's input.
## Requests an interaction start when the trigger is just pressed,
## and requests an interaction end when the trigger is released.
func evaluate_interaction() -> void:
	if interactor_ref == null:
		return
	if interactor_ref.get_action_state(trigger, "just_pressed"):
		request_interaction_start()
	if interactor_ref.get_action_state(trigger, "released"):
		request_interaction_end()


## Acts as a dispatcher that iterates over all behaviour components and calls
## each [PropBehaviour]'s [method execute] method when its corresponding
## trigger is held down.
func update_interaction() -> void:
	for bc in behaviour_components:
		if interactor_ref.get_action_state(bc.trigger, "pressed") \
		or interactor_ref.get_action_state(bc.trigger, "released"):
			bc.execute()


## Emits [signal set_camera_mov_status] with [code]false[/code], requesting the
## camera movement to be blocked.
func request_camera_block() -> void:
	set_camera_mov_status.emit(false)


## Emits [signal set_camera_mov_status] with [code]true[/code], requesting the
## camera movement to be released.
func request_camera_release() -> void:
	set_camera_mov_status.emit(true)


## Wrapper for the prop's [signal req_interaction_start] signal.
## Emitting a signal directly from an external script is discouraged
## in GDScript best practices: use this method instead.
func request_interaction_start() -> void:
	target_rest_pos_y = _get_floor_y()
	req_interaction_start.emit()


## Wrapper for the prop's [signal req_interaction_end] signal.
## Emitting a signal directly from an external script is discouraged
## in GDScript best practices: use this method instead.
func request_interaction_end() -> void:
	request_camera_release()
	req_interaction_end.emit()
