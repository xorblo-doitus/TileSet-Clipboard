@tool
extends AcceptDialog


static var settings: EditorSettings = EditorInterface.get_editor_settings()

@onready var edit_copy_shortcut: Button = $VBoxContainer/Buttons/EditCopyShortcut
@onready var edit_paste_shortcut: Button = $VBoxContainer/Buttons/EditPasteShortcut


func _ready() -> void:
	if owner and owner != get_tree().edited_scene_root:
		return
	
	load_theme()


func load_theme() -> void:
	var editor_base_control: Control = EditorInterface.get_base_control()
	edit_copy_shortcut.icon = editor_base_control.get_theme_icon("Shortcut", "EditorIcons")
	edit_paste_shortcut.icon = editor_base_control.get_theme_icon("Shortcut", "EditorIcons")


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
	if !settings.has_setting("addons/tile_set_clipboard/shortcuts/copy"):
		settings.set_setting(
			"addons/tile_set_clipboard/shortcuts/copy",
			load("res://addons/tile_set_clipboard.editor/inspector_plugin/default_copy_shortcut.tres").duplicate(true)
		)
	
	edit_shortcut(settings.get_setting("addons/tile_set_clipboard/shortcuts/copy"))


func _on_edit_paste_shortcut_pressed() -> void:
	if !settings.has_setting("addons/tile_set_clipboard/shortcuts/paste"):
		settings.set_setting(
			"addons/tile_set_clipboard/shortcuts/paste",
			load("res://addons/tile_set_clipboard.editor/inspector_plugin/default_paste_shortcut.tres").duplicate(true)
		)
	
	edit_shortcut(settings.get_setting("addons/tile_set_clipboard/shortcuts/paste"))
