@tool
extends Tree


enum State {
	UNCHECKED,
	INTERMEDIATE,
	CHECKED,
	NO_CHECK,
}


const CopiedObject = preload("res://addons/tile_set_clipboard.editor/copying/copied_object.gd")
const CopiedProperty = preload("res://addons/tile_set_clipboard.editor/copying/copied_property.gd")
const CopiedProperties = preload("res://addons/tile_set_clipboard.editor/copying/copied_properties.gd")


## Main column with enable/disable checkbox, type icon and text
const _COL_MAIN: int = 0
const _COL_VALUE: int = _COL_MAIN + 1
const _COL_DUPLICATE: int = _COL_VALUE + 1
const _COL_COUNT: int = _COL_DUPLICATE + 1

const _META_PROPERTY_PATH = &"_tile_set_clipboard__property_path"
const _META_COPIED_PROPERTY = &"_tile_set_clipboard__copied_property"


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
var _property_dicts: Dictionary[StringName, Dictionary]
var _groups: Dictionary[StringName, TreeItem]



func _init() -> void:
	item_edited.connect(_on_item_edited)
	check_propagated_to_item.connect(_on_column_edited)
	
	reset()


func build(
	new_targets: Array[CopiedObject],
	new_translations: Dictionary[StringName, String],
	new_property_dicts: Dictionary[StringName, Dictionary],
) -> void:
	_targets = new_targets
	_translations = new_translations
	_property_dicts = new_property_dicts
	reset()
	
	_property_map.clear()
	
	if _targets.is_empty():
		columns = 1
		set_column_title(0, empty_targets_message)
		column_titles_visible = true
		return
	
	for target in _targets:
		for property in target.properties:
			if not property in _property_map:
				_property_map[property] = CopiedProperties.new()
			_property_map[property].properties.append(target.properties[property])
	
	var root: TreeItem = create_item()
	
	_setup_main_cell(root)
	root.set_indeterminate(_COL_MAIN, true)
	
	root.set_text(_COL_MAIN, "TileData")
	
	var item: TreeItem
	var all_cant_duplicate: bool = true
	
	for property_name in _property_map:
		if property_name in ignored_properties:
			continue
		
		var properties: Array[CopiedProperty] = _property_map[property_name].properties
		
		item = create_item(_get_tree_parent(root, property_name))
		item.set_meta(_META_PROPERTY_PATH, property_name)
		
		_setup_main_cell(item)
		if property_name in _property_dicts:
			item.set_icon(_COL_MAIN, AnyIcon.get_property_icon_from_dict(
				_property_dicts[property_name]
			))
		if property_name in _translations:
			item.set_text(_COL_MAIN, _translations[property_name])
		else:
			item.set_text(_COL_MAIN, property_name.get_file().capitalize())
		
		item.set_tooltip_text(_COL_MAIN, property_name)
		
		_add_per_instance_item(item, properties)
		
		if item.get_cell_mode(_COL_DUPLICATE) == TreeItem.CELL_MODE_CHECK:
			all_cant_duplicate = false
	
	var groups: Array[TreeItem] = _groups.values()
	groups.reverse()
	for group: TreeItem in groups:
		_setup_can_duplicate_from_children(group)
	
	if not all_cant_duplicate:
		_setup_duplicate_cell(root)


func _add_per_instance_item(base_item: TreeItem, properties: Array[CopiedProperty]) -> void:
	var item: TreeItem
	var all_cant_duplicate: bool = true
	
	for copied_property in properties:
		item = create_item(base_item)
		item.set_meta(_META_COPIED_PROPERTY, copied_property)
		
		_setup_main_cell(item)
		item.set_checked(_COL_MAIN, copied_property.enabled)
		item.set_icon(_COL_MAIN, AnyIcon.get_variant_icon(copied_property.base_value))
		item.set_text(_COL_MAIN, copied_property.label + ": " + str(copied_property.duplicated_value))
		item.set_tooltip_text(_COL_MAIN, copied_property.extended_label + "\nProperty value: " + str(copied_property.duplicated_value))
		
		if copied_property.base_value is Color:
			item.set_custom_bg_color(_COL_VALUE, copied_property.base_value)
			item.set_custom_color(
				_COL_VALUE,
				Color.BLACK
				if copied_property.base_value.srgb_to_linear().get_luminance() > 0.5
				else Color.WHITE
			)
		
		_setup_duplicate_cell(item)
		var duplicate_state: State = State.NO_CHECK
		if copied_property.can_duplicate():
			if copied_property.duplicate:
				duplicate_state = State.CHECKED
			else:
				duplicate_state = State.UNCHECKED
			all_cant_duplicate = false
		_apply_state_to(item, _COL_DUPLICATE, duplicate_state)
	
	if not all_cant_duplicate:
		_setup_duplicate_cell(base_item)
	
	base_item.collapsed = true
	item.propagate_check(_COL_MAIN, true)
	_propagate_duplicate(item)


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
			
			_setup_main_cell(parent)
			parent.set_icon(_COL_MAIN, AnyIcon.get_icon(&"Folder"))
			
			parent.set_tooltip_text(_COL_MAIN, current_path)
			if split in _translations:
				parent.set_text(_COL_MAIN, _translations[split])
			else:
				parent.set_text(_COL_MAIN, split.capitalize())
			
			parent.collapsed = true
			
			_groups[current_path] = parent
		
		current_path += "/"
	return parent


