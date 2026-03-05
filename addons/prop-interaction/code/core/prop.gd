class_name Prop
extends Node3D

signal req_interaction_start
signal req_interaction_end

signal set_camera_mov_status(active: bool)

@export var target_body : RigidBody3D
@export var body_layer : int = 3
@export var trigger : String = "grab"
@export var behaviour_components : Array[PropBehaviour]

var interactor_ref : Interactor
var target_rest_pos_y : float

func _ready() -> void:
	_get_target_body()
	_setup_components()
	
	target_rest_pos_y = target_body.global_transform.origin.y


func _setup_components() -> void:
	for i in behaviour_components.size():
		behaviour_components[i] = behaviour_components[i].duplicate()
		behaviour_components[i].setup(self)


func _get_target_body() -> void:
	if target_body == null:
		target_body = get_child(0)


## Evaluates the interaction state each frame based on the interactor's input.
## Requests an interaction start when the trigger is just pressed,
## and requests an interaction end when the trigger is released.
func evaluate_interaction() -> void:
	if interactor_ref == null:
		return
	if interactor_ref.get_input_state(trigger, "just_pressed"):
		request_interaction_start()
	if interactor_ref.get_input_state(trigger, "released"):
		request_interaction_end()


## Acts as a dispatcher that iterates over all behaviour components and calls
## each [PropBehaviour]'s [method execute] method when its corresponding
## trigger is held down.
func update_interaction() -> void:
	for bc in behaviour_components:
		if interactor_ref.get_input_state(bc.trigger, "pressed"):
			bc.execute()


## Emits [signal set_camera_mov_status] with [code]false[/code], requesting the
## camera movement to be blocked.
func request_camera_block() -> void:
	set_camera_mov_status.emit(false)


## Emits [signal set_camera_mov_status] with [code]true[/code], requesting the
## camera movement to be released.
func request_camera_release() -> void:
	set_camera_mov_status.emit(true)


## Emits [signal req_interaction_start], requesting the interaction to begin.
func request_interaction_start() -> void:
	req_interaction_start.emit()


## Emits [signal req_interaction_end], requesting the interaction to end.
func request_interaction_end() -> void:
	req_interaction_end.emit()
