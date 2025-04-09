extends Object


static var _atlas_source_proxy: Object:
	get:
		if !is_instance_valid(_atlas_source_proxy):
			scrap()
		return _atlas_source_proxy
static var _tile_set_editor: Object:
	get:
		if !is_instance_valid(_tile_set_editor):
			scrap()
		return _tile_set_editor
static var _atlas_source_editor: Object:
	get:
		if !is_instance_valid(_atlas_source_editor):
			scrap()
		return _atlas_source_editor


static func scrap() -> void:
	var base_control = EditorInterface.get_base_control()
	_tile_set_editor = _get_first_node_by_class(base_control, "TileSetEditor")
	_atlas_source_editor = _get_first_node_by_class(_tile_set_editor, "TileSetAtlasSourceEditor")
	_atlas_source_proxy = _get_first_connected_object_by_class(_atlas_source_editor, "TileSetAtlasSourceProxyObject")


static func get_tile_set() -> TileSet:
	for connection in _tile_set_editor.get_incoming_connections():
		var connected: Object = connection["signal"].get_object()
		if connected is TileSet:
			return connected
	return null


static func get_source() -> TileSetSource:
	for connection in _atlas_source_proxy.get_incoming_connections():
		var connected: Object = connection["signal"].get_object()
		if connected is TileSetSource:
			return connected
	return null



# --------------------------------------
# 	Helper functions from https://github.com/dandeliondino/tile_bit_tools/blob/0bbf10f27d492cdc5f7e227cf7946a705998e0d4/addons/tile_bit_tools/inspector_plugin.gd#L272
# --------------------------------------

static func _get_first_node_by_class(parent_node : Node, p_class_name : String) -> Node:
	var nodes := parent_node.find_children("*", p_class_name, true, false)
	if !nodes.size():
		return null
	return nodes[0]

# https://github.com/dandeliondino/tile_bit_tools/blob/0bbf10f27d492cdc5f7e227cf7946a705998e0d4/addons/tile_bit_tools/inspector_plugin.gd#L272
static func _get_first_connected_object_by_class(object : Object, p_class_name : String) -> Object:
	var objects := _get_connected_objects_by_class(object, p_class_name)
	if !objects.size():
		return null
	return objects[0]

# https://github.com/dandeliondino/tile_bit_tools/blob/0bbf10f27d492cdc5f7e227cf7946a705998e0d4/addons/tile_bit_tools/inspector_plugin.gd#L272
static func _get_connected_objects_by_class(object : Object, p_class_name : String) -> Array:
	var objects := []
	for connection in object.get_incoming_connections():
		var connected_object = connection["signal"].get_object()
		if connected_object.is_class(p_class_name):
			objects.append(connected_object)
	return objects
