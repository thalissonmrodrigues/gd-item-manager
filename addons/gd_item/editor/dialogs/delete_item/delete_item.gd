@tool
extends ConfirmationDialog


signal deletion_request(item: GDItemBase)

@export var label: Label

var item: GDItemBase


## Configure the dialog box display.
func setup(item_to_delete: GDItemBase) -> void:
	item = item_to_delete
	label.text = "Are you sure you want to delete the item: %s?" % [item.display_name]


## Triggered when the dialog delete button is pressed, then confirm item deletion.
func _on_confirmed() -> void:
	deletion_request.emit(item)
	queue_free()
