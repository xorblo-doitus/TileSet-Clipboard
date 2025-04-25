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
	return from_object_and_properties(
		object,
		CopiedProperty.get_serializable_property_names(object)
	)


func from_object_and_properties(object: Object, property_names: Array[StringName]) -> void:
	for property_name in property_names:
		var copied_property: CopiedProperty = CopiedProperty.new()
		copied_property.from_value(object.get(property_name))
		properties[property_name] = copied_property


func paste(object: Object) -> void:
	var history: EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()
	var object_properties: Array[StringName] = get_property_names([object])
	var backups: Dictionary[StringName, Variant] = {}
	for property_name in object_properties:
		if not properties.has(property_name):
			backups[property_name] = object.get(property_name)
	
	paste_unsafe(object)
	
	for property_name in backups:
		history.add_undo_property(object, property_name, backups[property_name])


func paste_unsafe(object: Object) -> void:
	for property_name in properties:
		properties[property_name].paste(object, property_name)


static func get_property_names(objects: Array[Object]) -> Array[StringName]:
	# Use a dictionary to reduce complexity from O(n²) to O(n)
	var dict: Dictionary[StringName, bool] = {}
	for object in objects:
		for property_name in CopiedProperty.get_serializable_property_names(object):
			dict[property_name] = true
	return dict.keys()


static func transfer_states(
	from: Dictionary[StringName, CopiedProperties],
	to: Dictionary[StringName, CopiedProperties],
	enabled_cache: Dictionary[StringName, bool],
	duplicate_cache: Dictionary[StringName, bool],
) -> void:
	var to_properties: Array[CopiedProperty]
	
	for property_name in from:
		var from_properties: Array[CopiedProperty] = from[property_name].properties
		if from_properties.is_empty():
			if property_name in enabled_cache:
				var enabled: bool = enabled_cache[property_name]
				for copied_property in to_properties:
					copied_property.enabled = enabled
			if property_name in duplicate_cache:
				var duplicate: bool = duplicate_cache[property_name]
				for copied_property in to_properties:
					copied_property.duplicate = duplicate
			continue
		
		var agregated_enabled: AgregatedState = agregate_enabled(from_properties)
		var agregated_duplicate: AgregatedState = agregate_duplicate(from_properties)
		
		save_agregation(enabled_cache, property_name, agregated_enabled)
		save_agregation(duplicate_cache, property_name, agregated_duplicate)
		
		if property_name in to:
			to_properties = to[property_name].properties
			match agregated_enabled:
				AgregatedState.ALL_ENABLED:
					for copied_property in to_properties:
						copied_property.enabled = true
				AgregatedState.ALL_DISABLED:
					for copied_property in to_properties:
						copied_property.enabled = false
			
			match agregated_duplicate:
				AgregatedState.ALL_ENABLED:
					for copied_property in to_properties:
						copied_property.duplicate = true
				AgregatedState.ALL_DISABLED:
					for copied_property in to_properties:
						copied_property.duplicate = false
	
	for property_name in to:
		if not property_name in from:
			to_properties = to[property_name].properties
			if property_name in enabled_cache:
				var enabled: bool = enabled_cache[property_name]
				for copied_property in to_properties:
					copied_property.enabled = enabled
			if property_name in duplicate_cache:
				var duplicate: bool = duplicate_cache[property_name]
				for copied_property in to_properties:
					copied_property.duplicate = duplicate


static func save_agregation(
	cache: Dictionary[StringName, bool],
	property_name: StringName,
	state: AgregatedState,
) -> void:
	match state:
		AgregatedState.ALL_ENABLED:
			cache[property_name] = true
		AgregatedState.MIXED:
			cache.erase(property_name)
		AgregatedState.ALL_DISABLED:
			cache[property_name] = false


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
