@tool
extends HBoxContainer


@export_tool_button("Reload Theme", "Reload") var __reload_theme: Callable = load_theme 

@onready var copy_button: Button = %CopyButton
@onready var paste_button: Button = %PasteButton
@onready var settings_button: Button = %SettingsButton



func _ready() -> void:
	if EditorInterface.get_base_control().is_ancestor_of(self):
		load_theme()
	
	focus_mode = Control.FOCUS_ALL
	grab_focus.call_deferred()


func load_theme() -> void:
	var editor_base_control: Control = EditorInterface.get_base_control()
	copy_button.icon = editor_base_control.get_theme_icon("ActionCopy", "EditorIcons")
	paste_button.icon = editor_base_control.get_theme_icon("ActionPaste", "EditorIcons")
	settings_button.icon = editor_base_control.get_theme_icon("GDScript", "EditorIcons")
