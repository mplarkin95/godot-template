---
name: asset-pipeline
description: Workflows for importing assets into Godot from Blender (3D models) and Aseprite (sprites/spritesheets). Load when creating, exporting, or importing art assets.
tools:
  - Bash
  - Read
---

# Asset Pipeline

## Blender → Godot (3D models)

### Export from Blender via MCP

Use the Blender MCP to export directly — never import .blend files into Godot.

```
# Ask Claude to do this via Blender MCP:
"Export the selected mesh as GLB to res://assets/models/enemy_goblin.glb
 with Y-up axis, apply all modifiers, include armature if present"
```

Key Blender export settings for Godot 4:
- Format: **GLTF 2.0 (.glb)** — binary, single file
- Y-up: ✓ (Godot uses Y-up)
- Apply modifiers: ✓
- Include: Meshes + Armatures + Animations
- Compression: None (Godot reimports anyway)

### Godot import settings for .glb

After export, set these in Godot's Import dock:
- **Meshes > Generate LODs**: ✓ for environment, ✗ for characters
- **Animation > Import**: ✓ if the model has animations
- **Skins > Use Named Skins**: ✓

### Scale convention
Blender uses meters, Godot's default unit is also meters — 1:1 scale works.
If a model imports too large/small, fix in Blender before re-exporting.
Do NOT use the import scale multiplier in Godot — it breaks physics shapes.

---

## Aseprite → Godot (2D sprites)

### Export spritesheet via pixel-plugin or Aseprite MCP

```
# Ask Claude to do this via Aseprite MCP:
"Export player.aseprite as a spritesheet to res://assets/sprites/player.png
 with accompanying JSON data at res://assets/sprites/player.json,
 rows layout, one row per animation tag"
```

### Import as AnimatedSprite2D in Godot

After export:
1. Drag `player.png` into Godot FileSystem
2. Create `SpriteFrames` resource:
   - In editor: add `AnimatedSprite2D` node → SpriteFrames → New SpriteFrames
   - Or via MCP: "Create AnimatedSprite2D using player.png spritesheet with tags: idle(4), run(6), jump(2), fall(2), attack(5)"

### Godot import settings for pixel art sprites

Set these on the .png import to prevent blurring:
- **Filter**: Nearest (not Linear)
- **Mipmaps**: Off
- **Compression**: Lossless

You can set this project-wide in:
`Project > Project Settings > Rendering > Textures > Canvas Textures > Default Texture Filter = Nearest`

### Naming convention for animation frames
Aseprite tags should match the animation names you'll use in GDScript:
`idle`, `run`, `jump`, `fall`, `attack`, `death`, `hurt`

These map directly to `animated_sprite.play("idle")` etc.

---

## Asset checklist before committing

- [ ] .blend files NOT in res:// (use assets/models/*.glb only)
- [ ] .aseprite files NOT in res:// (use assets/sprites/*.png + *.json)
- [ ] .import files NOT committed to git (add to .gitignore)
- [ ] Pixel art textures set to Nearest filter
- [ ] 3D models exported with Y-up from Blender
- [ ] Audio files as .ogg (loop) or .wav (one-shot)