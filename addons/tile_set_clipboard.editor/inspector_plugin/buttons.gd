@tool
extends HBoxContainer



@onready var copy_button: Button = %CopyButton
@onready var paste_button: Button = %PasteButton
@onready var settings_button: Button = %SettingsButton



func _ready() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	load_theme()

	focus_mode = Control.FOCUS_ALL
	grab_focus.call_deferred()
	
	if EditorInterface.get_editor_settings().has_setting("addons/tile_set_clipboard/shortcuts/copy"):
		copy_button.shortcut = EditorInterface.get_editor_settings().get_setting("addons/tile_set_clipboard/shortcuts/copy")
	if EditorInterface.get_editor_settings().has_setting("addons/tile_set_clipboard/shortcuts/paste"):
		paste_button.shortcut = EditorInterface.get_editor_settings().get_setting("addons/tile_set_clipboard/shortcuts/paste")


func load_theme() -> void:
	var editor_base_control: Control = EditorInterface.get_base_control()
	copy_button.icon = editor_base_control.get_theme_icon("ActionCopy", "EditorIcons")
	paste_button.icon = editor_base_control.get_theme_icon("ActionPaste", "EditorIcons")
	settings_button.icon = editor_base_control.get_theme_icon("GDScript", "EditorIcons")
