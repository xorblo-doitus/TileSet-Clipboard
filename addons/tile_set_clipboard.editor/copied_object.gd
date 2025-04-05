extends Resource

const CopiedProperty = preload("res://addons/tile_set_clipboard.editor/copied_property.gd")


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
