# Game — Domain Context

<!-- ============================================================
  TEMPLATE PLACEHOLDER — fill this in before starting development
  Replace this entire comment block and the two sections below with:
    - Game title and one-sentence pitch
    - Genre and core loop (what does the player do every 30 seconds?)
    - Target feel / references (e.g. "feels like Celeste but top-down")
    - Any hard constraints (platform, scope, deadline)
  Claude uses this file to make design and architecture decisions.
  A missing or generic description will produce generic suggestions.
============================================================ -->

## What this game is

_TODO: describe your game here._

## Canonical structure

All game code lives under `src/`. The root-level `assets/` holds non-code files. The root-level `scripts/` holds shell/tooling scripts only (not GDScript).

## Autoloads (singletons)

| Name | Purpose |
|------|---------|
| `EventBus` | Global signal bus |
| `AudioManager` | Music and pooled SFX playback |
| `SceneTransitionManager` | Animated scene transitions (fade, voronoi) + threaded loading screen |
| `GlobalEffects` | Screen-level effects: fade, flash, frame freeze |

## Menu system

A `UIManager` autoload owns a stack of menu screens. Any scene can push/pop screens onto the stack without knowing the UI hierarchy. Fits the existing autoload pattern.

Baseline screens baked into the template: main menu + pause menu.

**UIManager** is a new autoload (to be added alongside EventBus, AudioManager, SceneTransitionManager, GlobalEffects).

- `SceneTransitionManager` handles full scene swaps (main menu → game)
- `UIManager` handles overlay screens (pause, settings) that sit on top of gameplay

## Settings system

A settings screen pushed via `UIManager`. Scope: audio (master/music/sfx volume) + display (resolution, fullscreen). Persisted to `user://settings.cfg`.

Not extensible for per-game custom settings — games add their own settings on top.

`AudioManager` will need audio bus volume control wired to the settings screen.

## Out of scope for v1

- **Input remapping UI**: Too game-specific. Each project handles its own input bindings.

## UIManager API

Screens are addressed by PackedScene reference (mirrors `SceneTransitionManager.transition_to_scene()` pattern):

```gdscript
UIManager.push_screen(PauseMenu)
UIManager.pop_screen()
```

No string registry, no preload boilerplate on UIManager's side.

## UIManager pause behavior

`push_screen(scene: PackedScene, pause: bool = true)` — caller decides per call-site. Default is pause because that's the common case (pause menu). Non-pausing pushes exist for overlays that shouldn't stop gameplay (notifications, popups).

Uses `get_tree().paused` — independent of `GlobalEffects.frame_freeze()` which uses `Engine.time_scale`.

## Screen lifecycle

Screens emit `close_requested` signal when done. `UIManager` connects to it on push and calls `pop_screen()` in response. Screens never reference `UIManager` directly.

## EventBus philosophy

EventBus is for cross-scene signals that can't be directly wired. Autoloads use their own signals for their own concerns (e.g. `SceneTransitionManager.transition_finished` stays on SceneTransitionManager). EventBus stays sparse in the template — each game populates it with domain-specific signals.

## GDScript validation

`scripts/validate_gdscript.sh` runs headless Godot (`godot --headless --check-only`) after every `.gd` edit. Validates without needing a running editor or MCP. Wired via PostToolUse hook in `.claude/settings.json`.
