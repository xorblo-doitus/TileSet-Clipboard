extends Resource


enum AgregatedState {
	ALL_DISABLED,
	MIXED,
	ALL_ENABLED,
}


const CopiedProperty = preload("res://addons/tile_set_clipboard.editor/copying/copied_property.gd")
const CopiedProperties = preload("res://addons/tile_set_clipboard.editor/copying/copied_properties.gd")


@export var properties: Dictionary[StringName, CopiedProperty]



func from_object(object: Object) -> void:
	for property_dict: Dictionary[String, Variant] \
	in CopiedProperty.get_serializable_properties(object):
		var copied_property: CopiedProperty = CopiedProperty.new()
		copied_property.from_value(object.get(property_dict["name"]))
		properties[property_dict["name"]] = copied_property



func paste(object: Object) -> void:
	for property_name in properties:
		properties[property_name].paste(object, property_name)


static func transfer_states(
	from: Dictionary[StringName, CopiedProperties],
	to: Dictionary[StringName, CopiedProperties]
) -> void:
	for property_name in from:
		var from_properties: Array[CopiedProperty] = from[property_name].properties
		var to_properties: Array[CopiedProperty] = to[property_name].properties
		var enabled: AgregatedState = agregate_enabled(from_properties)
		match enabled:
			AgregatedState.ALL_ENABLED:
				for copied_property in to_properties:
					copied_property.enabled = true
			AgregatedState.ALL_DISABLED:
				for copied_property in to_properties:
					copied_property.enabled = false
		
		var duplicate: AgregatedState = agregate_enabled(from_properties)
		match duplicate:
			AgregatedState.ALL_ENABLED:
				for copied_property in to_properties:
					copied_property.duplicate = true
			AgregatedState.ALL_DISABLED:
				for copied_property in to_properties:
					copied_property.duplicate = false


static func agregate_enabled(properties: Array[CopiedProperty]) -> AgregatedState:
	var enabled: bool = properties[-1].enabled
	for i in len(properties) - 1:
		if enabled != properties[i].enabled:
			return AgregatedState.MIXED
	
	if enabled:
		return AgregatedState.ALL_ENABLED
	
	return AgregatedState.ALL_DISABLED


static func agregate_duplicate(properties: Array[CopiedProperty]) -> AgregatedState:
	var duplicate: bool = properties[-1].duplicate
	for i in len(properties) - 1:
		if duplicate != properties[i].duplicate:
			return AgregatedState.MIXED
	
	if duplicate:
		return AgregatedState.ALL_ENABLED
	
	return AgregatedState.ALL_DISABLED
