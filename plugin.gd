@tool
extends EditorPlugin


func _enter_tree() -> void:
	const ICON: Texture2D = preload("res://addons/TileMapDual/tile_map_dual.svg")
	add_custom_type("TileMapDualOverlay", "TileMapLayer", preload("tile_map_dual_overlay.gd"), ICON)


func _exit_tree() -> void:
	remove_custom_type("TileMapDualOverlay")
