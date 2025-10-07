extends VBoxContainer

@onready var children_v_box: VBoxContainer = $MarginContainer/ChildrenVBox

@export var state: CUStateTreeNode = null


func _ready() -> void:
	var root: Node = null
	if not state:
		if get_parent() is CUStateTreeNode:
			state = get_parent()
		else:
			root = get_parent()
	%CheckBox.disabled = true
	if state:
		%CheckBox.text = state.name
	else:
		%CheckBox.text = "StatesRooot"
		$HBoxContainer.visible = false
		($MarginContainer as MarginContainer).set(&"theme_override_constants/margin_left", 0)
	for i in state.get_children() if state else get_parent().get_children():
		if i is CUStateTreeNode:
			var new: = preload("uid://chh6i48wv8iix").instantiate()
			new.state = i
			%ChildrenVBox.add_child(new)
	#$HBoxContainer/Label.text = state.name


func _process(delta: float) -> void:
	if state:
		%CheckBox.button_pressed = state.active
