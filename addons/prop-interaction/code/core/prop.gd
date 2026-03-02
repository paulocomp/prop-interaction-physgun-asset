################################################################################
#
# Class: Prop
# Purpose: []
#
# Signals:
#   -
#
# Attributes:
#   - target_body [Node3D]:
#   - body_layer [int]:
#   - trigger [String]:
#   - 
#   - interactor_ref [Interactor]:
#
# Methods:
#   - _get_target_body():
#
################################################################################

class_name Prop
extends Node3D

signal req_interaction_start
signal req_interaction_end

@export var target_body : RigidBody3D
@export var body_layer : int = 3
@export var trigger : String = "grab"
@export var behaviour_components: Array[Script]

var interactor_ref : Interactor


func _ready() -> void:
	_get_target_body()
	
	for bc in behaviour_components:
		bc = bc.duplicate()


func _get_target_body():
	if target_body == null:
		target_body = get_child(0)


func evaluate_interaction():
	if (interactor_ref == null):
		return
	
	if (interactor_ref.get_input_state(trigger, "just_pressed")):
		req_interaction_start.emit()
	if (interactor_ref.get_input_state(trigger, "released")):
		req_interaction_end.emit()


func update_interaction():
	for bc in behaviour_components:
		if interactor_ref.get_input_state(bc.trigger, "pressed"):
			bc.execute()
