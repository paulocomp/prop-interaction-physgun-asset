extends Label

@export var interactor_ref : Interactor


func node_name(node: Node) -> String:
	return str(node.name) if is_instance_valid(node) else "<NULL>"


func _process(_delta: float) -> void:
	text = "DetectedProp: %s\nCurrent Prop: %s" % [
		node_name(interactor_ref.detected_prop),
		node_name(interactor_ref.current_prop),
	]
