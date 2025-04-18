extends Node


var mouse_mode : Input.MouseMode
var catch_inputs: bool = false

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and not catch_inputs:
		if event.pressed and event.keycode == KEY_DELETE:
			mouse_mode = Input.mouse_mode
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			catch_inputs = true
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and catch_inputs:
		if event.pressed:
			Input.mouse_mode = mouse_mode
			catch_inputs = false
			get_viewport().set_input_as_handled()
	if catch_inputs:
		get_viewport().set_input_as_handled()
