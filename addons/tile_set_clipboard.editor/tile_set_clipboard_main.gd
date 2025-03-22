@tool
extends EditorPlugin


const TileSetInspector = preload("res://addons/tile_set_clipboard.editor/tile_set_inspector.gd")

var inspector: EditorInspectorPlugin


func _enter_tree() -> void:
	inspector = TileSetInspector.new()
	add_inspector_plugin(inspector)


func _exit_tree() -> void:
	remove_inspector_plugin(inspector)
