@tool
## The basis for creating items
class_name GDItemBase extends Resource


@export_group("Basic Information")
@export var friendly_id: String
@export var display_name: String
@export_multiline() var description: String
@export var icon: Texture2D = preload("res://addons/gd_item/assets/icon/item.png")
@export var is_stackable: bool = false
@export_range(1, 999) var max_stack_size: int = 1
@export var weight: float = 0.0

#NOTE These parent class properties are ignored, so they don't appear in the file inspector, keeping the item form cleaner, but if you need them, simply remove them from this array.
var _properties_to_ignore: Array = [
	"resource_local_to_scene",
	"resource_path",
	"resource_name",
	"script"
]


func _validate_property(property: Dictionary) -> void:
	if property.name in _properties_to_ignore:
		property.usage = PROPERTY_USAGE_NO_EDITOR
