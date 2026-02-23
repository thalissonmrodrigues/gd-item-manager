@tool
extends Control


@export var item_list: ItemList
@export var content: VBoxContainer
@export var add_button: Button
@export var delete_button: Button
@export var edit_script: Button
@export var reload_list: Button
@export var build_storage: Button
@export var search: LineEdit
@export var items_button: Button
@export var categories_button: Button
@export var _btn_group: ButtonGroup

var _current_resource: Resource
var _inspector: EditorInspector
var _search_timer: SceneTreeTimer

const CREATE_RESOURCE_DIALOG: PackedScene = preload("res://addons/gd_item/editor/dialogs/create_resource/create_resource.tscn")
const DELETE_RESOURCE_DIALOG: PackedScene = preload("res://addons/gd_item/editor/dialogs/delete_resource/delete_resource.tscn")

enum SECTION { ITEMS, CATEGORIES }


func _ready() -> void:
	auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED

	add_button.icon = get_theme_icon("Add", "EditorIcons")
	delete_button.icon = get_theme_icon("Remove", "EditorIcons")
	reload_list.icon = get_theme_icon("Reload", "EditorIcons")
	build_storage.icon = get_theme_icon("MainPlay", "EditorIcons")
	edit_script.icon = get_theme_icon("ScriptExtend", "EditorIcons")
	search.right_icon = get_theme_icon("Search", "EditorIcons")

	_btn_group.pressed.connect(_btn_group_pressed)
	_update_access_to_buttons()

	_inspector = EditorInspector.new()
	_inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(_inspector)

	_refresh_resource_list()


## Update the list of resource.
func _refresh_resource_list(filter: String = "") -> void:
	item_list.clear()

	var data: Dictionary = {}
	var section: SECTION = _get_current_section()
	if section == SECTION.ITEMS:
		data = {
			"settings": "ITEMS",
			"file_extension": ".tres",
		}
	else:
		data = {
			"settings": "CATEGORIES",
			"file_extension": ".gd",
		}

	var path: String = GDUtils.get_settings(data.settings)
	if path.is_empty():
		push_warning("GDPanel: No path to settings was found.")
		return

	var result: Dictionary = GDUtils.get_resources_from_directory(path, data.file_extension)

	var resources: Array = result.values().filter(
		func(resource):
			if not filter.is_empty():
				if section == SECTION.ITEMS:
					return filter.to_lower() in resource.display_name.to_lower()

				if section == SECTION.CATEGORIES:
					return filter.to_lower() in resource.get_global_name().to_lower()

				push_warning("GDPanel: Section does not exist.")
				return false

			# Not exist filter to apply.
			return true
	)

	for resource in resources:
		var title: String
		var icon: Texture2D
		if section == SECTION.ITEMS:
			title = resource.display_name
			icon = resource.icon
		else:
			title = resource.get_global_name()
			icon = get_theme_icon("GDScript", "EditorIcons")

		var idx: int = item_list.add_item(title)
		item_list.set_item_metadata(idx, resource)
		item_list.set_item_icon(idx, icon)


## Triggered when the item_selected signal from the item_list is activated, then select the resource that was clicked.
func _on_item_list_resource_selected(index: int) -> void:
	var resource: Resource = item_list.get_item_metadata(index)
	var previous_resource: Resource = _current_resource

	if previous_resource == resource:
		_deselect_resource()
	else:
		_select_resource(resource)


## Select the resource.
func _select_resource(resource: Resource) -> void:
	_current_resource = resource
	_update_access_to_buttons()

	if _get_current_section() == SECTION.ITEMS:
		_inspector.edit(_current_resource)


## Deselect the resource.
func _deselect_resource() -> void:
	item_list.deselect_all()
	_current_resource = null
	_inspector.edit(null)
	_update_access_to_buttons()


## Update access to the buttons.
func _update_access_to_buttons() -> void:
	edit_script.disabled = not _current_resource
	delete_button.disabled = not _current_resource


## Triggered when the edit_script button is pressed, then redirect to edit the script of the selected resource.
func _on_edit_script_pressed() -> void:
	if not _current_resource:
		return

	var script: GDScript
	if _get_current_section() == SECTION.ITEMS:
		script = _current_resource.get_script()
	else:
		script = _current_resource

	if script:
		EditorInterface.edit_resource(script)
	else:
		push_warning("GDPanel: This resource does not have an associated script.")


## Triggered when text is typed into the search field, then applies a filter for list of resource.
func _on_search_text_changed(search: String) -> void:
	var current_timer: SceneTreeTimer = get_tree().create_timer(0.5)
	_search_timer = current_timer
	await current_timer.timeout
	if _search_timer == current_timer:
		_refresh_resource_list(search)


## Triggered when the reload button is pressed, then reload the list of resource.
func _on_reload_list_pressed() -> void:
	search.text = ""
	_deselect_resource()
	_refresh_resource_list()


## Triggered when the add button is pressed. then open create resource dialog.
func _on_add_button_pressed() -> void:
	var dialog: ConfirmationDialog = CREATE_RESOURCE_DIALOG.instantiate()
	add_child(dialog)
	dialog.setup(SECTION.keys()[_get_current_section()])
	dialog.creation_request.connect(_on_create)


## Triggered when receive the `creation_request` signal, then creates the new resource.
func _on_create(data: Dictionary):
	var err: Error
	var path: String = GDUtils.get_settings(data.type)
	if path.is_empty():
		push_warning("GDPanel: No path to the %s settings was found." % [data.type])
		return

	if data.type == "ITEMS":
		var item: GDItemBase = data.category.new()
		item.friendly_id = data.file_name.to_snake_case()
		item.display_name = data.file_name.capitalize()
		var full_path: String = path + item.friendly_id + ".tres"
		err = ResourceSaver.save(item, full_path)
	else:
		var category: GDScript = GDScript.new()
		category.source_code = "@tool\nclass_name %s extends %s\n" % [data.file_name.to_pascal_case(), data.category.get_global_name()]
		var full_path: String = path + data.file_name.to_snake_case() + ".gd"
		err = ResourceSaver.save(category, full_path)

	if err != OK:
		push_warning("GDPanel: File creation failed. Error code: %s ]" % [err])
		return

	_deselect_resource()
	EditorInterface.get_resource_filesystem().scan()
	_refresh_resource_list()


## Triggered when the delete button is pressed. then open delete resource dialog.
func _on_delete_button_pressed() -> void:
	var dialog: ConfirmationDialog = DELETE_RESOURCE_DIALOG.instantiate()
	add_child(dialog)
	dialog.setup(_current_resource, SECTION.keys()[_get_current_section()])
	dialog.deletion_request.connect(_on_delete)


## Triggered when receive the `deletion request` signal, then delete the current resource selected.
func _on_delete(resource: Resource) -> void:
	var path: String = resource.resource_path
	if FileAccess.file_exists(path):
		var dir: DirAccess = DirAccess.open("res://")
		var err: Error = dir.remove(path)

		if err != OK:
			push_warning("GDPanel: Error deleting file. Error code: %s" % [err])
	else:
		push_warning("The file does not exist in the following path: %s" % [path])

	_deselect_resource()
	EditorInterface.get_resource_filesystem().scan()
	_refresh_resource_list()


## Get current section selected (Items ou Categories).
func _get_current_section() -> SECTION:
	var button_active: BaseButton = _btn_group.get_pressed_button()
	return SECTION.ITEMS if button_active == items_button else SECTION.CATEGORIES


##  Triggered when receive the `pressed` signal of button group.
func _btn_group_pressed(button: BaseButton) -> void:
	_deselect_resource()
	_refresh_resource_list()
