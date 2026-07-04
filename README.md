# TileMapDualOverlay

[中文文档](README_CN.md)

Overlay rendering layer system for [TileMapDual](https://github.com/pablogila/TileMapDual).

Mirrors DisplayLayer tiles onto one or more overlay TileMapLayers using the same atlas grid layout, enabling per-tile visual effects like water surface, rim light, or decoration.

## Installation

1. Copy `addons/TileMapDualOverlay/` into your project's `addons/` directory
2. Enable the plugin: **Project → Project Settings → Plugins → TileMapDualOverlay → Enable**

**Dependency:** Requires the [TileMapDual](https://github.com/pablogila/TileMapDual) addon to be installed and enabled.

## Quick Start

1. Create a scene with **TileMapDualOverlay** as the root node
2. Add an **OverlayLayer** child node
3. In the Inspector, set **source_id** (or drag a texture to **source_texture** to auto-match)
4. Assign your TileSet, draw tiles — the overlay auto-syncs

## Inspector Properties

| Property | Type | Description |
|----------|------|-------------|
| `source_id` | `int` | Atlas source ID to render from |
| `source_texture` | `Texture2D` | Drag an atlas texture here — auto-fills `source_id` |
| `overlay_z_index` | `int` | Render order (higher = on top) |
| `overlay_material` | `Material` | Custom material (if set, `_build_material` is skipped) |

## Custom Overlays (Scripting)

Create a subclass of `OverlayLayer` to define default settings and custom material:

```gdscript
# water_overlay.gd
@tool
class_name WaterOverlay
extends OverlayLayer

const BED_HEIGHT_MAP_SOURCE_ID: int = 3

func _init() -> void:
    source_id = 2
    overlay_z_index = 1

func _build_material() -> Material:
    var mat := ShaderMaterial.new()
    mat.shader = preload("res://shader/water_hight.gdshader")
    if tile_set and tile_set.has_source(BED_HEIGHT_MAP_SOURCE_ID):
        var src = tile_set.get_source(BED_HEIGHT_MAP_SOURCE_ID)
        if src is TileSetAtlasSource:
            mat.set_shader_parameter(&"bed_height_map", src.texture)
    mat.set_shader_parameter(&"water_height", 1.0)
    return mat

func set_water_height(value: float) -> void:
    if material:
        material.set_shader_parameter(&"water_height", value)
```

Material priority:
1. **Inspector `overlay_material`** — highest priority, use if set
2. **`_build_material()`** — fallback for script-defined materials

## API

### OverlayLayer

| Method | Description |
|--------|-------------|
| `sync(display_layer: DisplayLayer)` | Mirror all tiles from display_layer to this layer |
| `resolve_source_id(ts: TileSet)` | Auto-match `source_texture` to a TileSet atlas source |
| `_build_material() -> Material` | Override to provide a script-built material |

### TileMapDualOverlay

| Method | Description |
|--------|-------------|
| `_init_overlay(layer: OverlayLayer)` | Configure a single overlay (tile_set, position, material) |
| `_sync_all_overlays()` | Trigger full sync on all child overlay layers |

## Limitations

- Currently only syncs `grids[0]` — works for **Isometric** and **Square** grid shapes
- **Half-offset** and **Hex** shapes are not supported (see TODO in source)

## License

Same as TileMapDual — MIT.
