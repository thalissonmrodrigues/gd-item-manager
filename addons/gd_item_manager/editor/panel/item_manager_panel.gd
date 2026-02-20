@tool
extends Control


@export var item_list: ItemList
@export var content: VBoxContainer
@export var add_item: Button
@export var remove_item: Button
@export var edit_script: Button
@export var reload_list: Button
@export var search_item: LineEdit

var _current_item: GDItem
var _inspector: EditorInspector
var _search_timer: SceneTreeTimer

const CREATE_ITEM_AND_CATEGORY_DIALOG = preload("res://addons/gd_item_manager/editor/dialog/create_item_and_category.tscn")

func _ready() -> void:
	auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED

	add_item.icon = get_theme_icon("Add", "EditorIcons")
	remove_item.icon = get_theme_icon("Remove", "EditorIcons")
	edit_script.icon = get_theme_icon("ScriptExtend", "EditorIcons")
	reload_list.icon = get_theme_icon("Reload", "EditorIcons")
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

	var items: Array = GDItemDatabase.where(filters)
	if not items.is_empty():
		# Compare the name 'a' with the name 'b' returns true if 'a' should come before 'b'.
		items.sort_custom(func(a, b):
			return a.display_name.naturalnocasecmp_to(b.display_name) < 0
		)

		for item in items as Array[GDItem]:
			var idx: int = item_list.add_item(item.display_name)
			item_list.set_item_metadata(idx, item)
			item_list.set_item_icon(idx, item.icon)


## Triggered when the item_selected signal from the item_list is activated, then select the item that was clicked.
func _on_item_list_item_selected(index: int) -> void:
	var item: GDItem = item_list.get_item_metadata(index)
	var previous_item: GDItem = _inspector.get_edited_object()

	if previous_item == item:
		_deselect_item()
	else:
		_select_item(item)


## Select the item for edit in the inspector.
func _select_item(item: GDItem) -> void:
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
	remove_item.disabled = not _current_item


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
	refresh_item_list()












func _on_add_item_pressed() -> void:
	var dialog: ConfirmationDialog = CREATE_ITEM_AND_CATEGORY_DIALOG.instantiate()
	add_child(dialog)
	_deselect_item()
	dialog.creation_requested.connect(_on_create_requested)




func _on_create_requested(data: Dictionary):
	if data.type == "ITEM":
		var items_folder: String = ProjectSettings.get_setting(GDItemManagerSettings.SETTING_ITEMS_PATH, GDItemManagerSettings.DEFAULT_ITEMS_PATH)

		var item: GDItem = data.category.new()
		item.friendly_id = data.file_name.to_snake_case()
		item.display_name = data.file_name
		var path = items_folder + item.friendly_id + ".tres"
		var err = ResourceSaver.save(item, path)

		if err != OK:
			push_warning("GDItemManagerPanel: File creation failed. Path to save: %s ]" % [path])
			return

		var uid = ResourceLoader.get_resource_uid(path)
		if uid == -1:
			push_error("GDItemDatabase: Error retrieving UID")
			return
		var uid_string = ResourceUID.id_to_text(uid)
		err = GDItemDatabase.add_item(item.friendly_id, uid_string)

		if err == OK:
			refresh_item_list()

		return

	#if data.type == "CATEGORY":
		## Criação de um novo Script (.gd) que extende a categoria
		#var path = base_folder + data.file_name + ".gd"
		#var content = "@tool\nextends %s\nclass_name %s\n" % [data.base_script, data.file_name.to_pascal_case()]
#
		#var file = FileAccess.open(path, FileAccess.WRITE)
		#file.store_string(content)
		#file.close()
#
		#EditorInterface.get_resource_filesystem().scan()
		#await EditorInterface.get_resource_filesystem().sources_changed
		#EditorInterface.edit_resource(load(path))
