@tool
extends EditorPlugin


const SETTING_ITEM_DATABASE_PATH = "addons/gd_item_manager/general/item_database_path"
const DEFAULT_DATABASE_PATH = "res://item_database.cfg"


func _enable_plugin() -> void:
	# Check if the configuration already exists if not, create a default one.
	if not ProjectSettings.has_setting(SETTING_ITEM_DATABASE_PATH):
		ProjectSettings.set_setting(SETTING_ITEM_DATABASE_PATH, DEFAULT_DATABASE_PATH)

	ProjectSettings.set_initial_value(SETTING_ITEM_DATABASE_PATH, DEFAULT_DATABASE_PATH)

	var property_info = {
		"name": SETTING_ITEM_DATABASE_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.cfg"
	}
	ProjectSettings.add_property_info(property_info)
	ProjectSettings.save()

	print("GD Item Manager: enabled.")


func _disable_plugin() -> void:
	# Removes a setting when disabling the plugin.
	if ProjectSettings.has_setting(SETTING_ITEM_DATABASE_PATH):
		ProjectSettings.set_setting(SETTING_ITEM_DATABASE_PATH, null)
		ProjectSettings.save()

	print("GD Item Manager: disabled.")


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
