# TileMapDualOverlay

基于 [TileMapDual](https://github.com/pablogila/TileMapDual) 的叠加渲染图层系统。

将 DisplayLayer 的瓦片镜像到一个或多个 OverlayLayer 上，利用相同的 atlas 网格布局实现逐瓦片视觉效果，例如水面、发光边缘、装饰物等。

**前置条件：** 必须与 TileMapDual 使用**同一个 TileSet**，叠加层引用其中的不同 atlas source。所有 atlas source 必须具有相同的网格布局 —— 相同 atlas 坐标的瓦片一一对应。

## 安装

1. 将 `addons/TileMapDualOverlay/` 复制到项目的 `addons/` 目录中
2. 启用插件：**项目 → 项目设置 → 插件 → TileMapDualOverlay → 启用**

**依赖：** 需要先安装并启用 [TileMapDual](https://github.com/pablogila/TileMapDual) 插件。

## 快速开始

1. 新建场景，根节点选择 **TileMapDualOverlay**
2. 绑定一个 **TileSet** — 该 TileSet 必须包含地形和叠加层所需的**所有 atlas source**（例如 source 1 河床、source 2 水面、source 3 深度图）。各 source 网格布局必须一致。
3. 添加 **OverlayLayer** 子节点 — 其 **TileSet** 自动继承父节点的值（Inspector 立刻显示）
4. 在 Inspector 中设置 **Atlas Source ID** 为叠加层对应的 atlas source（或拖入纹理到 **source_texture** 自动匹配）
5. 绘制瓦片 — 叠加层自动从 `atlas_source_id` 取出相同 atlas 网格位置的瓦片同步渲染

## Inspector 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `atlas_source_id` | `int` | 渲染来源的 atlas source ID |
| `source_texture` | `Texture2D` | 拖入 atlas 纹理自动填充 `atlas_source_id` |
| `overlay_z_index` | `int` | 渲染层级（值越大越靠前） |
| `overlay_material` | `Material` | 自定义材质（设置后将跳过 `_build_material`） |

## 自定义 Overlay（脚本）

继承 `OverlayLayer` 来设置默认参数和自定义材质：

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

材质优先级：
1. **Inspector `overlay_material`** — 最高优先级，设置后不再调用 `_build_material`
2. **`_build_material()`** — 回退方案，用于脚本定义材质

## API

### OverlayLayer

| 方法 | 说明 |
|------|------|
| `sync(display_layer: DisplayLayer)` | 将 display_layer 的所有瓦片镜像到本图层 |
| `resolve_source_id(ts: TileSet)` | 根据 `source_texture` 自动匹配 TileSet 中的 atlas source |
| `_build_material() -> Material` | 子类覆盖，提供脚本构建的材质 |

### TileMapDualOverlay

| 方法 | 说明 |
|------|------|
| `_init_overlay(layer: OverlayLayer)` | 初始化单个 OverlayLayer（tile_set、位置、材质） |
| `_sync_all_overlays()` | 对所有子 OverlayLayer 触发全量同步 |

## 已知问题

### 首次扩展脚本时编辑器崩溃（Godot 4.7）

在编辑器中继承 `TileMapDualOverlay`（或 `TileMapDual`）创建新脚本，拖拽脚本到节点上时可能触发 **signal 11 段错误**。仅在**首次**操作时崩溃——保存项目并重开编辑器后，同样操作可正常运行。

**根因：** Godot 4.7 引擎 Bug（[#67971](https://github.com/godotengine/godot/issues/67971)）—— `TileMapLayer` 的 C++ 代码在热切换脚本实例时，未正确处理动态添加的子节点（`_ready()` 中通过 `add_child()` 添加）。`TileMapDual._ready()` 中 `add_child(_display)` 触发了此问题。

**规避方法：** 创建扩展脚本后先保存项目、重启编辑器，再挂载脚本。

**影响范围：** 所有在 `_ready()` 中添加子节点的 `TileMapLayer` 派生类——`TileMapDual` 和 `TileMapDualOverlay` 均受影响。

## 限制

- 当前仅同步 `grids[0]` — 仅支持 **Isometric** 和 **Square** 网格
- **Half-offset** 和 **Hex** 网格暂不支持（见源码中的 TODO）

## 许可证

与 TileMapDual 相同 — MIT。
