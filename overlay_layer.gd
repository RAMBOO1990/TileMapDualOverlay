@tool
class_name OverlayLayer
extends TileMapLayer

# 手动输入 atlas source ID（WaterOverlay 默认 = 2）
@export var source_id: int = -1

# 拖入 TileSet 纹理自动匹配 source_id（非空时优先于数字输入）
@export var source_texture: Texture2D = null:
	set(v):
		source_texture = v
		if tile_set:
			resolve_source_id(tile_set)

@export var overlay_z_index: int = 1:
	set(v):
		overlay_z_index = v
		if is_inside_tree():
			z_index = v

@export var overlay_material: Material = null:
	set(v):
		overlay_material = v
		if is_inside_tree():
			material = v


# 进入场景树时自动继承父 TileSet（编辑器下新建子节点后立刻生效）
func _enter_tree() -> void:
	if not tile_set and Engine.is_editor_hint():
		var parent := get_parent() as TileMapLayer
		if parent and parent.tile_set:
			tile_set = parent.tile_set


# 根据拖入的纹理自动匹配 TileSet 中的 atlas source ID
func resolve_source_id(ts: TileSet) -> void:
	if not source_texture or not ts:
		return
	for i in ts.get_source_count():
		var src = ts.get_source(i)
		if src is TileSetAtlasSource and src.texture == source_texture:
			source_id = i
			notify_property_list_changed()
			return


# 子类覆盖：当 overlay_material 未在 Inspector 设置时调用
func _build_material() -> Material:
	return null


# 镜像 display_layer 的所有瓦片到本图层
func sync(display_layer: DisplayLayer) -> void:
	if source_id < 0:
		return
	var dl_tiles := {}
	for cell in display_layer.get_used_cells():
		dl_tiles[cell] = display_layer.get_cell_atlas_coords(cell)

	for cell in get_used_cells():
		if cell not in dl_tiles:
			erase_cell(cell)

	for cell in dl_tiles:
		set_cell(cell, source_id, dl_tiles[cell])
