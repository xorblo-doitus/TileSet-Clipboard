extends EditorInspectorPlugin

const Consts = preload("res://addons/tile_set_clipboard.editor/consts.gd")
const Scrapper = preload("res://addons/tile_set_clipboard.editor/other/scrapper.gd")
const TileSelection = preload("res://addons/tile_set_clipboard.editor/other/tile_selection.gd")
const CopiedPropertiesSelector = preload("res://addons/tile_set_clipboard.editor/settings/copied_properties_selector.gd")
const CopiedTiles = preload("res://addons/tile_set_clipboard.editor/copying/copied_tiles.gd")
const CopiedObject = preload("res://addons/tile_set_clipboard.editor/copying/copied_object.gd")
const CopiedProperties = preload("res://addons/tile_set_clipboard.editor/copying/copied_properties.gd")

const PACKED_BUTTONS = preload("res://addons/tile_set_clipboard.editor/inspector_plugin/buttons.tscn")
const PACKED_SETTINGS = preload("res://addons/tile_set_clipboard.editor/settings/settings.tscn")

static var _atlas_tile_proxy: Object


var buttons: Control
var copied: CopiedTiles
var _enabled_cache: Dictionary[StringName, bool] = {}
var _duplicate_cache: Dictionary[StringName, bool] = {}


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
	var new_copy: CopiedTiles = CopiedTiles.new()
	new_copy.from_selection(
		TileSelection.from_data_and_set(get_tiles(), Scrapper.get_tile_set())
	)
	
	if is_instance_valid(copied) and EditorInterface.get_editor_settings().get_setting(
		Consts.SETTING_PREFIX + Consts.REMEMBER_FILTERS_SETTING
	):
		CopiedObject.transfer_states(
			flatten(copied),
			flatten(new_copy),
			_enabled_cache,
			_duplicate_cache,
		)
	copied = new_copy


func paste() -> void:
	if copied == null:
		return
	
	var current_selection: TileSelection = TileSelection.from_data_and_set(get_tiles(), Scrapper.get_tile_set())
	var history: EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()
	
	history.create_action("Paste tiles in tile set")
	copied.paste(current_selection)
	history.commit_action()



func open_settings() -> void:
	var settings: EditorSettings = EditorInterface.get_editor_settings()
	var popup: AcceptDialog = PACKED_SETTINGS.instantiate()
	var tree: CopiedPropertiesSelector = popup.get_node("%CopiedPropertiesSelector")
	
	if is_instance_valid(copied):
		tree.build(copied.copies.values(), _get_property_translations())
	
	if (
		settings.get_setting(Consts.SETTING_PREFIX + Consts.REMEMBER_WINDOW_SETTING)
		and settings.has_setting(Consts.SETTING_PREFIX + Consts.SAVED_WINDOW_RECT)
	):
		EditorInterface.popup_dialog(popup, settings.get_setting(Consts.SETTING_PREFIX + Consts.SAVED_WINDOW_RECT))
	else:
		EditorInterface.popup_dialog_centered(popup, Vector2i(300, 600))


func _parse_begin(_object: Object) -> void:
	if buttons == null:
		buttons = PACKED_BUTTONS.instantiate()
		buttons.get_node("%CopyButton").pressed.connect(copy)
		buttons.get_node("%PasteButton").pressed.connect(paste)
		buttons.get_node("%SettingsButton").pressed.connect(open_settings)
	
	add_custom_control(buttons)


func _get_property_translations() -> Dictionary[StringName, String]:
	var translations: Dictionary[StringName, String] = {}
	var tile_set: TileSet = Scrapper.get_tile_set()
	for layer_id in tile_set.get_custom_data_layers_count():
		translations["custom_data_" + str(layer_id)] = tile_set.get_custom_data_layer_name(layer_id)
	return translations


static func flatten(copied_tiles: CopiedTiles) -> Dictionary[StringName, CopiedProperties]:
	var result: Dictionary[StringName, CopiedProperties] = {}
	for copied_object: CopiedObject in copied_tiles.copies.values():
		for property_name in copied_object.properties:
			if not result.has(property_name):
				result[property_name] = CopiedProperties.new()
			result[property_name].properties.append(
				copied_object.properties[property_name]
			)
	return result
