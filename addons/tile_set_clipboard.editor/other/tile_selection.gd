extends RefCounted

const TileSelection = preload("res://addons/tile_set_clipboard.editor/other/tile_selection.gd")
const Scrapper = preload("res://addons/tile_set_clipboard.editor/other/scrapper.gd")

var zone: Rect2i
var pos_to_tile: Dictionary[Vector2i, TileData]


static func from_data_and_set(tiles: Array[TileData], tile_set: TileSet) -> TileSelection:
	var selection: TileSelection = TileSelection.new()
	selection.find_tiles(tiles, tile_set)
	return selection


func find_tiles(tiles: Array[TileData], tile_set: TileSet) -> void:
	var source: TileSetSource = Scrapper.get_source()
	var min: Vector2i = Vector2i.MAX
	var max: Vector2i = Vector2i.MIN
	
	for tile_data in tiles:
		var pos: Vector2i = find_tile(tile_data, source)
		min = min.min(pos)
		max = max.max(pos)
		pos_to_tile[pos] = tile_data
	
	zone.position = min
	zone.end = max


static func find_tile(tile_data: TileData, source: TileSetSource) -> Vector2i:
	for index in source.get_tiles_count():
		var pos: Vector2i = source.get_tile_id(index)
		if tile_data == source.get_tile_data(pos, 0): # TODO ALTERNATIVE
			return pos
	return Vector2i(-1, -1)
