extends Resource


const ALWAYS_DUPLICATED_TYPES = [
	TYPE_DICTIONARY,
	TYPE_ARRAY,
	TYPE_PACKED_BYTE_ARRAY,
	TYPE_PACKED_INT32_ARRAY,
	TYPE_PACKED_INT64_ARRAY,
	TYPE_PACKED_FLOAT32_ARRAY,
	TYPE_PACKED_FLOAT64_ARRAY,
	TYPE_PACKED_STRING_ARRAY,
	TYPE_PACKED_VECTOR2_ARRAY,
	TYPE_PACKED_VECTOR3_ARRAY,
	TYPE_PACKED_COLOR_ARRAY,
	TYPE_PACKED_VECTOR4_ARRAY,
]


## If true, this property is pasted
@export var enabled: bool = true
## If true, resources are duplicated (and subresources too)
@export var duplicate: bool = true

@export var label: StringName
@export var extended_label: StringName

# We basically need two members because if [member duplicate] is modified,
# we would then need the other value
# TODO Handle serialization (base value wouldn't always be the right reference,
# for instance if it was an internal resource of the tileset I think)
@export_storage var base_value: Variant
@export_storage var duplicated_value: Variant:
	get:
		if duplicated_value == null:
			return base_value
		return duplicated_value



static func get_serializable_properties(object: Object) -> Array[Dictionary]:
	return object.get_property_list().filter(is_serializable)

static func get_serializable_property_names(object: Object) -> Array[StringName]:
	var result: Array[StringName]
	result.assign(get_serializable_properties(object).map(get_property_name_untyped))
	return result


static func is_serializable(property: Dictionary) -> bool:
#static func is_serializable(property: Dictionary[String, Variant]) -> bool:
	return property["usage"] & PROPERTY_USAGE_STORAGE


static func get_property_name(property_dict: Dictionary[StringName, Variant]) -> StringName:
	return property_dict["name"]
static func get_property_name_untyped(property_dict: Dictionary) -> StringName:
	return property_dict["name"]


func from_value(value: Variant) -> void:
	base_value = value
	if (
		typeof(value) in ALWAYS_DUPLICATED_TYPES
		or (value is Resource and not value.resource_scene_unique_id.is_empty())
	):
		duplicate = true
		duplicated_value = _duplicate(value)
	else:
		duplicate = false
		duplicated_value = null


func paste(object: Object, property_name: StringName) -> void:
	if not enabled:
		return
	
	var curent_value: Variant = object.get(property_name)
	var to_paste: Variant = get_value_to_paste()
	
	if curent_value != to_paste:
		var history: EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()
		history.add_do_property(object, property_name, to_paste)
		history.add_undo_property(object, property_name, curent_value)


func get_value_to_paste() -> Variant:
	if duplicate and can_duplicate():
		return _duplicate(duplicated_value)
	return base_value


## Value must be duplicatable
static func _duplicate(value: Variant) -> Variant:
	if (
			value is Resource
			or typeof(value) == TYPE_ARRAY
			or typeof(value) == TYPE_DICTIONARY
		):
		return value.duplicate(true)
	
	return value.duplicate()


func can_duplicate() -> bool:
	return (
		typeof(duplicated_value) in ALWAYS_DUPLICATED_TYPES
		or duplicated_value is Resource
	)


func _to_string() -> String:
	return "Copied: " + str(base_value)
