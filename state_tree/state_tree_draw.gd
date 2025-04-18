extends VBoxContainer

@onready var children_v_box: VBoxContainer = $MarginContainer/ChildrenVBox

@export var state: CUStateTreeNode = null


func _ready() -> void:
	$HBoxContainer/CheckBox.text = state.name
	#$HBoxContainer/Label.text = state.name
	for i in state.get_children():
		if i is CUStateTreeNode:
			var new: = preload("uid://chh6i48wv8iix").instantiate()
			new.state = i
			$MarginContainer/ChildrenVBox.add_child(new)


func _process(delta: float) -> void:
	if state:
		$HBoxContainer/CheckBox.button_pressed = state.active
