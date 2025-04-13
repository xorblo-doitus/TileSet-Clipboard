@tool
extends HBoxContainer


signal swap_requested(from: int, to: int)

@onready var from: SpinBox = $From
@onready var to: SpinBox = $To
@onready var change_terrain: Button = %ChangeTerrain


func _ready() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	load_theme()


func set_from(new: int) -> void:
	from.value = new
	
func set_to(new: int) -> void:
	to.value = new


func get_from() -> int:
	return from.value
	
func get_to() -> int:
	return to.value


func load_theme() -> void:
	var editor_base_control: Control = EditorInterface.get_base_control()
	change_terrain.icon = editor_base_control.get_theme_icon("ArrowRight", "EditorIcons")


func _on_change_terrain_pressed() -> void:
	swap_requested.emit(from.value, to.value)
