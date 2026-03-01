################################################################################
#
# Class: Prop
# Purpose: []
#
# Attributes:
#   - target_body: Node3D >
#   - body_layer: int     >
#
# Methods:
#   -
#
################################################################################

class_name Prop
extends Node

@export var target_body : Node3D
@export var body_layer : int = 3


func _ready() -> void:
	get_target_body()
	get_adapter()


func get_target_body():
	if target_body == null:
		target_body = get_child(0)


func get_adapter() -> Resource:
	return null
