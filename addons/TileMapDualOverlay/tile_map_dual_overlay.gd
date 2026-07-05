@tool
class_name TileMapDualOverlay
extends TileMapDual


func _ready() -> void:
	super._ready()
	_setup_overlays()


# 初始化所有 OverlayLayer 子节点并连接同步信号
func _setup_overlays() -> void:
	for child in get_children():
		if child is OverlayLayer:
			_init_overlay(child)

	_display.world_tiles_changed.connect(_on_world_tiles_changed, CONNECT_DEFERRED)
	_display.terrain.changed.connect(_on_terrain_changed, CONNECT_DEFERRED)
	_tileset_watcher.tileset_resized.connect(_on_tileset_resized)


# 配置单个 OverlayLayer
# Inspector 设置了 material 则优先用（方便纯配置需求），否则调 _build_material
func _init_overlay(layer: OverlayLayer) -> void:
	layer.tile_set = tile_set
	layer.resolve_source_id(tile_set)
	layer.z_index = layer.overlay_z_index
	layer.position = _get_grid_offset()
	layer.material = layer.overlay_material if layer.overlay_material else layer._build_material()


# 信号转发：跳过 DisplayLayer 尚未初始化时的空调用
func _on_world_tiles_changed(_coords: Array[Vector2i] = []) -> void:
	if _display_layer_0() == null:
		return
	_sync_all_overlays(_coords)


# 地形重组时全量重建所有 OverlayLayer
func _on_terrain_changed() -> void:
	assert(is_instance_valid(_display))
	_sync_all_overlays()


# tile_size 变化时更新所有 OverlayLayer 位置
func _on_tileset_resized() -> void:
	var offset := _get_grid_offset()
	for child in get_children():
		if child is OverlayLayer:
			child.position = offset


# 遍历所有 OverlayLayer 子节点，逐一镜像显示层瓦片
func _sync_all_overlays(_coords: Array[Vector2i] = []) -> void:
	var dl := _display_layer_0()
	assert(dl != null, "未找到显示层")

	for child in get_children():
		if child is OverlayLayer:
			child.sync(dl)


# 计算当前 TileSet 的首个网格偏移（像素）
func _get_grid_offset() -> Vector2:
	assert(tile_set != null, "tile_set 为空")
	var gs = Display.tileset_gridshape(tile_set)
	var grids: Array = Display.GRIDS.get(gs, [])
	assert(grids.size() > 0, "未找到网格形状对应的 GRIDS 配置")
	return grids[0].offset * Vector2(tile_set.tile_size)


# 获取 grids[0] 对应的 DisplayLayer
func _display_layer_0() -> DisplayLayer:
	for child in _display.get_children():
		if child is DisplayLayer:
			return child
	return null


# TODO: 六边形/Half-offset 需要每 grids entry 对应一个 OverlayLayer
# 当前只同步 grids[0]（isometric / square 的单层场景）
