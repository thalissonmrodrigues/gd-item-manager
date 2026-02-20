@tool
extends EditorPlugin


const AUTOLOAD_NAME: String = "GDItemDatabase"
var _item_manager_panel: Control


func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/gd_item_manager/scripts/item_database.gd")
	_create_settings()

	print("GD Item Manager: enabled.")


func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
	_remove_settings()

	print("GD Item Manager: disabled.")


func _enter_tree() -> void:
	# Adds the item manger panel to the editor.
	_item_manager_panel = load("res://addons/gd_item_manager/editor/panel/item_manager_panel.tscn").instantiate()
	EditorInterface.get_editor_main_screen().add_child(_item_manager_panel)
	_make_visible(false)


func _exit_tree() -> void:
	# Remove item manger panel to the editor.
	if _item_manager_panel:
		_item_manager_panel.queue_free()


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return "GD Item Manager"


func _make_visible(visible) -> void:
	if _item_manager_panel:
		_item_manager_panel.visible = visible


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("Object", "EditorIcons")

## Create settings if not exists.
func _create_settings() -> void:
	# Database path.
	if not ProjectSettings.has_setting(GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH):
		ProjectSettings.set_setting(GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH, GDItemManagerSettings.DEFAULT_DATABASE_PATH)

	var property_info: Dictionary = {
		"name": GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.cfg"
	}
	ProjectSettings.add_property_info(property_info)

	# Items path.
	if not ProjectSettings.has_setting(GDItemManagerSettings.SETTING_ITEMS_PATH):
		ProjectSettings.set_setting(GDItemManagerSettings.SETTING_ITEMS_PATH, GDItemManagerSettings.DEFAULT_ITEMS_PATH)

	property_info = {
		"name": GDItemManagerSettings.SETTING_ITEMS_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.cfg"
	}
	ProjectSettings.add_property_info(property_info)

	# Categories path.
	if not ProjectSettings.has_setting(GDItemManagerSettings.SETTING_ITEM_CATEGORY_PATH):
		ProjectSettings.set_setting(GDItemManagerSettings.SETTING_ITEM_CATEGORY_PATH, GDItemManagerSettings.DEFAULT_ITEM_CATEGORY_PATH)

	property_info = {
		"name": GDItemManagerSettings.SETTING_ITEM_CATEGORY_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.cfg"
	}
	ProjectSettings.add_property_info(property_info)

	ProjectSettings.save()


## Remove settings if exists.
func _remove_settings():
	# Database path.
	if ProjectSettings.has_setting(GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH):
		ProjectSettings.set_setting(GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH, null)

	# Items path.
	if ProjectSettings.has_setting(GDItemManagerSettings.SETTING_ITEMS_PATH):
		ProjectSettings.set_setting(GDItemManagerSettings.SETTING_ITEMS_PATH, null)

	# Categories path.
	if ProjectSettings.has_setting(GDItemManagerSettings.SETTING_ITEM_CATEGORY_PATH):
		ProjectSettings.set_setting(GDItemManagerSettings.SETTING_ITEM_CATEGORY_PATH, null)

	ProjectSettings.save()
