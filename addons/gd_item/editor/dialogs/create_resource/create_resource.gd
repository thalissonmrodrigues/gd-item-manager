@tool
extends ConfirmationDialog


signal creation_request(data: Dictionary)

@export var file_name_line_edit: LineEdit
@export var category_label: Label
@export var category_option_button: OptionButton

var section: String
var _categories: Dictionary = {
	"GDItemBase": preload("res://addons/gd_item/scripts/item.gd")
}


func _ready() -> void:
	_populate_categories()


## Configure the dialog box display.
func setup(current_section: String) -> void:
	section = current_section
	if section == "ITEMS":
		self.title = "Create Item"
		category_label.text = "Category Type"
	else:
		self.title = "Create Category"
		category_label.text = "Extends from"


## Populate the categories field.
func _populate_categories() -> void:
	category_option_button.clear()

	var path: String = GDUtils.get_settings("CATEGORIES")
	if path.is_empty():
		push_warning("GDCreateResource: No path to the category settings was found.")
		return

	var result: Dictionary = GDUtils.get_resources_from_directory(path, ".gd")
	_categories.merge(result)

	var index: int = 0
	for category_name in _categories:
		category_option_button.add_item(category_name, index)
		index += 1


## Triggered when the dialog create button is pressed, then confirm resource creation.
func _on_confirmed() -> void:
	var data: Dictionary = {}

	var category_name: String = category_option_button.get_item_text(category_option_button.selected)
	data = {
		"type": section,
		"category": _categories[category_name],
		"file_name": file_name_line_edit.text.strip_edges()
	}

	if not data.file_name.is_empty():
		creation_request.emit(data)

	queue_free()
