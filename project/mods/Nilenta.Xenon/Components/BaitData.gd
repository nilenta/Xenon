extends Node

var bait_data = {
	"": {"catch": 0.0, "max_tier": 0, "quality": []},
	"worms": {"catch": 0.06, "max_tier": 1, "quality": [1.0]},
	"cricket": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.05]},
	"leech": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.15, 0.05]},
	"minnow": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.5, 0.25, 0.05]},
	"squid": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.8, 0.45, 0.15, 0.05]},
	"nautilus": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.98, 0.75, 0.55, 0.25, 0.05]}
}

func save_bait(name: String, catch_value: float, quality: Array):
	print("Saving " + str(quality))
	bait_data[name] = {
		"catch": catch_value,
		"max_tier": quality.size(), # LOL
		"quality": quality
	}
	_save_bait_data()


func get_bait_data() -> Dictionary:
	return bait_data

func delete_bait(name: String):
	bait_data.erase(name)
	_save_bait_data()

func load_bait(name: String) -> Dictionary:
	if name in bait_data:
		return bait_data[name]
	else:
		print("[XENON_GD]: Bait with name '", name, "' not found.")
		return {}

func _save_bait_data():
	var path = _get_bait_config_location()
	var json_data = JSON.print(bait_data)
	
	var file = File.new()
	if file.open(path, File.WRITE) == OK:
		file.store_string(json_data)
		file.close()
		print("[XENON_GD]: Bait data successfully saved to ", path)
	else:
		print("[XENON_GD]: Failed to save bait data to ", path)

func _load_bait_data():
	var path = _get_bait_config_location()
	var file = File.new()
	
	if not file.file_exists(path):
		print("[XENON_GD]: Bait config file not found, creating a new one with default values!")
		_save_bait_data()
		return
	
	if file.open(path, File.READ) == OK:
		var data = file.get_as_text()
		file.close()
		
		var result = JSON.parse(data)
		if result.error == OK:
			if typeof(result.result) == TYPE_DICTIONARY:
				bait_data = result.result
				print("[XENON_GD]: Loaded bait data successfully: ", bait_data)
			else:
				print("[XENON_GD]: Bait data is not a dictionary.")
		else:
			print("[XENON_GD]: JSON parse error: ", result.error)
	else:
		print("[XENON_GD]: Failed to open file for reading: ", path)
	
	return bait_data

func _get_bait_config_location() -> String:
	var config_path = "user://XENON_BAIT_DATA.json"
	print("[XENON_GD]: Bait config path is ", config_path)
	return config_path

func _ready():
	pass
