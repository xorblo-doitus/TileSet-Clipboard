@tool
extends Tree


enum State {
	UNCHECKED,
	INTERMEDIATE,
	CHECKED,
}


const CopiedObject = preload("res://addons/tile_set_clipboard.editor/copied_object.gd")
const CopiedProperty = preload("res://addons/tile_set_clipboard.editor/copied_property.gd")


const _NESTING_USAGES = (
	PROPERTY_USAGE_CATEGORY
	| PROPERTY_USAGE_GROUP
	| PROPERTY_USAGE_SUBGROUP
)
const _NESTING_LEVELS: Array[int] = [
	PROPERTY_USAGE_CATEGORY,
	PROPERTY_USAGE_GROUP,
	PROPERTY_USAGE_SUBGROUP,
]

const _COL_CHECKBOX: int = 0
const _COL_TEXT: int = _COL_CHECKBOX + 1
const _COL_COUNT: int = _COL_TEXT + 1


#@export_tool_button("Target Currently Selected", "ColorPick")
#var __target_currently_selected = func(): set_target(EditorInterface.get_selection().get_selected_nodes()[0])


var targets: Array[CopiedObject]: set = set_targets
var properties: Dictionary[StringName, CopiedProperties]


@export var ignored_properties: PackedStringArray = [
	"script",
]


func _init() -> void:
	columns = _COL_COUNT
	set_column_expand(_COL_CHECKBOX, false)
	item_edited.connect(propagate_checkboxes)
	
	set_column_title(_COL_CHECKBOX, "Paste")
	set_column_title(_COL_TEXT, "Property")
	
	reset()



func set_targets(targets: Array[CopiedObject]) -> void:
	targets = targets
	reset()
	
	
	#var properties: Dictionary[StringName, Array[Object]]
	#print(target.get_property_list())
	properties.clear()
	for target in targets:
		for property in target.properties:
			if not property in properties:
				properties[property] = CopiedProperties.new()
			properties[property].properties.append(target.properties[property])
	
	var root: TreeItem = create_item()

	root.set_editable(_COL_CHECKBOX, true)
	root.set_cell_mode(_COL_CHECKBOX, TreeItem.CELL_MODE_CHECK)
	root.set_text(_COL_TEXT, "TileData")
	
	for property_name in properties:
		#var property_name: String = property["name"]
		if property_name in ignored_properties:
			continue
		
		#var usage: int = property["usage"]
		
		var item: TreeItem = create_item(root)
		
		item.set_text(_COL_TEXT, property_name)
		item.set_editable(_COL_CHECKBOX, true)
		item.set_cell_mode(_COL_CHECKBOX, TreeItem.CELL_MODE_CHECK)
		match fetch_propperty_state(properties[property_name].properties):
			State.UNCHECKED:
				item.set_checked(_COL_CHECKBOX, false)
			State.INTERMEDIATE:
				item.set_indeterminate(_COL_CHECKBOX, true)
			State.CHECKED:
				item.set_checked(_COL_CHECKBOX, true)


func fetch_propperty_state(properties: Array[CopiedProperty]) -> State:
	if properties.is_empty():
		return State.UNCHECKED
	
	var checked: bool = properties[-1].enabled
	
	for i in len(properties) - 1:
		if properties[i].enabled != checked:
			return State.INTERMEDIATE
	
	if checked:
		return State.CHECKED
	
	return State.UNCHECKED


func reset() -> void:
	clear()


func propagate_checkboxes() -> void:
	if get_edited() != get_root():
		var enabled: bool = get_edited().is_checked(_COL_CHECKBOX)
		var property_name: StringName = get_edited().get_text(_COL_TEXT)
		var affected_properties: CopiedProperties = properties[property_name]
		for property in affected_properties.properties:
			property.enabled = enabled
	
	get_edited().propagate_check(_COL_CHECKBOX, false)


class CopiedProperties:
	var properties: Array[CopiedProperty]
