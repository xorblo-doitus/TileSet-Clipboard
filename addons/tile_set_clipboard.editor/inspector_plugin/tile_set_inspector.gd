extends EditorInspectorPlugin

const Scrapper = preload("res://addons/tile_set_clipboard.editor/scrapper.gd")
const TileSelection = preload("res://addons/tile_set_clipboard.editor/tile_selection.gd")
const CopiedPropertiesSelector = preload("res://addons/tile_set_clipboard.editor/copying/copied_properties_selector.gd")
const CopiedTiles = preload("res://addons/tile_set_clipboard.editor/copying/copied_tiles.gd")

const PACKED_BUTTONS = preload("res://addons/tile_set_clipboard.editor/buttons.tscn")
const PACKED_SETTINGS = preload("res://addons/tile_set_clipboard.editor/settings.tscn")

static var _atlas_tile_proxy: Object


var buttons: Control
var copied: CopiedTiles
#var current_selection: TileSelection

static func get_tiles() -> Array[TileData]:
	if !is_instance_valid(_atlas_tile_proxy):
		return []
	
	var tiles: Array[TileData] = []
	for connection in _atlas_tile_proxy.get_incoming_connections():
		var connected: Object = connection["signal"].get_object()
		if connected is TileData:
			tiles.append(connected)
	return tiles


func _can_handle(object: Object) -> bool:
	if object.is_class("AtlasTileProxyObject"):
		_atlas_tile_proxy = object
		return true
		
	return false


func get_pastable_properties(tile: TileData) -> PackedStringArray:
	var result: PackedStringArray
	
	for property in tile.get_property_list():
		if true or (
			property["usage"] & PROPERTY_USAGE_STORAGE
			and property["name"] != "atlas_coords"
			and property["name"] != "size_in_atlas"
			and property["name"] != "script"
		):
			result.append(property["name"])
	
	return result


func copy() -> void:
	copied = CopiedTiles.new()
	copied.from_selection(
		TileSelection.from_data_and_set(get_tiles(), Scrapper.get_tile_set())
	)


func paste() -> void:
	if copied == null:
		return
	
	var current_selection: TileSelection = TileSelection.from_data_and_set(get_tiles(), Scrapper.get_tile_set())
	var history: EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()
	
	history.create_action("Paste tiles in tile set")
	copied.paste(current_selection)
	history.commit_action()



func open_settings() -> void:
	var popup: AcceptDialog = PACKED_SETTINGS.instantiate()
	var tree: CopiedPropertiesSelector = popup.get_node("%CopiedPropertiesSelector")
	
	if is_instance_valid(copied):
		tree.set_targets(copied.copies.values())
	
	EditorInterface.popup_dialog_centered(popup, Vector2i(300, 600))


func _parse_begin(_object: Object) -> void:
	if buttons == null:
		buttons = PACKED_BUTTONS.instantiate()
		buttons.get_node("%CopyButton").pressed.connect(copy)
		buttons.get_node("%PasteButton").pressed.connect(paste)
		buttons.get_node("%SettingsButton").pressed.connect(open_settings)
	
	add_custom_control(buttons)
