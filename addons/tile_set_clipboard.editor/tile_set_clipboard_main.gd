@tool
extends EditorPlugin


const TileSetInspector = preload("res://addons/tile_set_clipboard.editor/tile_set_inspector.gd")

var inspector: EditorInspectorPlugin


func _enter_tree() -> void:
	inspector = TileSetInspector.new()
	add_inspector_plugin(inspector)


func _exit_tree() -> void:
	remove_inspector_plugin(inspector)


func _enable_plugin() -> void:
	if !EditorInterface.get_editor_settings().has_setting("addons/tile_set_clipboard/shortcuts/copy"):
		EditorInterface.get_editor_settings().set_setting(
			"addons/tile_set_clipboard/shortcuts/copy",
			load("res://addons/tile_set_clipboard.editor/settings/default_copy_shortcut.tres").duplicate(true)
		)
	if !EditorInterface.get_editor_settings().has_setting("addons/tile_set_clipboard/shortcuts/paste"):
		EditorInterface.get_editor_settings().set_setting(
			"addons/tile_set_clipboard/shortcuts/paste",
			load("res://addons/tile_set_clipboard.editor/settings/default_paste_shortcut.tres").duplicate(true)
		)

func _disable_plugin() -> void:
	EditorInterface.get_editor_settings().set_setting(
		"addons/tile_set_clipboard/shortcuts/copy",
		null
	)
	EditorInterface.get_editor_settings().set_setting(
		"addons/tile_set_clipboard/shortcuts/paste",
		null
	)
