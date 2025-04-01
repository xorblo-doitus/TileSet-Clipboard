extends Resource


## If true, this property is pasted
@export var enabled: bool = true
## If true, resources are duplicated
@export var deep_copy: bool = true


#@export var copied_value: Variant
# We basically need two members because if [member deep_copy] is modified,
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



func from_dict_and_value(dict: Dictionary, value: Variant) -> void:
#func from_dict_and_value(dict: Dictionary[String, Variant], value: Variant) -> void:
	#if value is Resource:
		#copied_value = value.duplicate()
	#else:
		#copied_value = value
	base_value = value
	if value is Resource:
		cloned_base_value = value.duplicate()
	else:
		cloned_base_value = null


func paste(object: Object, property_name: StringName) -> void:
	if not enabled:
		return
	#object.set(property_name, get_value_to_paste())
	var history: EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()
	history.add_do_property(object, property_name, get_value_to_paste())
	history.add_undo_property(object, property_name, object.get(property_name))


func get_value_to_paste() -> Variant:
	if deep_copy and cloned_base_value is Resource:
		return cloned_base_value.duplicate()
	return base_value
