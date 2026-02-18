extends Node


var _cache: Dictionary = {}


func get_item(friendly_id: String) -> GDItem:
	if _cache.has(friendly_id):
		return _cache[friendly_id]

	if not ProjectSettings.has_setting(GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH):
		push_warning("GDItemDatabase: The path configuration for the item's database was not found. Path to configuration: %s" % [GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH])
		return null

	var database_path: String = ProjectSettings.get_setting(GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH, GDItemManagerSettings.DEFAULT_DATABASE_PATH)
	var database: ConfigFile = ConfigFile.new()
	var err: Error = database.load(database_path)

	if err != OK:
		push_warning("GDItemDatabase: Database file not found or error loading. Path to database: %s" % [database_path])
		return null

	if database.has_section_key("items", friendly_id):
		var uid = database.get_value("items", friendly_id)
		var item_path = ResourceUID.get_id_path(uid)
		if FileAccess.file_exists(item_path):
			_cache[friendly_id] = load(item_path) as GDItem
			return _cache[friendly_id]
		else:
			push_error("GDItemDatabase: The item file was not found. Path to file: %s" % [item_path])

	return null
