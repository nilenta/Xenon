extends Node

var position_data = {}

func save_position(name: String, position: Vector3, zone: String):
	position_data[name] = {
		"position": [position.x, position.y, position.z],
		"zone": zone
	}
	_save_position_data()

func load_position(name: String) -> Dictionary:
	if name in position_data:
		var pos_dict = position_data[name]
		var pos_array = pos_dict["position"]
		return {
			"position": Vector3(pos_array[0], pos_array[1], pos_array[2]),
			"zone": pos_dict["zone"]
		}
	else:
		print("[XENON_GD]: Position with name '", name, "' not found.")
		return {}

func _save_position_data():
	var path = _get_position_config_location()
	var json_data = JSON.print(position_data)
	
	var file = File.new()
	if file.open(path, File.WRITE) == OK:
		file.store_string(json_data)
		file.close()
		print("[XENON_GD]: Position data successfully saved to ", path)
	else:
		print("[XENON_GD]: Failed to save position data to ", path)

func _load_position_data():
	var path = _get_position_config_location()
	var file = File.new()
	
	if not file.file_exists(path):
		print("[XENON_GD]: Position config file not found, creating a new one!")
		_save_position_data()
		return
	
	if file.open(path, File.READ) == OK:
		var data = file.get_as_text()
		file.close()
		
		var result = JSON.parse(data)
		if result.error == OK:
			if typeof(result.result) == TYPE_DICTIONARY:
				position_data = result.result
				print("[XENON_GD]: Loaded position data successfully: ", position_data)
			else:
				print("[XENON_GD]: Position data is not a dictionary.")
		else:
			print("[XENON_GD]: JSON parse error: ", result.error)
	else:
		print("[XENON_GD]: Failed to open file for reading: ", path)
	
	return position_data

func _get_position_config_location() -> String:
	var config_path = "user://XENON_POSITIONS.json"
	print("[XENON_GD]: Position config path is ", config_path)
	return config_path


func _ready():
	pass
