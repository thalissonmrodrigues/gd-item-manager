@tool
extends EditorPlugin


const AUTOLOAD_NAME: String = "GDItemDatabase"


func _enable_plugin() -> void:
	# Create autoload.
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/gd_item_manager/scripts/item_database.gd")

	# Check if the configuration already exists if not, create a default one.
	if not ProjectSettings.has_setting(GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH):
		ProjectSettings.set_setting(GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH, GDItemManagerSettings.DEFAULT_DATABASE_PATH)

	ProjectSettings.set_initial_value(GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH, GDItemManagerSettings.DEFAULT_DATABASE_PATH)

	var property_info = {
		"name": GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.cfg"
	}
	ProjectSettings.add_property_info(property_info)
	ProjectSettings.save()

	print("GD Item Manager: enabled.")


func _disable_plugin() -> void:
	# Removes autoload.
	remove_autoload_singleton(AUTOLOAD_NAME)

	# Removes a setting when disabling the plugin.
	if ProjectSettings.has_setting(GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH):
		ProjectSettings.set_setting(GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH, null)
		ProjectSettings.save()

	print("GD Item Manager: disabled.")


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
