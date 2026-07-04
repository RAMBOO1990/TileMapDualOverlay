# TileMapDualOverlay

[中文文档](README_CN.md)

Overlay rendering layer system for [TileMapDual](https://github.com/pablogila/TileMapDual).

Mirrors DisplayLayer tiles onto one or more overlay TileMapLayers using the same atlas grid layout, enabling per-tile visual effects like water surface, rim light, or decoration.

**Requirement:** Must use the **same TileSet** as TileMapDual, referencing different atlas sources within it. All atlas sources must share the same grid layout — tiles at identical atlas coordinates map to each other.

## Installation

1. Copy `addons/TileMapDualOverlay/` into your project's `addons/` directory
2. Enable the plugin: **Project → Project Settings → Plugins → TileMapDualOverlay → Enable**

**Dependency:** Requires the [TileMapDual](https://github.com/pablogila/TileMapDual) addon to be installed and enabled.

## Quick Start

1. Create a scene with **TileMapDualOverlay** as the root node
2. Assign a **TileSet** to it — this TileSet must contain ALL atlas sources for terrain AND overlay tiles (e.g., riverbed in source 1, water in source 2, depth map in source 3). All sources must share the same grid layout.
3. Add an **OverlayLayer** child node — its **TileSet** auto-inherits from the parent (shown immediately in the Inspector)
4. In the Inspector, set **Atlas Source ID** to the overlay's atlas source (or drag a texture to **source_texture** to auto-match)
5. Draw tiles — the overlay auto-syncs with a matching tile from `atlas_source_id` at the same atlas grid position

## Inspector Properties

| Property | Type | Description |
|----------|------|-------------|
| `atlas_source_id` | `int` | Atlas source ID to render from |
| `source_texture` | `Texture2D` | Drag an atlas texture here — auto-fills `atlas_source_id` |
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
    atlas_source_id = 2
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
