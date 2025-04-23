extends VBoxContainer

@onready var children_v_box: VBoxContainer = $MarginContainer/ChildrenVBox

@export var state: CUStateTreeNode = null


func _ready() -> void:
	if not state:
		if get_parent() is CUStateTreeNode:
			state = get_parent()
		else:
			return
	%CheckBox.text = state.name
	#$HBoxContainer/Label.text = state.name
	for i in state.get_children():
		if i is CUStateTreeNode:
			var new: = preload("uid://chh6i48wv8iix").instantiate()
			new.state = i
			%ChildrenVBox.add_child(new)


func _process(delta: float) -> void:
	if state:
		%CheckBox.button_pressed = state.active
