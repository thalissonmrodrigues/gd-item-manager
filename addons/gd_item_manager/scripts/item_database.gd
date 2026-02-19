@tool
extends Node


var _cache: Dictionary = {}


## Get all items from database.
func get_all() -> Array:
	var items: Array = []
	var database: ConfigFile = _get_database()
	if not database:
		#NOTE If the database is null, the _get_database() function will display the error in the terminal, so another push_warning() is not necessary here.
		return items

	if database.has_section("items"):
		var friendly_ids: PackedStringArray = database.get_section_keys("items")

		for friendly_id in friendly_ids:
			if _cache.has(friendly_id):
				items.append(_cache[friendly_id])
				continue

			var uid: String = database.get_value("items", friendly_id)
			var item_path: String = ResourceUID.uid_to_path(uid)
			if FileAccess.file_exists(item_path):
				_cache[friendly_id] = load(item_path) as GDItem
				items.append(_cache[friendly_id])
			else:
				push_error("GDItemDatabase: The item file was not found. Path to file: %s" % [item_path])

	return items


## Get item by friendly ID from the database
func get_item(friendly_id: String) -> GDItem:
	if _cache.has(friendly_id):
		return _cache[friendly_id]

	var database: ConfigFile = _get_database()
	if not database:
		#NOTE If the database is null, the _get_database() function will display the error in the terminal, so another push_warning() is not necessary here.
		return null

	if database.has_section_key("items", friendly_id):
		var uid: String = database.get_value("items", friendly_id)
		var item_path: String = ResourceUID.uid_to_path(uid)
		if FileAccess.file_exists(item_path):
			_cache[friendly_id] = load(item_path) as GDItem
			return _cache[friendly_id]
		else:
			push_error("GDItemDatabase: The item file was not found. Path to file: %s" % [item_path])

	return null


## Get all items where the filters were matched.
func where(filters: Dictionary) -> Array:
	var all_items: Array = get_all()

	if all_items.is_empty():
		return []

	return all_items.filter(
		func(item: GDItem):
			for property in filters:
				if property in item:
					var item_value: Variant = item.get(property)
					var filter_value: Variant = filters[property]

					# If is a string, compare if contains the value.
					if item_value is String and filter_value is String:
						if not filter_value.to_lower() in item_value.to_lower():
							return false
						continue

					# If is a different type, check if are identical.
					if item_value != filter_value:
						return false

			# Passed all the filters!
			return true
	)


## Get item database.
func _get_database() -> ConfigFile:
	if not ProjectSettings.has_setting(GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH):
		push_warning("GDItemDatabase: The path configuration for the item's database was not found. Path to configuration: %s" % [GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH])
		return null

	var database_path: String = ProjectSettings.get_setting(GDItemManagerSettings.SETTING_ITEM_DATABASE_PATH, GDItemManagerSettings.DEFAULT_DATABASE_PATH)
	var database: ConfigFile = ConfigFile.new()
	var err: Error = database.load(database_path)

	if err != OK:
		push_warning("GDItemDatabase: Database file not found or error loading. Path to database: %s" % [database_path])
		return null

	return database
