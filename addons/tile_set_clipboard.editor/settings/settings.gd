@tool
extends AcceptDialog

const Consts = preload("res://addons/tile_set_clipboard.editor/consts.gd")


static var settings: EditorSettings = EditorInterface.get_editor_settings()

@onready var edit_copy_shortcut: Button = $VBoxContainer/Buttons/EditCopyShortcut
@onready var edit_paste_shortcut: Button = $VBoxContainer/Buttons/EditPasteShortcut
@onready var remember_filters: CheckButton = $VBoxContainer/RememberFilters
@onready var remember_window: CheckButton = $VBoxContainer/RememberWindow


func _ready() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	load_theme()
	
	var remember_filter_setting: String = Consts.SETTING_PREFIX + Consts.REMEMBER_FILTERS_SETTING
	if not settings.has_setting(remember_filter_setting):
		settings.set_setting(remember_filter_setting, true)
	remember_filters.button_pressed = settings.get_setting(remember_filter_setting)
	
	var remember_window_setting: String = Consts.SETTING_PREFIX + Consts.REMEMBER_WINDOW_SETTING
	if not settings.has_setting(remember_window_setting):
		settings.set_setting(remember_window_setting, true)
	remember_window.button_pressed = settings.get_setting(remember_window_setting)


func load_theme() -> void:
	var editor_base_control: Control = EditorInterface.get_base_control()
	edit_copy_shortcut.icon = editor_base_control.get_theme_icon("Shortcut", "EditorIcons")
	edit_paste_shortcut.icon = editor_base_control.get_theme_icon("Shortcut", "EditorIcons")


func start_editing_shortcut(shortcut_name: String) -> void:
	var setting_path: String = "addons/tile_set_clipboard/shortcuts/" + shortcut_name
	if !settings.has_setting(setting_path):
		settings.set_setting(
			setting_path,
			load(
				"res://addons/tile_set_clipboard.editor/inspector_plugin/default_"
				+ shortcut_name
				+ "_shortcut.tres"
			).duplicate(true)
		)
	
	edit_shortcut(settings.get_setting(setting_path))


func edit_shortcut(shortcut: Shortcut) -> void:
	var inspector: EditorInspector = EditorInterface.get_inspector()
	var previous_selection: Object = inspector.get_edited_object()
	inspector.edit(shortcut)
	
	hide()
	exclusive = false
	
	while inspector.get_edited_object() == shortcut:
		await get_tree().process_frame
	
	exclusive = true
	show()
	inspector.edit(previous_selection)
	if previous_selection is TileSet:
		EditorInterface.edit_resource(previous_selection)


func _on_edit_copy_shortcut_pressed() -> void:
	start_editing_shortcut("copy")


func _on_edit_paste_shortcut_pressed() -> void:
	start_editing_shortcut("paste")


func _on_remember_filters_toggled(toggled_on: bool) -> void:
	settings.set_setting(
		Consts.SETTING_PREFIX + Consts.REMEMBER_FILTERS_SETTING,
		toggled_on
	)


func _on_remember_window_toggled(toggled_on: bool) -> void:
	settings.set_setting(
		Consts.SETTING_PREFIX + Consts.REMEMBER_WINDOW_SETTING,
		toggled_on
	)


func _on_exiting() -> void:
	if settings.get_setting(Consts.SETTING_PREFIX + Consts.REMEMBER_WINDOW_SETTING):
		settings.set_setting(
			Consts.SETTING_PREFIX + Consts.SAVED_WINDOW_RECT,
			Rect2i(get_position_with_decorations(), get_size_with_decorations())
		)
