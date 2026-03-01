################################################################################
#
# Class: Prop
# Purpose: []
#
# Signals:
#   -
#
# Attributes:
#   - target_body: Node3D >
#   - body_layer: int     >
#
# Methods:
#   - get_target_body() >
#
################################################################################

class_name Prop
extends Node

@export var target_body : RigidBody3D
@export var body_layer : int = 3


func _ready() -> void:
	get_target_body()


func get_target_body():
	if target_body == null:
		target_body = get_child(0)
