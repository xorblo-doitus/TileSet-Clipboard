extends Resource

const CopiedObject = preload("res://addons/tile_set_clipboard.editor/copying/copied_object.gd")
const TileSelection = preload("res://addons/tile_set_clipboard.editor/other/tile_selection.gd")
const CopiedProperty = preload("res://addons/tile_set_clipboard.editor/copying/copied_property.gd")


@export var size: Vector2i
@export var copies: Dictionary[Vector2i, CopiedObject]



func from_selection(selection: TileSelection) -> void:
	size = selection.zone.size + Vector2i.ONE
	
	for pos in selection.pos_to_tile:
		var copy: CopiedObject = CopiedObject.new()
		copy.from_object(selection.pos_to_tile[pos])
		copies[pos - selection.zone.position] = copy


func paste(selection: TileSelection) -> void:
	for dest_pos: Vector2i in selection.pos_to_tile.keys():
		var source_pos: Vector2i = (dest_pos - selection.zone.position) % size
		if source_pos in copies:
			copies[source_pos].paste(selection.pos_to_tile[dest_pos])