func _setup_can_duplicate_from_children(item: TreeItem) -> void:
	for child in item.get_children():
		if child.is_editable(_COL_DUPLICATE):
			_setup_duplicate_cell(item)
			item.set_checked(_COL_DUPLICATE, child.is_checked(_COL_DUPLICATE))
			return


func _fetch_copy_state(properties: Array[CopiedProperty]) -> State:
	if properties.is_empty():
		return State.UNCHECKED
	
	var checked: bool = properties[-1].enabled
	
	for i in len(properties) - 1:
		if properties[i].enabled != checked:
			return State.INTERMEDIATE
	
	if checked:
		return State.CHECKED
	
	return State.UNCHECKED


func _fetch_duplicate_state(properties: Array[CopiedProperty]) -> State:
	if properties.is_empty():
		return State.UNCHECKED
	
	var checked: bool = properties[-1].duplicate
	
	for i in len(properties) - 1:
		if properties[i].duplicate != checked:
			return State.INTERMEDIATE
	
	if checked:
		return State.CHECKED
	
	return State.UNCHECKED


func _fetch_can_duplicate(properties: Array[CopiedProperty]) -> State:
	if properties.is_empty():
		return State.NO_CHECK
	
	var can_duplicate: bool = properties[-1].can_duplicate()
	
	for i in len(properties) - 1:
		if properties[i].can_duplicate() != can_duplicate:
			return _fetch_duplicate_state(properties)
	
	if can_duplicate:
		return _fetch_duplicate_state(properties)
	
	return State.NO_CHECK


func _apply_state_to(item: TreeItem, column: int, state: State) -> void:
	match state:
		State.UNCHECKED:
			item.set_checked(column, false)
			item.set_indeterminate(column, false)
		State.INTERMEDIATE:
			item.set_checked(column, false)
			item.set_indeterminate(column, true)
		State.CHECKED:
			item.set_checked(column, true)
			item.set_indeterminate(column, false)
		State.NO_CHECK:
			item.set_cell_mode(column, TreeItem.CELL_MODE_STRING)
			item.set_editable(column, false)


func reset() -> void:
	columns = _COL_COUNT
	
	set_column_expand(_COL_MAIN, true)
	set_column_expand(_COL_VALUE, false)
	set_column_expand(_COL_DUPLICATE, false)
	
	column_titles_visible = false
	
	clear()


func _setup_main_cell(item: TreeItem) -> void:
	item.set_cell_mode(_COL_MAIN, TreeItem.CELL_MODE_CHECK)
	item.set_editable(_COL_MAIN, true)


func _setup_duplicate_cell(item: TreeItem) -> void:
	item.set_cell_mode(_COL_DUPLICATE, TreeItem.CELL_MODE_CHECK)
	item.set_tooltip_text(_COL_DUPLICATE, "Duplicate")
	item.set_editable(_COL_DUPLICATE, true)


func _propagate_duplicate(item: TreeItem) -> void:
	# Custom propagation to fix unwanted indeterminated state when not all cell
	# modes are "checkbox"
	item.propagate_check(_COL_DUPLICATE, true)
	
	var parent: TreeItem = item.get_parent()
	var fixed_parent_state: State = State.NO_CHECK # Don't fetch the item state as it can be buggy
	
	for sibling in parent.get_children():
		if sibling.get_cell_mode(_COL_DUPLICATE) == TreeItem.CELL_MODE_CHECK:
			var sibling_state: State = _get_col_state(sibling, _COL_DUPLICATE)
			if fixed_parent_state == State.NO_CHECK:
				fixed_parent_state = sibling_state
			elif sibling_state != fixed_parent_state:
				fixed_parent_state = State.INTERMEDIATE
				break
	
	if _get_col_state(parent, _COL_DUPLICATE) != fixed_parent_state:
		_apply_state_to(parent, _COL_DUPLICATE, fixed_parent_state)
		parent.propagate_check(_COL_DUPLICATE, true)


func _get_col_state(item: TreeItem, column: int) -> State:
	if item.is_indeterminate(column):
		return State.INTERMEDIATE
	
	if item.is_checked(column):
		return State.CHECKED
	
	return State.UNCHECKED


func _on_item_edited() -> void:
	if get_edited() != get_root():
		_on_column_edited(get_edited(), get_edited_column())
	
	if get_edited_column() == _COL_DUPLICATE:
		_propagate_duplicate(get_edited())
	else:
		get_edited().propagate_check(get_edited_column(), true)
	


func _on_column_edited(item: TreeItem, column: int) -> void:
	if item == null:
		return
	
	if not item.has_meta(_META_COPIED_PROPERTY):
		return
	
	var copied_property: CopiedProperty = item.get_meta(_META_COPIED_PROPERTY)
	var new_checked: bool = item.is_checked(column)
	
	match column:
		_COL_MAIN:
			copied_property.enabled = new_checked
		_COL_DUPLICATE:
			copied_property.duplicate = new_checked
