@tool
extends HBoxContainer


@onready var copy_button: Button = %CopyButton
@onready var paste_button: Button = %PasteButton



func _ready() -> void:
	copy_button.icon = EditorInterface.get_base_control().get_theme_icon("ActionCopy", "EditorIcons")
	paste_button.icon = EditorInterface.get_base_control().get_theme_icon("ActionPaste", "EditorIcons")
