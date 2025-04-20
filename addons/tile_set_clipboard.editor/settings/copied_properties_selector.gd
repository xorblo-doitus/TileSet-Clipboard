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
const _COL_VALUE: int = _COL_TEXT + 1
const _COL_COUNT: int = _COL_VALUE + 1

const _META_PROPERTY_PATH = &"_tile_set_clipboard__property_path"
const _META_COPIED_PROPERTY = &"_tile_set_clipboard__copied_property"
const _META_FORCED_DUPLICATE_STATE = &"_tile_set_clipboard__forced_state"


@export var ignored_properties: PackedStringArray = [
	"script",
]
@export var empty_targets_message: String = "Nothing to choose properties from."

@export_group("Grouping")
## If true, properties will be grouped by slash components.
## E.g.: [code]peering_bits/right_side[/code] and [code]peering_bits/left_side[/code]
## under [code]peering_bits[/code]
@export var auto_group: bool = true


var _property_map: Dictionary[StringName, CopiedProperties]
var _targets: Array[CopiedObject]
var _translations: Dictionary[StringName, String]
var _groups: Dictionary[StringName, TreeItem]



func _init() -> void:
	item_edited.connect(_on_item_edited)
	check_propagated_to_item.connect(_on_column_edited)
	
	reset()


func build(new_targets: Array[CopiedObject], new_translations: Dictionary[StringName, String]) -> void:
	_targets = new_targets
	_translations = new_translations
	reset()
	
	_property_map.clear()
	
	if _targets.is_empty():
		columns = 1
		set_column_title(0, empty_targets_message)
		return
	
	for target in _targets:
		for property in target.properties:
			if not property in _property_map:
				_property_map[property] = CopiedProperties.new()
			_property_map[property].properties.append(target.properties[property])
	
	var root: TreeItem = create_item()

	root.set_editable(_COL_COPY, true)
	root.set_indeterminate(_COL_COPY, true)
	root.set_cell_mode(_COL_COPY, TreeItem.CELL_MODE_CHECK)
	root.set_editable(_COL_DUPLICATE, true)
	root.set_indeterminate(_COL_DUPLICATE, true)
	root.set_cell_mode(_COL_DUPLICATE, TreeItem.CELL_MODE_CHECK)
	root.set_text(_COL_TEXT, "TileData")
	root.set_expand_right(_COL_TEXT, true)
	
	var item: TreeItem
	var all_cant_duplicate: bool = true
	
	for property_name in _property_map:
		if property_name in ignored_properties:
			continue
		
		var properties: Array[CopiedProperty] = _property_map[property_name].properties
		item = create_item(_get_tree_parent(root, property_name))
		
		item.set_tooltip_text(_COL_TEXT, property_name)
		if property_name in _translations:
			item.set_text(_COL_TEXT, _translations[property_name])
		else:
			item.set_text(_COL_TEXT, property_name.get_file().capitalize())
		item.set_expand_right(_COL_TEXT, true)
		
		item.set_meta(_META_PROPERTY_PATH, property_name)
		
		item.set_cell_mode(_COL_COPY, TreeItem.CELL_MODE_CHECK)
		item.set_editable(_COL_COPY, true)
		
		item.set_cell_mode(_COL_DUPLICATE, TreeItem.CELL_MODE_CHECK)
		item.set_editable(_COL_DUPLICATE, true)
		
		_add_per_instance_item(item, properties)
		if item.get_meta(_META_FORCED_DUPLICATE_STATE, -1) == -1:
			all_cant_duplicate = false
	
	var groups: Array[TreeItem] = _groups.values()
	groups.reverse()
	for group: TreeItem in groups:
		print(group.get_tooltip_text(_COL_TEXT))
		_check_editable(group, _COL_DUPLICATE)
	
	if all_cant_duplicate:
		root.set_meta(_META_FORCED_DUPLICATE_STATE, State.CHECKED_CANT_EDIT)
		root.set_checked(_COL_DUPLICATE, true)
		root.set_editable(_COL_DUPLICATE, false)


