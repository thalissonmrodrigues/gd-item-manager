@tool
extends ConfirmationDialog

signal creation_requested(data: Dictionary)

@export var tab_container: TabContainer
@export var item_category_options: OptionButton
@export var file_name: LineEdit
@export var category_extender_options: OptionButton
@export var category_file_name: LineEdit
var _categories: Dictionary = {
	"GDItem": preload("res://addons/gd_item_manager/scripts/item.gd")
}

func _ready():
	confirmed.connect(_on_confirmed)
	_map_scripts_in_dir()
	_populate_initial_data()

func _populate_initial_data():
	item_category_options.clear()
	category_extender_options.clear()

	var index: int = 0
	for category_name in _categories:
		item_category_options.add_item(category_name, index)
		category_extender_options.add_item(category_name, index)
		index += 1

func _on_confirmed():
	var data = {}

	if tab_container.current_tab == 0:
		var category_name: String = item_category_options.get_item_text(item_category_options.selected)
		data = {
			"type": "ITEM",
			"category": _categories[category_name],
			"file_name": file_name.text.strip_edges()
		}

	#else:
		#data = {
			#"type": "CATEGORY",
			#"base_script": category_extender_options.get_item_text(category_extender_options.selected),
			#"file_name": category_file_name.text.strip_edges()
		#}

	if not data.file_name.is_empty():
		creation_requested.emit(data)

	queue_free()


## Maps existing scripts in the categories directory.
func _map_scripts_in_dir() -> void:
	var category_folder: String = ProjectSettings.get_setting(GDItemManagerSettings.SETTING_ITEM_CATEGORY_PATH, GDItemManagerSettings.DEFAULT_ITEM_CATEGORY_PATH)
	var dir: DirAccess = DirAccess.open(category_folder)

	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()

		while not file_name.is_empty():
			#NOTE Ignores folders and focuses on .gd files.
			if not dir.current_is_dir() and file_name.ends_with(".gd"):
				var full_path: String = category_folder + "/" + file_name
				var script: GDScript = load(full_path)

				if script is GDScript:
					var class_name_str: String = script.get_global_name()

					if class_name_str.is_empty():
						push_warning("CreateItemAndCategory: Script '%s.gd'does not have a class_name defined." % [file_name.get_basename()])
						continue

					_categories[class_name_str] = script

			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("CreateItemAndCategory: Error accessing folder: %s" % [category_folder])
