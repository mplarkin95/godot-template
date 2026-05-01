# Godot AI Toolkit

> **TEMPLATE REPO** — This repository is a reusable starting point, not a game itself.
> If you are working in a repo created *from* this template, replace this notice and the
> "What this project is" section below with a description of your actual game before
> doing anything else. Claude uses this file to understand what it is building.

## First-time setup (after cloning from template)
1. Update `config/name` in [project.godot](project.godot) with your game's title.
2. Replace the "What this project is" section below with a one-paragraph description of your game (genre, core loop, target feel).
3. Delete this "First-time setup" section once done.

## What this project is
AI-assisted Godot 4 game development toolkit. Claude Code is connected to a live
Godot editor via godot-ai MCP, Blender via blender-mcp, and Aseprite via pixel-plugin.

## Godot version
Godot 4.4+ (GDScript 2.0 only — never write GDScript 1.x syntax)

## MCP servers active in this project
- `godot-ai`  → live editor bridge (scenes, nodes, scripts, signals, animations)
- `blender`   → 3D asset creation and manipulation
- `aseprite`  → pixel art, sprites, spritesheets, animations

## Key rules before writing any GDScript

**Always use the gdscript-docs skill before writing code for an unfamiliar class.**
Run: `/skills gdscript-docs` and look up the class via the `gdoc` tool.
This prevents hallucinating deprecated or GDScript 1.x API.

GDScript 2.0 must-knows:
- `onready var` is now `@onready var`
- `export var` is now `@export var`
- `yield()` is gone — use `await`
- `connect(signal, self, "method")` is gone — use `signal.connect(callable)`
- Type annotations are strongly preferred: `var speed: float = 200.0`
- Use `super()` not `._function()` for parent calls

## Project structure conventions
```
res://
├── src/
│   ├── Autoload/         # Singletons (EventBus, AudioManager, SceneTransitionManager, GlobalEffects)
│   ├── Components/       # Reusable node components (e.g. state machine)
│   ├── Scenes/           # Game scenes
│   ├── UI/               # Control nodes, menus, HUD
│   │   ├── components/   # Reusable UI sub-scenes
│   │   └── screens/      # Full-screen UI scenes (menus, settings)
│   ├── Resources/        # .tres resource files
│   ├── Shaders/          # Shader files
│   │   └── 2d/
│   └── Utils/            # Stateless utility scripts
├── assets/
│   ├── sprites/          # Aseprite exports (.png + .json spritesheets)
│   ├── models/           # Blender exports (.glb)
│   ├── sound/
│   │   ├── music/        # Background tracks (mp3/wav/ogg)
│   │   └── sfx/          # Sound effects (mp3/wav/ogg)
│   └── fonts/
└── scripts/              # Shell/tooling scripts (not GDScript)
```

## Node naming conventions
- Scenes: PascalCase (`PlayerCharacter.tscn`)
- Nodes: PascalCase (`HealthBar`, `AnimationPlayer`)
- Scripts: snake_case (`player_character.gd`)
- Groups: snake_case strings (`"enemies"`, `"collectibles"`)

## Signal conventions
- Names: past tense snake_case (`health_changed`, `enemy_died`)
- Always define signals at top of script before variables
- Prefer signals over direct node references across scene boundaries

## DO NOT
- Write `$NodePath` references in `_init()` — use `@onready` or `_ready()`
- Use `get_node()` chains — use `@onready` vars and cache them
- Reference nodes by absolute paths `/root/Main/...` — use groups or signals
- Import .blend files directly — export to .glb first via Blender MCP
- Commit .import files — Godot regenerates these

## When adding a new feature
1. Check gdscript-docs skill for any unfamiliar classes
2. Use godot-ai MCP to create scene/nodes in the live editor
3. Write the GDScript — run syntax validation via MCP before saving
4. Wire signals in the editor via MCP, not hardcoded in script
5. Test by running the scene via MCP and checking debug output