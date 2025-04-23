extends Control


@export var properties: Array[String] = []
@export var target: Node = null :
	set(value):
		if target == value:
			return
		target = value
		for i in $VBoxContainer.get_children():
			i.queue_free()
		if not target:
			return
		for i in properties:
			var new: = preload("uid://domfkx3i2egcg").instantiate()
			$VBoxContainer.add_child(new)


func _process(_delta: float) -> void:
	if not target:
		return
	for i in properties.size():
		$VBoxContainer.get_child(i).get_node("./NameLabel").text = properties[i]
		$VBoxContainer.get_child(i).get_node("./ValueLabel").text = str(target.get_indexed(properties[i]))
