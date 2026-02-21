@tool
extends EditorPlugin


var _gd_panel: Control


func _enable_plugin() -> void:
	add_autoload_singleton("GDItemStorage", "res://addons/gd_item/scripts/storage.gd")
	_create_settings()
	print("GD Item: enabled.")


func _disable_plugin() -> void:
	remove_autoload_singleton("GDItemStorage")
	_remove_settings()
	print("GD Item: disabled.")


func _enter_tree() -> void:
	# Adds the item panel to the editor.
	_gd_panel = load("res://addons/gd_item/editor/panel/panel.tscn").instantiate()
	EditorInterface.get_editor_main_screen().add_child(_gd_panel)
	_make_visible(false)


func _exit_tree() -> void:
	# Remove item panel to the editor.
	if _gd_panel:
		_gd_panel.queue_free()


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return "GD Item"


func _make_visible(visible) -> void:
	if _gd_panel:
		_gd_panel.visible = visible


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("Object", "EditorIcons")


## Create settings if not exists.
func _create_settings() -> void:
	for settings in GDUtils.SETTINGS.values():
		if not ProjectSettings.has_setting(settings.path):
			ProjectSettings.set_setting(settings.path, settings.default)

		var property_info: Dictionary = {
			"name": settings.path,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.cfg"
		}
		ProjectSettings.add_property_info(property_info)

	ProjectSettings.save()


## Remove settings if exists.
func _remove_settings():
	for settings in GDUtils.SETTINGS.values():
		if not ProjectSettings.has_setting(settings.path):
			ProjectSettings.set_setting(settings.path, null)

	ProjectSettings.save()
