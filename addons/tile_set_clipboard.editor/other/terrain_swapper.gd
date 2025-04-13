extends Object


const TERRAIN_PROPERTIES: Array[StringName] = [
	"terrain",
	"terrains_peering_bit/right_side",
	"terrains_peering_bit/right_corner",
	"terrains_peering_bit/bottom_right_side",
	"terrains_peering_bit/bottom_right_corner",
	"terrains_peering_bit/bottom_side",
	"terrains_peering_bit/bottom_corner",
	"terrains_peering_bit/bottom_left_side",
	"terrains_peering_bit/bottom_left_corner",
	"terrains_peering_bit/left_side",
	"terrains_peering_bit/left_corner",
	"terrains_peering_bit/top_left_side",
	"terrains_peering_bit/top_left_corner",
	"terrains_peering_bit/top_side",
	"terrains_peering_bit/top_corner",
	"terrains_peering_bit/top_right_side",
	"terrains_peering_bit/top_right_corner",
]


static func swap(tiles: Array[TileData], from: int, to: int) -> void:
	if from == to:
		return
	
	var history: EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()
	
	history.create_action("Replace all terrain " + str(from) + " to " + str(to))
	
	for tile in tiles:
		for property_name in TERRAIN_PROPERTIES:
			if tile.get(property_name) == from:
				history.add_do_property(tile, property_name, to)
				history.add_undo_property(tile, property_name, from)
	
	history.commit_action()
