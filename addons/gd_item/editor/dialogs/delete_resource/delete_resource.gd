@tool
extends ConfirmationDialog


signal deletion_request(resource: Resource)

@export var label: Label

var resource: Resource


## Configure the dialog box display.
func setup(resource_to_delete: Resource, section: String) -> void:
	resource = resource_to_delete
	if section == "ITEMS":
		self.title = "Delete Item"
		label.text = "Are you sure you want to delete the item: %s?" % [resource.display_name]
	else:
		self.title = "Delete Category"
		label.text = "Are you sure you want to delete the category: %s?" % [resource.get_global_name()]


## Triggered when the dialog delete button is pressed, then confirm resource deletion.
func _on_confirmed() -> void:
	deletion_request.emit(resource)
	queue_free()
