extends Resource


const ALWAYS_DUPLICATED_TYPES = (
	TYPE_DICTIONARY
	| TYPE_ARRAY
	| TYPE_PACKED_BYTE_ARRAY
	| TYPE_PACKED_INT32_ARRAY
	| TYPE_PACKED_INT64_ARRAY
	| TYPE_PACKED_FLOAT32_ARRAY
	| TYPE_PACKED_FLOAT64_ARRAY
	| TYPE_PACKED_STRING_ARRAY
	| TYPE_PACKED_VECTOR2_ARRAY
	| TYPE_PACKED_VECTOR3_ARRAY
	| TYPE_PACKED_COLOR_ARRAY
	| TYPE_PACKED_VECTOR4_ARRAY
)
#const CANT_DUPLICATE_TYPES = (
	#NIL,
	#BOOL,
	#INT,
	#FLOAT,
	#STRING,
	#VECTOR2,
	#VECTOR2I,
	#RECT2,
	#RECT2I,
	#VECTOR3,
	#VECTOR3I,
	#TRANSFORM2D,
	#VECTOR4,
	#VECTOR4I,
	#PLANE,
	#QUATERNION,
	#AABB,
	#BASIS,
	#TRANSFORM3D,
	#PROJECTION,
	#COLOR,
	#STRING_NAME,
	#NODE_PATH,
	#RID,
	#OBJECT,
	#CALLABLE,
	#SIGNAL,
#)


## If true, this property is pasted
@export var enabled: bool = true
## If true, resources are duplicated (and subresources too)
@export var duplicate: bool = true


#@export var copied_value: Variant
# We basically need two members because if [member duplicate] is modified,
# we would then need the other value
# TODO Handle serialization (base value wouldn't always be the right reference,
# for instance if it was an internal resource of the tileset I think)
@export_storage var base_value: Variant
@export_storage var cloned_base_value: Variant:
	get:
		if cloned_base_value == null:
			return base_value
		return cloned_base_value



static func get_serializable_properties(object: Object) -> Array[Dictionary]:
	return object.get_property_list().filter(is_serializable) as Array[Dictionary]


static func is_serializable(property: Dictionary) -> bool:
#static func is_serializable(property: Dictionary[String, Variant]) -> bool:
	return property["usage"] & PROPERTY_USAGE_STORAGE


func from_value(value: Variant) -> void:
	base_value = value
	if (
		typeof(value) & ALWAYS_DUPLICATED_TYPES
		or (value is Resource and not value.resource_scene_unique_id.is_empty())
	):
		duplicate = true
		cloned_base_value = value.duplicate(true)
	else:
		duplicate = false
		cloned_base_value = null


func paste(object: Object, property_name: StringName) -> void:
	if not enabled:
		return
	
	var history: EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()
	history.add_do_property(object, property_name, get_value_to_paste())
	history.add_undo_property(object, property_name, object.get(property_name))


func get_value_to_paste() -> Variant:
	if duplicate and can_duplicate():
		if (
			cloned_base_value is Resource
			or typeof(cloned_base_value) & TYPE_ARRAY | TYPE_DICTIONARY
		):
			return cloned_base_value.duplicate(true)
		else:
			return cloned_base_value.duplicate()
	return base_value


func can_duplicate() -> bool:
	return (
		typeof(cloned_base_value) & ALWAYS_DUPLICATED_TYPES
		or cloned_base_value is Resource
	)


func _to_string() -> String:
	return "Copied: " + str(base_value)
