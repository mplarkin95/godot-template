class_name StateNode extends Node


## The object that this state operates on
var actor: Node
var controller: StateController

## Name of this state, used for debugging and state management
@export var state_name: String

func _ready() -> void:
	# Verify state name is set
	if !state_name:
		push_error("State name not set for state: " + name)

## Called when entering this state
## @virtual
func enter() -> void:
	pass

## Called when exiting this state
## @virtual
func exit() -> void:
	pass

## Updates state physics
## @param delta Time since last physics update
## @return String|null The name of the next state to transition to, or null if staying in current state
## @virtual
func physics_update(_delta: float):
	return

## Updates state logic
## @param delta Time since last process update
## @return String|null The name of the next state to transition to, or null if staying in current state
## @virtual
func process(_delta: float):
	return