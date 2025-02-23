class_name StateController extends Node

var actor: Node
@export var initial_state: StateNode
var current_state: StateNode

signal state_changed(new_state: StateNode)
var states: Dictionary = {}
func _ready():
	actor = get_parent()
	for child in get_children():
		child.actor = actor
		child.controller = self
		states[child.state_name] = child
	change_state(initial_state)

func _input(event: InputEvent):
	if current_state:
		current_state.input(event)

func _process(_delta: float) -> void:
	if current_state:
		current_state.process(_delta)

func _physics_process(_delta: float) -> void:
	if current_state:
		current_state.physics_update(_delta)

func transition_state_string(state_string: String) -> void:
	var next_state_node = states.get(state_string)
	if (!next_state_node):
		assert(false, "State not found: " + state_string)
	change_state(next_state_node)

func change_state(new_state: StateNode):
	if current_state:
		current_state.exit()
	current_state = new_state
	state_changed.emit(current_state)
	current_state.enter()
