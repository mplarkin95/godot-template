---
name: gdscript-docs
description: Look up official Godot 4.x API documentation for any class, method, property, or signal. Load this skill before writing GDScript for any class you are not 100% certain about.
tools:
  - Bash
---

# GDScript Docs Skill

Use this skill to fetch authoritative Godot 4.x API documentation before writing code.
This prevents hallucinating deprecated APIs or GDScript 1.x syntax.

## How to look up a class

Run the bash tool with the `gdoc` helper defined below. It fetches structured
docs from docs.godotengine.org for Godot 4.x and returns the class reference.

### Fetching a class page

```bash
# Fetch class reference (replace ClassName with e.g. CharacterBody2D, AnimationPlayer, etc.)
curl -s "https://docs.godotengine.org/en/stable/classes/class_$(echo 'ClassName' | tr '[:upper:]' '[:lower:]').html" \
  | python3 -c "
import sys, re
html = sys.stdin.read()

# Extract class description
desc = re.search(r'<section id=\"class-description\">(.*?)</section>', html, re.DOTALL)
if desc:
    text = re.sub(r'<[^>]+>', '', desc.group(1)).strip()
    print('=== DESCRIPTION ===')
    print(text[:1000])

# Extract properties
props = re.findall(r'<dt[^>]*>.*?<em[^>]*>([^<]+)</em>.*?<strong[^>]*>([^<]+)</strong>(.*?)</dt>', html, re.DOTALL)
if props:
    print('\n=== PROPERTIES ===')
    for type_, name, rest in props[:20]:
        print(f'  {type_.strip()} {name.strip()}')

# Extract methods
methods = re.findall(r'<dt[^>]*id=\"class-[^\"]+\"[^>]*>.*?<em[^>]*>([^<]+)</em>.*?<strong[^>]*>([^<]+)</strong>\s*\((.*?)\)', html, re.DOTALL)
if methods:
    print('\n=== METHODS ===')
    for ret, name, args in methods[:30]:
        args_clean = re.sub(r'<[^>]+>', '', args).strip()
        print(f'  {ret.strip()} {name.strip()}({args_clean})')
"
```

### Quick method lookup

```bash
# Look up a specific method — searches the class page for it
CLASS="CharacterBody2D"
METHOD="move_and_slide"
curl -s "https://docs.godotengine.org/en/stable/classes/class_$(echo $CLASS | tr '[:upper:]' '[:lower:]').html" \
  | python3 -c "
import sys, re
html = sys.stdin.read()
# Find the method section
pattern = rf'id=\"class-[^\"]*-method-{re.escape(\"$METHOD\")}\".*?(?=<dt id=|</dl>)'
match = re.search(pattern, html, re.DOTALL)
if match:
    clean = re.sub(r'<[^>]+>', '', match.group(0)).strip()
    print(clean[:2000])
else:
    print(f'Method $METHOD not found in $CLASS — check the class name or method spelling.')
"
```

### Search for a class by keyword

```bash
# If you don't know the exact class name, search the index
curl -s "https://docs.godotengine.org/en/stable/classes/index.html" \
  | grep -i "KEYWORD" \
  | python3 -c "import sys,re; [print(re.sub(r'<[^>]+>','',l).strip()) for l in sys.stdin if l.strip()]" \
  | head -20
```

## Common classes quick reference

These are well-established — you can use them without fetching docs:

| Class | Inherits | Use for |
|-------|----------|---------|
| `Node` | Object | Base of everything |
| `Node2D` | Node | 2D transforms, position/rotation/scale |
| `Node3D` | Node | 3D equivalent |
| `CharacterBody2D` | PhysicsBody2D | Player/enemy with `move_and_slide()` |
| `CharacterBody3D` | PhysicsBody3D | 3D equivalent |
| `RigidBody2D` | PhysicsBody2D | Physics-driven objects |
| `Area2D` | CollisionObject2D | Triggers, hitboxes, pickup zones |
| `AnimationPlayer` | Node | Keyframe animations |
| `AnimationTree` | Node | State machine for animations |
| `StaticBody2D` | PhysicsBody2D | Immovable terrain |
| `TileMap` | Node2D | Tile-based levels |
| `Camera2D` | Node2D | 2D camera with smoothing |
| `CanvasLayer` | Node | UI layering |
| `Control` | CanvasItem | Base UI node |
| `Label` | Control | Text display |
| `Button` | BaseButton | Clickable button |
| `AudioStreamPlayer` | Node | Sound playback |
| `GPUParticles2D` | Node2D | Particle effects |
| `Sprite2D` | Node2D | Static image display |
| `AnimatedSprite2D` | Node2D | Frame-based animation |

## GDScript 2.0 syntax cheatsheet (Godot 4.x)

```gdscript
extends CharacterBody2D

# Annotations (NOT keywords like in GDScript 1.x)
@export var speed: float = 200.0
@export_range(0, 100) var health: int = 100
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer

# Signals — define at top
signal health_changed(new_health: int)
signal died

# Constants
const GRAVITY = 980.0

# Typed variables
var direction: Vector2 = Vector2.ZERO
var is_dead: bool = false

func _ready() -> void:
    # @onready vars are safe here
    anim.play("idle")

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += GRAVITY * delta
    move_and_slide()

# Signals — new connection syntax
func _on_area_entered(area: Area2D) -> void:
    pass

# Connecting signals (NOT the old string-based syntax)
func _ready() -> void:
    some_area.body_entered.connect(_on_body_entered)
    # With a lambda:
    button.pressed.connect(func(): print("pressed"))

# Awaiting signals and coroutines
func do_thing() -> void:
    await get_tree().create_timer(1.0).timeout
    await animation_finished  # wait for a signal

# Parent method calls
func _ready() -> void:
    super()          # calls parent _ready()
    super._ready()   # explicit form

# Type casting
var body = $Body as CharacterBody2D
if body:
    body.velocity = Vector2.ZERO
```

## Godot 4 gotchas

- `get_node()` returns `null` if path wrong — no error. Always check.
- `@onready` only works for vars populated from the scene tree — not for code-created nodes.
- Signals must be explicitly connected — they don't auto-connect by method naming alone (except via editor).
- `move_and_slide()` in Godot 4 uses `velocity` property directly — no return value to assign.
- `delta` in `_physics_process` is fixed (60fps default), not variable like `_process`.
- `PackedScene.instantiate()` — not `.instance()` (that was Godot 3).
- `ResourceLoader.load()` returns `null` on failure silently — check the result.