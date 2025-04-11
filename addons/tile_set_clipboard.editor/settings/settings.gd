@tool
extends AcceptDialog

const Consts = preload("res://addons/tile_set_clipboard.editor/consts.gd")


static var settings: EditorSettings = EditorInterface.get_editor_settings()

@onready var edit_copy_shortcut: Button = $VBoxContainer/Buttons/EditCopyShortcut
@onready var edit_paste_shortcut: Button = $VBoxContainer/Buttons/EditPasteShortcut
@onready var remember_filters: CheckButton = $VBoxContainer/Toggles/RememberFilters


func _ready() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	load_theme()
	
	var remember_setting: String = Consts.SETTING_PREFIX + Consts.REMEMBER_FILTERS_SETTING
	if not settings.has_setting(remember_setting):
		settings.set_setting(remember_setting, true)
	remember_filters.button_pressed = settings.get_setting(remember_setting)


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


func _on_check_button_toggled(toggled_on: bool) -> void:
	settings.set_setting(
		Consts.SETTING_PREFIX + Consts.REMEMBER_FILTERS_SETTING,
		toggled_on
	)
