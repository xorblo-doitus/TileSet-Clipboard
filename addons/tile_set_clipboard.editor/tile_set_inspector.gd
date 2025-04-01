extends EditorInspectorPlugin

const Scrapper = preload("res://addons/tile_set_clipboard.editor/scrapper.gd")
const TileSelection = preload("res://addons/tile_set_clipboard.editor/tile_selection.gd")
const PropertySelector = preload("res://addons/tile_set_clipboard.editor/property_selector.gd")
const CopiedTiles = preload("res://addons/tile_set_clipboard.editor/copied_tiles.gd")

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
	print(object)
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
	#EditorInterface.popup_property_selector(_atlas_tile_proxy, print)
	var popup: ConfirmationDialog = PACKED_SETTINGS.instantiate()
	var tree: PropertySelector = popup.get_node("%PropertySelector")
	
	#var base_tile: TileData
	#if is_instance_valid(copied) and not copied.pos_to_tile.is_empty():
		#base_tile = copied.pos_to_tile.values()[0]
	#else:
		##base_tile = TileData.new()
		#pass
	
	tree.set_targets(copied.copies.values())
	#tree.set_target(base_tile)
	
	EditorInterface.popup_dialog_centered(popup, Vector2i(0, 600))




func honk() -> void:
	prints("Honk!")
	copy()
	print(copied.zone)
	print(copied.pos_to_tile)


func _parse_begin(object: Object) -> void:
	if buttons == null:
		print("recreate button")
		buttons = PACKED_BUTTONS.instantiate()
		buttons.get_node("%CopyButton").pressed.connect(copy)
		buttons.get_node("%PasteButton").pressed.connect(paste)
		buttons.get_node("%SettingsButton").pressed.connect(open_settings)
	
	# TODO Find a way to use keyboard shortcuts (or wait https://github.com/godotengine/godot/pull/102807)
	#var gui_input_signal: Signal = Scrapper._atlas_source_editor.gui_input
	#if !gui_input_signal.is_connected(_on_tile_set_editor_gui_input):
		#gui_input_signal.connect(_on_tile_set_editor_gui_input)
	
	add_custom_control(buttons)
	


# TODO Find a way to use keyboard shortcut (or wait https://github.com/godotengine/godot/pull/102807)
#func _on_tile_set_editor_gui_input(event: InputEvent) -> void:
	#if InputMap.event_is_action(event, "ui_copy", true):
		#copy()
		#Scrapper._tile_set_editor.get_viewport().set_input_as_handled()
	#elif InputMap.event_is_action(event, "ui_paste", true):
		#paste()
		#Scrapper._tile_set_editor.get_viewport().set_input_as_handled()



#func get_source(_atlas_tile_proxy: Object) -> Array[TileData]:
	#var _atlas_source_proxy: Object = null
	#
	#var tiles: Array[TileData] = []
	#for connection in _atlas_tile_proxy.get_incoming_connections():
		#var connected: Object = connection["signal"].get_object()
		#if connected is TileData:
			#tiles.append(connected)
	#return null
