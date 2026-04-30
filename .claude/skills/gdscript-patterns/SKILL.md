---
name: gdscript-patterns
description: Common GDScript 2.0 patterns for game systems — state machines, singleton autoloads, resource-based data, object pooling, event bus. Load when implementing game architecture or systems.
tools:
  - Read
  - Bash
---

# GDScript Patterns

Proven patterns for Godot 4 game systems. All code is GDScript 2.0.

## State Machine (for actors)

```gdscript
# scripts/actors/player_state_machine.gd
class_name PlayerStateMachine
extends Node

enum State { IDLE, WALK, JUMP, FALL, ATTACK, DEAD }

@export var initial_state: State = State.IDLE

var current_state: State
var previous_state: State

signal state_changed(from: State, to: State)

func _ready() -> void:
    current_state = initial_state

func transition_to(new_state: State) -> void:
    if new_state == current_state:
        return
    previous_state = current_state
    current_state = new_state
    state_changed.emit(previous_state, current_state)
    _on_state_enter(new_state)

func _on_state_enter(state: State) -> void:
    match state:
        State.IDLE:   get_parent().play_animation("idle")
        State.WALK:   get_parent().play_animation("walk")
        State.JUMP:   get_parent().play_animation("jump")
        State.ATTACK: get_parent().play_animation("attack")
        State.DEAD:   get_parent().play_animation("death")
```

## Singleton / Autoload pattern

```gdscript
# scripts/autoload/game_manager.gd
# Add to Project > Project Settings > Autoload as "GameManager"
extends Node

signal game_paused(is_paused: bool)
signal level_completed(level_id: String)

var current_level: String = ""
var score: int = 0
var is_paused: bool = false

func pause_game() -> void:
    is_paused = !is_paused
    get_tree().paused = is_paused
    game_paused.emit(is_paused)

func load_level(level_path: String) -> void:
    current_level = level_path
    get_tree().change_scene_to_file(level_path)

# Access from anywhere:
# GameManager.score += 10
# GameManager.level_completed.connect(_on_level_done)
```

## Resource-based data (items, stats, etc.)

```gdscript
# scripts/resources/item_data.gd
class_name ItemData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var max_stack: int = 1
@export var value: int = 0

# Create .tres files in Godot editor or via:
# var item = ItemData.new()
# item.id = "sword_01"
# ResourceSaver.save(item, "res://resources/items/sword_01.tres")
```

## Event Bus (decoupled communication)

```gdscript
# scripts/autoload/event_bus.gd
# Add to Autoload as "EventBus"
extends Node

# Declare all game-wide signals here
signal enemy_died(enemy_id: String, position: Vector2)
signal player_health_changed(new_health: int, max_health: int)
signal item_collected(item_data: ItemData)
signal dialogue_started(dialogue_id: String)
signal dialogue_ended

# Usage from any script:
# EventBus.enemy_died.emit("goblin_01", global_position)
# EventBus.enemy_died.connect(_on_any_enemy_died)
```

## Object Pool (for bullets, particles, etc.)

```gdscript
# scripts/systems/object_pool.gd
class_name ObjectPool
extends Node

@export var scene: PackedScene
@export var initial_size: int = 20

var _pool: Array[Node] = []

func _ready() -> void:
    for i in initial_size:
        _create_instance()

func _create_instance() -> Node:
    var instance = scene.instantiate()
    instance.process_mode = Node.PROCESS_MODE_DISABLED
    add_child(instance)
    _pool.append(instance)
    return instance

func acquire() -> Node:
    for obj in _pool:
        if obj.process_mode == Node.PROCESS_MODE_DISABLED:
            obj.process_mode = Node.PROCESS_MODE_INHERIT
            return obj
    # Pool exhausted — grow it
    var new_obj = _create_instance()
    new_obj.process_mode = Node.PROCESS_MODE_INHERIT
    return new_obj

func release(obj: Node) -> void:
    obj.process_mode = Node.PROCESS_MODE_DISABLED
```

## Scene transition with loading screen

```gdscript
# scripts/autoload/scene_loader.gd
extends Node

signal load_progress(progress: float)
signal load_complete

var _target_scene: String = ""

func load_scene(path: String) -> void:
    _target_scene = path
    ResourceLoader.load_threaded_request(path)
    set_process(true)

func _process(_delta: float) -> void:
    var progress = []
    var status = ResourceLoader.load_threaded_get_status(_target_scene, progress)
    match status:
        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            load_progress.emit(progress[0])
        ResourceLoader.THREAD_LOAD_LOADED:
            set_process(false)
            var scene = ResourceLoader.load_threaded_get(_target_scene)
            get_tree().change_scene_to_packed(scene)
            load_complete.emit()
        ResourceLoader.THREAD_LOAD_FAILED:
            set_process(false)
            push_error("Failed to load scene: " + _target_scene)
```