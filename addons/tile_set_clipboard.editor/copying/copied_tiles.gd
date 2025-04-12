extends Resource

const Scrapper = preload("res://addons/tile_set_clipboard.editor/other/scrapper.gd")
const CopiedObject = preload("res://addons/tile_set_clipboard.editor/copying/copied_object.gd")
const TileSelection = preload("res://addons/tile_set_clipboard.editor/other/tile_selection.gd")
const CopiedProperty = preload("res://addons/tile_set_clipboard.editor/copying/copied_property.gd")


@export var size: Vector2i
@export var copies: Dictionary[Vector2i, CopiedObject]



func from_selection(selection: TileSelection) -> void:
	size = selection.zone.size + Vector2i.ONE
	
	for pos in selection.pos_to_tile:
		var relative_pos: Vector2i = pos - selection.zone.position
		
		var copy: CopiedObject = CopiedObject.new()
		copy.from_object(selection.pos_to_tile[pos])
		for copied_property in copy.properties.values():
			copied_property.label = str(relative_pos)
			copied_property.extended_label = "Atlas position: " + str(pos)
		
		copies[relative_pos] = copy
		


func paste(selection: TileSelection) -> void:
	if selection.zone.size == Vector2i.ZERO:
		paste_from_upper_left_corner(selection)
	else:
		paste_repeat(selection)


func paste_repeat(selection: TileSelection) -> void:
	for dest_pos: Vector2i in selection.pos_to_tile.keys():
		var source_pos: Vector2i = (dest_pos - selection.zone.position) % size
		if source_pos in copies:
			copies[source_pos].paste(selection.pos_to_tile[dest_pos])


func paste_from_upper_left_corner(selection: TileSelection) -> void:
	var source: TileSetAtlasSource = Scrapper.get_source()
	
	for source_pos: Vector2i in copies:
		var dest_pos: Vector2i = selection.zone.position + source_pos
		if source.has_tile(dest_pos):
			copies[source_pos].paste(source.get_tile_data(dest_pos, 0))
