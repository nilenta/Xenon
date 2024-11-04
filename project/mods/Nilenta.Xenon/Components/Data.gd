extends Node


var config_data = {
	"PlayerSprintSpeed": 6.44,
	"PlayerDiveDistance": 9,
	"PlayerWalkSpeed": 3.2,
	"PlayerJumpHeight": 6,
	"PlayerSpeedMult": 1,
	"PlayerGravity": 32,
	"UncapZoom": false,
	"AllowFishingWithNoBait": false,
	"NoBaitOP": false,
	"FishAnywhere": false,
	"FishingAutoClicker": false,
	"InstantCatch": false,
	"BellySlide": false,
	"UncapFreecamMovement": 4.0,
	"FreecamMovementSpeed": false,
	"NoItemCooldown": false
}

func _load_saved_lobby_code():
	var file = File.new()
	var save_path = "user://lobbyCODESAVETEMP.save"
	var lobby_code = null
	
	if file.file_exists(save_path):
		if file.open(save_path, File.READ) == OK:
			lobby_code = file.get_as_text()
			file.close()
			
			var dir = Directory.new()
			if dir.remove(save_path) == OK:
				print("[XENON_GD]: Lobby code loaded and file deleted successfully.")
			else:
				print("[XENON_GD]: Failed to delete the lobby code file.")
		else:
			print("[XENON_GD]: Failed to open the lobby code file for reading.")
	else:
		print("[XENON_GD]: Lobby code file does not exist at ", save_path)

	return lobby_code

func _get_config_location() -> String:
	var exe_path = OS.get_executable_path().get_base_dir()
	var config_path = exe_path.plus_file("GDWeave").plus_file("configs").plus_file("Nilenta.Xenon.json")
	
	var dir = Directory.new()
	if dir.make_dir_recursive(config_path.get_base_dir()) != OK:
		print("[XENON_GD]: Failed to create config directory - ", config_path.get_base_dir())
	
	print("[XENON_GD]: Config path is ", config_path)
	return config_path

func _save_config():
	var path = _get_config_location()
	var json_data = JSON.print(config_data)
	
	var file = File.new()
	if file.open(path, File.WRITE) == OK:
		file.store_string(json_data)
		file.close()
		print("[XENON_GD]: Config successfully saved to ", path)
	else:
		print("[XENON_GD]: Failed to save config to ", path)

func _load_config():
	var path = _get_config_location()
	var file = File.new()
	
	if not file.file_exists(path):
		print("[XENON_GD]: Config file not found, creating a new one!")
		_save_config()
		return
	
	if file.open(path, File.READ) == OK:
		var data = file.get_as_text()
		file.close()
		
		var result = JSON.parse(data)
		if result.error == OK:
			if typeof(result.result) == TYPE_DICTIONARY:
				config_data = result.result
				print("[XENON_GD]: Loaded config successfully: ", config_data)
			else:
				print("[XENON_GD]: Config data is not a dictionary.")
		else:
			print("[XENON_GD]: JSON parse error: ", result.error)
	else:
		print("[XENON_GD]: Failed to open file for reading: ", path)
	

func _ready():
	pass
