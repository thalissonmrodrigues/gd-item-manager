@tool
extends ConfirmationDialog


signal creation_request(data: Dictionary)

@export var file_name: LineEdit
@export var category: OptionButton

var _categories: Dictionary = {
	"GDItemBase": preload("res://addons/gd_item/scripts/item.gd")
}


func _ready() -> void:
	_populate_categories()


## Populate the categories field.
func _populate_categories() -> void:
	category.clear()

	var path: String = GDUtils.get_settings("CATEGORIES")
	if path.is_empty():
		push_warning("GDCreateItem: No path to the item settings was found.")
		return

	var result: Dictionary = GDUtils.get_resources_from_directory(path, ".gd")
	_categories.merge(result)

	var index: int = 0
	for category_name in _categories:
		category.add_item(category_name, index)
		index += 1


## Triggered when the dialog create button is pressed, then confirm item creation.
func _on_confirmed() -> void:
	var data: Dictionary = {}

	var category_name: String = category.get_item_text(category.selected)
	data = {
		"type": "ITEM",
		"category": _categories[category_name],
		"file_name": file_name.text.strip_edges()
	}

	if not data.file_name.is_empty():
		creation_request.emit(data)

	queue_free()
