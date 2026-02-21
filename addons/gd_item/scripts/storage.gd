@tool
extends Node


var _cache: Dictionary = {}


## Get item by friendly ID from the storage
func get_item(friendly_id: String) -> GDItemBase:
	if _cache.has(friendly_id):
		return _cache[friendly_id]

	var storage: ConfigFile = _get_storage()
	if not storage:
		return null

	if storage.has_section_key("items", friendly_id):
		var uid: String = storage.get_value("items", friendly_id)
		_cache[friendly_id] = load(uid) as GDItemBase
		return _cache[friendly_id]

	push_error("GDItemStorage: The item %s file was not found." % [friendly_id])
	return null


## Get item storage.
func _get_storage() -> ConfigFile:
	var storage_path: String = ProjectSettings.get_setting("addons/gd_item/general/storage_path", "res://item_storage.cfg")
	var storage: ConfigFile = ConfigFile.new()
	var err: Error = storage.load(storage_path)

	if err != OK:
		push_warning("GDItemStorage: Storage file not found or error loading. Path to storage: %s" % [storage_path])
		return null

	return storage