func _add_per_instance_item(base_item: TreeItem, properties: Array[CopiedProperty]) -> void:
	var item: TreeItem
	var all_cant_duplicate: bool = true
	
	for copied_property in properties:
		item = create_item(base_item)
		item.set_meta(_META_COPIED_PROPERTY, copied_property)
		
		item.set_text(_COL_TEXT, copied_property.label)
		item.set_tooltip_text(_COL_TEXT, copied_property.extended_label)
		item.set_expand_right(_COL_TEXT, true)
		
		item.set_text(_COL_VALUE, str(copied_property.duplicated_value))
		if copied_property.base_value is Color:
			item.set_custom_bg_color(_COL_VALUE, copied_property.base_value)
			item.set_custom_color(
				_COL_VALUE,
				Color.BLACK
				if copied_property.base_value.srgb_to_linear().get_luminance() > 0.5
				else Color.WHITE
			)
		else:
			item.set_text(_COL_VALUE, str(copied_property.duplicated_value))
		
		item.set_cell_mode(_COL_COPY, TreeItem.CELL_MODE_CHECK)
		item.set_checked(_COL_COPY, copied_property.enabled)
		item.set_editable(_COL_COPY, true)
		
		item.set_cell_mode(_COL_DUPLICATE, TreeItem.CELL_MODE_CHECK)
		var duplicate_state: State = State.CHECKED_CANT_EDIT
		if copied_property.can_duplicate():
			if copied_property.duplicate:
				duplicate_state = State.CHECKED
			else:
				duplicate_state = State.UNCHECKED
			all_cant_duplicate = false
		else:
			item.set_meta(_META_FORCED_DUPLICATE_STATE, State.CHECKED_CANT_EDIT)
		apply_state_to(item, _COL_DUPLICATE, duplicate_state)
	
	base_item.collapsed = true
	item.propagate_check(_COL_COPY, true)
	item.propagate_check(_COL_DUPLICATE, true)
	
	if all_cant_duplicate:
		base_item.set_meta(_META_FORCED_DUPLICATE_STATE, State.CHECKED_CANT_EDIT)
		base_item.set_checked(_COL_DUPLICATE, true)
		base_item.set_editable(_COL_DUPLICATE, false)


func _get_tree_parent(root: TreeItem, path: StringName) -> TreeItem:
	if not auto_group:
		return root
	
	var direct_parent_path: String = path.get_base_dir()
	if direct_parent_path in _groups:
		return _groups[direct_parent_path]
	
	var parent: TreeItem = root
	var splits: PackedStringArray = path.split("/")
	var current_path: String
	for i in len(splits) - 1:
		var split: String = splits[i]
		current_path += split
		
		if not current_path in _groups:
			parent = create_item(parent)
			
			parent.set_tooltip_text(_COL_TEXT, current_path)
			if split in _translations:
				parent.set_text(_COL_TEXT, _translations[split])
			else:
				parent.set_text(_COL_TEXT, split.capitalize())
			parent.set_expand_right(_COL_TEXT, true)
			
			parent.set_cell_mode(_COL_COPY, TreeItem.CELL_MODE_CHECK)
			parent.set_editable(_COL_COPY, true)
			
			parent.set_cell_mode(_COL_DUPLICATE, TreeItem.CELL_MODE_CHECK)
			parent.set_editable(_COL_DUPLICATE, true)
			
			parent.collapsed = true
			
			_groups[current_path] = parent
		
		current_path += "/"
	return parent


func _check_editable(item: TreeItem, column: int) -> void:
	for child in item.get_children():
		if child.is_editable(column):
			item.set_editable(column, true)
			item.set_checked(column, child.is_checked(column))
			return
	
	item.set_editable(column, false)


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
	columns = _COL_COUNT
	
	set_column_expand(_COL_COPY, false)
	set_column_expand(_COL_DUPLICATE, false)
	set_column_expand(_COL_TEXT, false)
	
	set_column_title(_COL_COPY, "Paste")
	set_column_title(_COL_DUPLICATE, "Duplicate")
	set_column_title(_COL_TEXT, "Property")
	
	clear()


func _on_item_edited() -> void:
	if get_edited() != get_root():
		_on_column_edited(get_edited(), get_edited_column())
	get_edited().propagate_check(get_edited_column(), true)


func _on_column_edited(item: TreeItem, column: int) -> void:
	if item == null:
		return
	
	if column == _COL_DUPLICATE:
		var forced_duplicate_state: State = item.get_meta(_META_FORCED_DUPLICATE_STATE, -1)
		
		if forced_duplicate_state != -1:
			apply_state_to(item, _COL_DUPLICATE, forced_duplicate_state)
			return
	
	if not item.has_meta(_META_COPIED_PROPERTY):
		return
	
	var copied_property: CopiedProperty = item.get_meta(_META_COPIED_PROPERTY)
	var new_checked: bool = item.is_checked(column)
	
	match column:
		_COL_COPY:
			copied_property.enabled = new_checked
		_COL_DUPLICATE:
			copied_property.duplicate = new_checked
