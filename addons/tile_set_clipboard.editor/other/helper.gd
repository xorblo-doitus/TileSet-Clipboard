extends Object



static func get_all_tiles(source: TileSetAtlasSource) -> Array[TileData]:
	var result: Array[TileData] = []
	var size: Vector2i = source.get_atlas_grid_size()
	
	for x in size.x:
		for y in size.y:
			var pos: Vector2i = Vector2i(x, y)
			if source.has_tile(pos):
				result.append(source.get_tile_data(pos, 0))
	
	return result
