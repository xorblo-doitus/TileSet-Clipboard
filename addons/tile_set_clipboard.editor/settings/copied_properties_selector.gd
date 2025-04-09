@tool
extends Tree


enum State {
	UNCHECKED,
	INTERMEDIATE,
	CHECKED,
	UNCHECKED_CANT_EDIT,
	INTERMEDIATE_CANT_EDIT,
	CHECKED_CANT_EDIT,
}


const CopiedObject = preload("res://addons/tile_set_clipboard.editor/copying/copied_object.gd")
const CopiedProperty = preload("res://addons/tile_set_clipboard.editor/copying/copied_property.gd")
const CopiedProperties = preload("res://addons/tile_set_clipboard.editor/copying/copied_properties.gd")


const _COL_COPY: int = 0
const _COL_DUPLICATE: int = _COL_COPY + 1
const _COL_TEXT: int = _COL_DUPLICATE + 1
const _COL_COUNT: int = _COL_TEXT + 1

const _META_PROPERTY_PATH = &"_tile_set_clipboard__property_path"


var targets: Array[CopiedObject]: set = set_targets
var property_map: Dictionary[StringName, CopiedProperties]


@export var ignored_properties: PackedStringArray = [
	"script",
]


func _init() -> void:
	columns = _COL_COUNT
	set_column_expand(_COL_COPY, false)
	set_column_expand(_COL_DUPLICATE, false)
	item_edited.connect(propagate_checkboxes)
	check_propagated_to_item.connect(verify_propagation)
	
	set_column_title(_COL_COPY, "Paste")
	set_column_title(_COL_DUPLICATE, "Duplicate")
	set_column_title(_COL_TEXT, "Property")
	
	reset()


func set_targets(new_targets: Array[CopiedObject]) -> void:
	targets = new_targets
	reset()
	
	property_map.clear()
	for target in targets:
		for property in target.properties:
			if not property in property_map:
				property_map[property] = CopiedProperties.new()
			property_map[property].properties.append(target.properties[property])
	
	var root: TreeItem = create_item()

	root.set_editable(_COL_COPY, true)
	root.set_indeterminate(_COL_COPY, true)
	root.set_cell_mode(_COL_COPY, TreeItem.CELL_MODE_CHECK)
	root.set_editable(_COL_DUPLICATE, true)
	root.set_indeterminate(_COL_DUPLICATE, true)
	root.set_cell_mode(_COL_DUPLICATE, TreeItem.CELL_MODE_CHECK)
	root.set_text(_COL_TEXT, "TileData")
	
	var last_item: TreeItem
	for property_name in property_map:
		if property_name in ignored_properties:
			continue
		
		var properties: Array[CopiedProperty] = property_map[property_name].properties
		var item: TreeItem = create_item(root)
		last_item = item
		
		item.set_text(_COL_TEXT, property_name)
		item.set_meta(_META_PROPERTY_PATH, property_name)
		item.set_cell_mode(_COL_COPY, TreeItem.CELL_MODE_CHECK)
		item.set_cell_mode(_COL_DUPLICATE, TreeItem.CELL_MODE_CHECK)
		apply_state_to(item, _COL_DUPLICATE, fetch_can_duplicate(properties))
		apply_state_to(item, _COL_COPY, fetch_copy_state(properties))
	
	last_item.propagate_check(_COL_COPY, true)
	last_item.propagate_check(_COL_DUPLICATE, true)


func fetch_copy_state(properties: Array[CopiedProperty]) -> State:
	if properties.is_empty():
		return State.UNCHECKED
	
	var checked: bool = properties[-1].enabled
	
	for i in len(properties) - 1:
		if properties[i].enabled != checked:
			return State.INTERMEDIATE
	
	if checked:
		return State.CHECKED
	
	return State.UNCHECKED


func fetch_duplicate_state(properties: Array[CopiedProperty]) -> State:
	if properties.is_empty():
		return State.UNCHECKED
	
	var checked: bool = properties[-1].duplicate
	
	for i in len(properties) - 1:
		if properties[i].duplicate != checked:
			return State.INTERMEDIATE
	
	if checked:
		return State.CHECKED
	
	return State.UNCHECKED


func fetch_can_duplicate(properties: Array[CopiedProperty]) -> State:
	if properties.is_empty():
		return State.CHECKED_CANT_EDIT
	
	var can_duplicate: bool = properties[-1].can_duplicate()
	
	for i in len(properties) - 1:
		if properties[i].can_duplicate() != can_duplicate:
			return fetch_duplicate_state(properties)
	
	if can_duplicate:
		return fetch_duplicate_state(properties)
	
	return State.CHECKED_CANT_EDIT


func apply_state_to(item: TreeItem, column: int, state: State) -> void:
	match state:
		State.UNCHECKED, State.UNCHECKED_CANT_EDIT:
			item.set_checked(column, false)
		State.INTERMEDIATE, State.INTERMEDIATE_CANT_EDIT:
			item.set_indeterminate(column, true)
		State.CHECKED, State.CHECKED_CANT_EDIT:
			item.set_checked(column, true)
	
	match state:
		State.UNCHECKED, State.INTERMEDIATE, State.CHECKED:
			item.set_editable(column, true)
		State.UNCHECKED_CANT_EDIT, State.INTERMEDIATE_CANT_EDIT, State.CHECKED_CANT_EDIT:
			item.set_editable(column, false)


func reset() -> void:
	clear()


func propagate_checkboxes() -> void:
	if get_edited() != get_root():
		verify_propagation(get_edited(), get_edited_column())
	get_edited().propagate_check(get_edited_column(), true)


func verify_propagation(item: TreeItem, column: int) -> void:
	if item == get_root():
		return
	
	if item == null:
		return
	
	var copy: bool = item.is_checked(_COL_COPY)
	var duplicate: bool = item.is_checked(_COL_DUPLICATE)
	var property_name: StringName = item.get_meta(_META_PROPERTY_PATH)
	var properties: Array[CopiedProperty] = property_map[property_name].properties
	
	if (
		column == _COL_DUPLICATE
		and not duplicate
		and not item.is_editable(_COL_DUPLICATE)
		and fetch_can_duplicate(properties) == State.CHECKED_CANT_EDIT
	):
		item.set_checked(_COL_DUPLICATE, true)
		item.set_checked.call_deferred(_COL_DUPLICATE, true)
		duplicate = true

	apply_settings_to(properties, copy, duplicate)


func apply_settings_to(properties: Array[CopiedProperty], copy: bool, duplicate: bool) -> void:
	for copied_property in properties:
		copied_property.enabled = copy
		copied_property.duplicate = duplicate
