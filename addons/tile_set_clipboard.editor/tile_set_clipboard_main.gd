@tool
extends EditorPlugin


const TileSetInspector = preload("res://addons/tile_set_clipboard.editor/inspector_plugin/tile_set_inspector.gd")

var inspector: EditorInspectorPlugin


func _enter_tree() -> void:
	inspector = TileSetInspector.new()
	add_inspector_plugin(inspector)


func _exit_tree() -> void:
	remove_inspector_plugin(inspector)


func _enable_plugin() -> void:
	add_shortcut("copy")
	add_shortcut("paste")

func _disable_plugin() -> void:
	var popup: ConfirmationDialog = ConfirmationDialog.new()
	popup.dialog_text = "Do you want to also remove editor-persistent data?\nYou may want to answer \"no\" in order to keep your settings for other projects."
	popup.cancel_button_text = "No"
	popup.ok_button_text = "Yes"
	popup.get_cancel_button().grab_focus.call_deferred()
	popup.confirmed.connect(remove_editor_persistent_data)
	EditorInterface.popup_dialog_centered(popup)


static func remove_editor_persistent_data() -> void:
	remove_shortcut("copy")
	remove_shortcut("paste")


static func add_shortcut(shortcut_name: String) -> void:
	var setting_path: String = "addons/tile_set_clipboard/shortcuts/" + shortcut_name
	if !EditorInterface.get_editor_settings().has_setting(setting_path):
		EditorInterface.get_editor_settings().set_setting(
			setting_path,
			load(
				"res://addons/tile_set_clipboard.editor/inspector_plugin/default_"
				+ shortcut_name
				+ "_shortcut.tres"
			).duplicate(true)
		)


static func remove_shortcut(shortcut_name: String) -> void:
	EditorInterface.get_editor_settings().set_setting(
		"addons/tile_set_clipboard/shortcuts/" + shortcut_name,
		null
	)
