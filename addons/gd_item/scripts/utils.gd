class_name GDUtils extends Node


const SETTINGS: Dictionary = {
	"DB": {
		"path": "addons/gd_item/general/storage_path",
		"default": "res://item_storage.cfg",
	},
	"ITEMS": {
		"path": "addons/gd_item/general/items_path",
		"default": "res://items/",
	},
	"CATEGORIES": {
		"path": "addons/gd_item/general/categories_path",
		"default": "res://categories/",
	},
}


## Get the settings via the key.
static func get_settings(settings: String) -> Variant:
	var key: String = settings.to_upper()
	if SETTINGS.has(key):
		return ProjectSettings.get_setting(SETTINGS[key].path, SETTINGS[key].default)

	return null


## Get existing resources in the directory.
static func get_resources_from_directory(folder_path: String, file_extension: String) -> Dictionary:
	var resources: Dictionary = {}
	var dir: DirAccess = DirAccess.open(folder_path)

	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()

		while not file_name.is_empty():
			#NOTE Ignores folders and focuses on .gd files.
			if not dir.current_is_dir() and file_name.ends_with(file_extension):
				var full_path: String = folder_path + "/" + file_name
				var resource: Resource = load(full_path)
				var resource_class_name: String

				if resource is GDScript:
					resource_class_name = resource.get_global_name()

				if resource is GDItemBase:
					resource_class_name = resource.display_name

				if resource_class_name.is_empty():
					push_warning("GDItemUtils: Resource '%s'does not have a class_name defined." % [file_name.get_basename()])
					continue

				resources[resource_class_name] = resource

			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("GDItemUtils: Error accessing folder: %s" % [folder_path])

	return resources
