class_name CUStateTreeNode
extends Node

signal enter
signal exit

## Controls whether multiple child states can be active simultaneously
## If true, allows multiple active substates at the same time
## If false, only one child state can be active at a time
@export var multiple_substates: bool = false

## Determines if this node is currently active in the state tree
## For root states (without a parent state), this can be set directly
@export var active: bool = false :
	set(value):
		if value == active:
			return
		active = value
		if active:
			_enter_state()
			enter.emit()
			set_process_mode(Node.PROCESS_MODE_INHERIT)
			if not get_parent() is CUStateTreeNode and is_node_ready():
				get_tree().physics_frame.connect(_process_state)
		else:
			if multiple_substates:
				for i in children:
					i.active = false
			elif active_substate:
				active_substate.active = false
				active_substate = null
			_exit_state()
			exit.emit()
			set_process_mode(Node.PROCESS_MODE_DISABLED)
			if not get_parent() is CUStateTreeNode and is_node_ready():
				get_tree().physics_frame.disconnect(_process_state)

## Contains all child nodes that are also EMStateTreeNodes
## This array is populated automatically during _ready()
var children: Array[CUStateTreeNode]

## Reference to the currently active child state
## Only applicable when multiple_substates is false
var active_substate: CUStateTreeNode = null


func _ready() -> void:
	# Collect all child states
	for i:Node in get_children():
		if i is CUStateTreeNode:
			children.append(i)
	# Child states start inactive by default
	if not get_parent() is CUStateTreeNode:
		active = true
	# Root states connect to physics frame for processing
	elif active:
		get_tree().physics_frame.connect(_process_state)
		_process_state()

## Virtual method called when this state is activated
## Override this method to define behavior when entering this state
func _enter_state() -> void:
	pass


## Virtual method called when this state is deactivated
## Override this method to define cleanup when exiting this state
func _exit_state() -> void:
	pass


## Processes the state logic and manages child state transitions
## Called on physics frame if this is a root state
## Otherwise called by parent EMStateTreeNode when this state is active
func _process_state() -> void:
	if not children:
		return
	for i:CUStateTreeNode in children:
		# Skip states that aren't activable
		if not i._activable():
			if i.active:
				if i._deactivable():
					i.active = false
					if not multiple_substates:
						active_substate = null
				else:
					i._process_state()
					if not multiple_substates:
						return
			continue
		# Skip if this state is already the active substate (for single state mode)
		if i == active_substate and not multiple_substates:
			i._process_state()
			return
		# Deactivate current active substate if switching (for single state mode)
		elif active_substate and active_substate.active:
			if active_substate._deactivable():
				active_substate.active = false
			else:
				active_substate._process_state()
				return
		# Activate the state and process its logic
		i.active = true
		i._process_state()
		# Update active substate reference and exit (for single state mode)
		if not multiple_substates:
			active_substate = i
			return
	# No activable states found, deactivate current if any
	if active_substate:
		active_substate.active = false
		active_substate = null


## Virtual method that determines if this state can be activated
## Override this method to define custom activation conditions
## @return true if the state can be activated, false otherwise
func _activable() -> bool:
	return true


func _deactivable() -> bool:
	return true
