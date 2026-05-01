class_name UIManagerSingleton extends Node

signal screen_pushed(screen: Node)
signal screen_popped(screen: Node)

const BASE_LAYER := 10

class ScreenEntry:
	var layer: CanvasLayer
	var screen: Node
	var pauses_game: bool

	func _init(l: CanvasLayer, s: Node, p: bool) -> void:
		layer = l
		screen = s
		pauses_game = p

var _stack: Array[ScreenEntry] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func push_screen(scene: PackedScene, pause: bool = true) -> void:
	var layer := CanvasLayer.new()
	layer.layer = BASE_LAYER + _stack.size()
	layer.process_mode = Node.PROCESS_MODE_ALWAYS

	var screen := scene.instantiate()
	screen.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.add_child(screen)
	add_child(layer)

	var entry := ScreenEntry.new(layer, screen, pause)
	_stack.append(entry)

	if screen.has_signal("close_requested"):
		screen.close_requested.connect(pop_screen)

	screen_pushed.emit(screen)

	if pause:
		get_tree().paused = true


func pop_screen() -> void:
	if _stack.is_empty():
		return

	var entry: ScreenEntry = _stack.pop_back()
	screen_popped.emit(entry.screen)
	entry.layer.queue_free()
	_sync_pause_state()


func clear() -> void:
	while not _stack.is_empty():
		pop_screen()


func _sync_pause_state() -> void:
	var should_pause := false
	for entry: ScreenEntry in _stack:
		if entry.pauses_game:
			should_pause = true
			break
	get_tree().paused = should_pause
