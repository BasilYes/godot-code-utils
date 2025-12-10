class_name CUStateTreeNode
extends Node

signal entered
signal exited

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
			set_process_mode(Node.PROCESS_MODE_INHERIT)
			_enter()
			entered.emit()
			if not get_parent() is CUStateTreeNode:
				get_tree().physics_frame.connect(_process_substates)
		else:
			if multiple_substates:
				for i:Node in get_children():
					if not i is CUStateTreeNode:
						continue
					i.active = false
			elif active_substate:
				active_substate.active = false
				active_substate = null
			_exit()
			set_process_mode(Node.PROCESS_MODE_DISABLED)
			if not get_parent() is CUStateTreeNode:
				get_tree().physics_frame.disconnect(_process_substates)

## Reference to the currently active child state
## Only applicable when multiple_substates is false
var active_substate: CUStateTreeNode = null

func _ready() -> void:
	# Set active if root state, set process priority to process before parent
	if not get_parent() is CUStateTreeNode:
		active = true
		_process_substates()
		process_priority = get_parent().process_priority - 1
		process_physics_priority = get_parent().process_physics_priority - 1
	else:
		if not active:
			set_process_mode(Node.PROCESS_MODE_DISABLED)
		process_priority = get_parent().process_priority
		process_physics_priority = get_parent().process_physics_priority

## Virtual method called when this state is activated
## Override this method to define behavior when entered this state
func _enter() -> void:
	pass

## Virtual method called when this state is deactivated
## Override this method to define cleanup when exited this state
func _exit() -> void:
	pass

## Virtual method that determines if this state can be activated
## Override this method to define custom activation conditions
## @return true if the state can be activated, false otherwise
func _activable() -> bool:
	return true

## Virtual method that determines if this state can be deactivated
## Override this method to define custom deactivation conditions
## @return true if the state can be deactivated, false otherwise
func _deactivable() -> bool:
	return true

## Manages child state transitions
## Called before physics frame if this is a root state
## Otherwise called by parent EMStateTreeNode when this state is active
func _process_substates() -> void:
	# If current single substate can't be deactivated, process this state and exit
	if active_substate and not active_substate._deactivable() and not multiple_substates:
		active_substate._process_substates()
		return

	for i:Node in get_children():
		if not i is CUStateTreeNode:
			continue
		# Skip states that aren't activable
		if not i._activable():
			if i.active:
				if i._deactivable():
					i.active = false
				else:
					i._process_substates()
					if not multiple_substates:
						active_substate = i
						return
			continue

		# Deactivate current active substate if switching (for single state mode)
		if active_substate and i != active_substate and not multiple_substates:
			active_substate.active = false
			active_substate = null

		# Activate the state and process it's substates
		i.active = true
		i._process_substates()

		# Exit if single substate
		if not multiple_substates:
			active_substate = i
			return

	# No activable states found, deactivate current if any
	if active_substate:
		active_substate.active = false
		active_substate = null
