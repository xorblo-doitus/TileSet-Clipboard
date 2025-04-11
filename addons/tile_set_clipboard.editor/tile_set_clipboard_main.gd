@tool
extends EditorPlugin


const TileSetInspector = preload("res://addons/tile_set_clipboard.editor/inspector_plugin/tile_set_inspector.gd")
const Consts = preload("res://addons/tile_set_clipboard.editor/consts.gd")


var inspector: EditorInspectorPlugin


func _enter_tree() -> void:
	inspector = TileSetInspector.new()
	add_inspector_plugin(inspector)


func _exit_tree() -> void:
	remove_inspector_plugin(inspector)



func _enable_plugin() -> void:
	add_settings()


func _disable_plugin() -> void:
	var popup: ConfirmationDialog = ConfirmationDialog.new()
	popup.dialog_text = "Do you want to also remove editor-persistent data?\nYou may want to answer \"no\" in order to keep your settings for other projects."
	popup.cancel_button_text = "No"
	popup.ok_button_text = "Yes"
	popup.get_cancel_button().grab_focus.call_deferred()
	popup.confirmed.connect(remove_editor_persistent_data)
	EditorInterface.popup_dialog_centered(popup)


static func remove_editor_persistent_data() -> void:
	remove_settings()
	EditorInterface.get_editor_settings().set_setting(
		Consts.SETTING_PREFIX + Consts.SAVED_WINDOW_RECT,
		null
	)



static func add_settings() -> void:
	var editor_settings: EditorSettings = EditorInterface.get_editor_settings()
	var default_settings: Dictionary[String, Variant] = get_default_settings()
	for setting in default_settings:
		var setting_path: String = Consts.SETTING_PREFIX + setting
		var value: Variant = default_settings[setting]
		
		if not editor_settings.has_setting(setting_path):
			editor_settings.set_setting(setting_path, value)


static func remove_settings() -> void:
	var editor_settings: EditorSettings = EditorInterface.get_editor_settings()
	var default_settings: Dictionary[String, Variant] = get_default_settings()
	for setting in default_settings:
		var setting_path: String = Consts.SETTING_PREFIX + setting
		editor_settings.set_setting(setting_path, null)



static func get_default_settings() -> Dictionary[String, Variant]:
	return {
		Consts.REMEMBER_FILTERS_SETTING: true,
		Consts.REMEMBER_WINDOW_SETTING: true,
		"shortcuts/copy": load_default_shortcut_value("copy"),
		"shortcuts/paste": load_default_shortcut_value("paste"),
	}


static func load_default_shortcut_value(shortcut_name: String) -> Shortcut:
	var result: Shortcut = load(
		"res://addons/tile_set_clipboard.editor/inspector_plugin/default_"
		+ shortcut_name
		+ "_shortcut.tres"
	).duplicate(true)
	result.events = result.events.map(func(event: InputEvent): return event.duplicate(true))
	return result
