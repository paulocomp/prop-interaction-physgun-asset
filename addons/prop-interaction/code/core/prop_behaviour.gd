class_name PropBehaviour
extends Resource

@export var trigger : String = "grab"

var delta_visual : float
var delta_physics : float
var prop : Prop
var camera : Camera3D


func setup(p: Prop) -> void:
	prop = p
	camera = prop.get_viewport().get_camera_3d()
	delta_visual = prop.get_process_delta_time()
	delta_physics = prop.get_physics_process_delta_time()


func execute() -> void:
	assert(false, "PropBehaviour is an abstract base class. Use a concrete subclass.")
