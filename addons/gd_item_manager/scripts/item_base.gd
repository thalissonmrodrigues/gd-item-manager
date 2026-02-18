class_name ItemBase extends Resource


@export var friendly_id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var is_stackable: bool = false
@export_range(1, 999) var max_stack_size: int = 1
@export var weight: float = 0.0
