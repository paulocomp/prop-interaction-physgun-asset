extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const PITCH_LIMIT = 80.0 # deg

@export var input_actions: Dictionary = {
	"move_up": "move_up",
	"move_down": "move_down",
	"move_left": "move_left",
	"move_right": "move_right"
}

@export var mouse_sensitivity : float = 3.5
@onready var _camera_anchor : Node3D = %CameraAnchorFPS
var camera_mov_enabled: bool = true


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var input_dir := Input.get_vector(input_actions["move_left"], 
					  input_actions["move_right"],
					  input_actions["move_up"],
					  input_actions["move_down"])
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# camera_mov_enabled is used to toggle camera movement on and off
	if event is InputEventMouseMotion \
	and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED \
	and camera_mov_enabled:
		rotate_y(-event.relative.x * mouse_sensitivity * 0.001)
		_camera_anchor.rotate_x(-event.relative.y * mouse_sensitivity * 0.001)
		_camera_anchor.rotation.x = clamp(
			_camera_anchor.rotation.x,
			deg_to_rad(-PITCH_LIMIT),
			deg_to_rad(PITCH_LIMIT)
		)


func _on_interactor_set_camera_mov_status(active: bool) -> void:
	camera_mov_enabled = active
