class_name Interactor
extends Node3D

signal set_camera_mov_status(active: bool)

enum RayOriginMode {
	CURSOR_MODE,
	CAMERA_MODE,
}

@export var origin := RayOriginMode.CAMERA_MODE
@export var ray_mask : int = 3
@export var ray_reach : float = 6.0

@export var input_actions : Dictionary = {
	"grab_action": "",
	"spin_action": "",
	"throw_action": "",
	"approx_action": "",
	"recede_action": "",
}

var input_state : Dictionary = {
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
	
	"mouse_delta": Vector2.ZERO,
}

var detected_prop : Prop
var current_prop : Prop

var camera_controller_ref : Script

var ray_hit_pos: Vector3


func _physics_process(_delta: float) -> void:
	_process_input()
	var res: Dictionary = _detect_prop(_get_ray_origin())
	var p: Prop = res["collider"]
	
	if current_prop == null:
		if p != detected_prop:
			if detected_prop != null:
				_unbind_prop(detected_prop)
			detected_prop = p
			if detected_prop != null:
				_bind_prop(detected_prop)
		
		if detected_prop != null:
			detected_prop.evaluate_interaction()
	else:
		current_prop.update_interaction()
	
	input_state["mouse_delta"] = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_mouse_delta(event.relative)


## Returns the state of an input action.
## [param action_name] is the action, [param state] can be
## [code]"pressed"[/code], [code]"just_pressed"[/code] or [code]"just_released"[/code].
## [codeblock lang=gdscript]
## if get_action_state("throw", "just_pressed"):
##     throw_object()
## [/codeblock]
func get_action_state(action_name: String, state: String = "pressed") -> bool:
	return input_state.get(action_name + "_" + state, false)


func get_mouse_delta() -> Vector2:
	return input_state.get("mouse_delta", Vector2.ZERO)


func _process_input() -> void:
	for action_key in input_actions:
		var action_name = action_key.replace("_action", "")
		var action = input_actions[action_key]
		
		if action == "":
			continue
		
		input_state[action_name + "_pressed"]      = Input.is_action_pressed(action)
		input_state[action_name + "_just_pressed"] = Input.is_action_just_pressed(action)
		input_state[action_name + "_released"]     = Input.is_action_just_released(action)


func _update_mouse_delta(mouse_delta: Vector2) -> void:
	input_state["mouse_delta"] += mouse_delta


func _detect_prop(ray_origin: Vector2) -> Dictionary:
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(ray_origin)
	var normal = camera.project_ray_normal(ray_origin)
	var to = from + normal * ray_reach
	ray_hit_pos = to
	var result = _cast_ray(from, to)
	
	if result:
		ray_hit_pos = result.position
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


func _get_ray_origin() -> Vector2:
	match origin:
		RayOriginMode.CURSOR_MODE:
			return get_viewport().get_mouse_position()
		RayOriginMode.CAMERA_MODE:
			return get_viewport().get_visible_rect().size / 2.0
		_:
			return Vector2.ZERO


func _bind_prop(p: Prop) -> void:
	p.connect("req_interaction_start", _on_interaction_requested)
	p.connect("req_interaction_end", _on_interaction_ended)
	p.connect("set_camera_mov_status", _on_set_camera_mov_status)
	p.interactor_ref = self


func _unbind_prop(p: Prop) -> void:
	if is_instance_valid(p):
		p.disconnect("req_interaction_start", _on_interaction_requested)
		p.disconnect("req_interaction_end", _on_interaction_ended)
		p.disconnect("set_camera_mov_status", _on_set_camera_mov_status)
		p.interactor_ref = null


func _cast_ray(start_pos: Vector3, end_pos: Vector3) -> Dictionary:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
	var result = space.intersect_ray(query)
	return result


func _on_interaction_requested() -> void:
	current_prop = detected_prop
	set_camera_mov_status.emit(true)


func _on_interaction_ended() -> void:
	current_prop = null


# Re-routes the prop signal outward, allowing the Player to handle camera
# movement blocking.
func _on_set_camera_mov_status(active: bool) -> void:
	set_camera_mov_status.emit(active)
