extends Resource

const CopiedObject = preload("res://addons/tile_set_clipboard.editor/copied_object.gd")
const TileSelection = preload("res://addons/tile_set_clipboard.editor/tile_selection.gd")
const CopiedProperty = preload("res://addons/tile_set_clipboard.editor/copied_property.gd")

#var copies: Array[]
@export var size: Vector2i
@export var copies: Dictionary[Vector2i, CopiedObject]



func from_selection(selection: TileSelection) -> void:
	size = selection.zone.size
	
	for pos in selection.pos_to_tile:
		var copy: CopiedObject = CopiedObject.new()
		copy.from_object(selection.pos_to_tile[pos])
		copies[pos - selection.zone.position] = copy


func paste(selection: TileSelection) -> void:
	for position: Vector2i in copies:
		var copy: CopiedObject = copies.get(position)
		var dest_pos: Vector2i = selection.zone.position + position
		
		if dest_pos in selection.pos_to_tile:
			var dest_tile: TileData = selection.pos_to_tile.get(dest_pos)
			copy.paste(dest_tile)
