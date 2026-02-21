@tool
extends Control


@export var item_list: ItemList
@export var content: VBoxContainer
@export var add_item: Button
@export var delete_item: Button
@export var edit_script: Button
@export var reload_list: Button
@export var build_storage: Button
@export var search_item: LineEdit

var _current_item: GDItemBase
var _inspector: EditorInspector
var _search_timer: SceneTreeTimer

const CREATE_ITEM_DIALOG: PackedScene = preload("res://addons/gd_item/editor/dialogs/create_item/create_item.tscn")
const DELETE_ITEM_DIALOG: PackedScene = preload("res://addons/gd_item/editor/dialogs/delete_item/delete_item.tscn")

func _ready() -> void:
	auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED

	add_item.icon = get_theme_icon("Add", "EditorIcons")
	delete_item.icon = get_theme_icon("Remove", "EditorIcons")
	reload_list.icon = get_theme_icon("Reload", "EditorIcons")
	build_storage.icon = get_theme_icon("MainPlay", "EditorIcons")
	edit_script.icon = get_theme_icon("ScriptExtend", "EditorIcons")
	search_item.right_icon = get_theme_icon("Search", "EditorIcons")

	_update_access_to_buttons()

	_inspector = EditorInspector.new()
	_inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(_inspector)

	refresh_item_list()


## Update the list of items.
func refresh_item_list(filters: Dictionary = {}) -> void:
	item_list.clear()

	var path: String = GDUtils.get_settings("ITEMS")
	if path.is_empty():
		push_warning("GDPanel: No path to the item settings was found.")
		return

	var result: Dictionary = GDUtils.get_resources_from_directory(path, ".tres")
	var items: Array = result.values().filter(
		func(item):
			for property in filters:
				if property in item:
					var filter_value: Variant = filters[property]
					var item_value: Variant = item.get(property)

					if filter_value is String and item_value is String:
						if not filter_value.to_lower() in item_value.to_lower():
							return false
						continue

					if filter_value == item_value:
						return false

			# All filters passed.
			return true
	)

	for item in items:
		var idx: int = item_list.add_item(item.display_name)
		item_list.set_item_metadata(idx, item)
		item_list.set_item_icon(idx, item.icon)


## Triggered when the item_selected signal from the item_list is activated, then select the item that was clicked.
func _on_item_list_item_selected(index: int) -> void:
	var item: GDItemBase = item_list.get_item_metadata(index)
	var previous_item: GDItemBase = _inspector.get_edited_object()

	if previous_item == item:
		_deselect_item()
	else:
		_select_item(item)


## Select the item for edit in the inspector.
func _select_item(item: GDItemBase) -> void:
	_current_item = item
	_inspector.edit(_current_item)
	_update_access_to_buttons()


## Deselect the item and remove of inspector.
func _deselect_item() -> void:
	item_list.deselect_all()
	_inspector.edit(null)
	_current_item = null
	_update_access_to_buttons()


## Update access to the buttons.
func _update_access_to_buttons() -> void:
	edit_script.disabled = not _current_item
	delete_item.disabled = not _current_item


## Triggered when the edit_script button is pressed, then redirect to edit the script of the selected item.
func _on_edit_script_pressed() -> void:
	if _current_item:
		var script: Script = _current_item.get_script()
		if script:
			EditorInterface.edit_resource(script)


## Triggered when text is typed into the search field, then applies a filter for list of items.
func _on_search_text_changed(search: String) -> void:
	var current_timer: SceneTreeTimer = get_tree().create_timer(0.5)
	_search_timer = current_timer

	await current_timer.timeout

	if _search_timer == current_timer:
		var filters: Dictionary = {"display_name": search} if not search.is_empty() else {}
		refresh_item_list(filters)


## Triggered when the reload button is pressed, then reload the list of items.
func _on_reload_list_pressed() -> void:
	search_item.text = ""
	_deselect_item()
	refresh_item_list()


## Triggered when the add item button is pressed. then open create item dialog.
func _on_add_item_pressed() -> void:
	var dialog: ConfirmationDialog = CREATE_ITEM_DIALOG.instantiate()
	add_child(dialog)
	_deselect_item()
	dialog.creation_request.connect(_on_create)


## Triggered when receive the `creation_request` signal, then creates the new item.
func _on_create(data: Dictionary):
	var path: String = GDUtils.get_settings("ITEMS")

	if path.is_empty():
		push_warning("GDPanel: No path to the item settings was found.")
		return

	var item: GDItemBase = data.category.new()
	item.friendly_id = data.file_name.to_snake_case()
	item.display_name = data.file_name
	var full_path: String = path + item.friendly_id + ".tres"
	var err: Error = ResourceSaver.save(item, full_path)

	if err != OK:
		push_warning("GDPanel: File creation failed. Path to save: %s ]" % [path])
		return

	EditorInterface.get_resource_filesystem().scan()
	refresh_item_list()


## Triggered when the delete item button is pressed. then open delete item dialog.
func _on_delete_item_pressed() -> void:
	var dialog: ConfirmationDialog = DELETE_ITEM_DIALOG.instantiate()
	add_child(dialog)
	dialog.setup(_current_item)
	dialog.deletion_request.connect(_on_delete)


## Triggered when receive the `deletion request` signal, then delete the current item selected.
func _on_delete(item: GDItemBase) -> void:
	var path: String = item.resource_path
	if FileAccess.file_exists(path):
		var dir: DirAccess = DirAccess.open("res://")
		var err: Error = dir.remove(path)

		if err != OK:
			push_warning("GDPanel: Error deleting file. Error code: %s" % [err])
	else:
		push_warning("The file does not exist in the following path: %s" % [path])

	_deselect_item()
	EditorInterface.get_resource_filesystem().scan()
	refresh_item_list()
