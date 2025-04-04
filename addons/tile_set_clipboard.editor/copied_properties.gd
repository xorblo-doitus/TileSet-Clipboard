extends RefCounted

const CopiedProperty = preload("res://addons/tile_set_clipboard.editor/copied_property.gd")


## This class has it's own file just because cyclic dependency made Godot mad.

var properties: Array[CopiedProperty]
