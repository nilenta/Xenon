extends Node

var _Player: Node
var _PlayerData: Node
var _Globals: Node
var xenon_interface: VBoxContainer
var _Network: Node
var _Data
var xenon_panels_data: Array = []

func setup(Player: Node, PlayerData: Node, Globals: Node, Interface: VBoxContainer, Data, _tree, Network, _posData, PopupMsg) -> void:
	_Player = Player
	_PlayerData = PlayerData
	_Globals = Globals
	_Network = Network
	xenon_interface = Interface
	_Data = Data  # LOL
	
	xenon_panels_data = [
		{
			"name": "Player Sprint Speed",
			"requireRestart": true,
			"description": "Adjusts your speed when you hold down shift to sprint.\nDefault value is 6.44\nNyoom value is 6.88",
			"elements": [
				{"type": "float", "name": "PlayerSprintSpeed", "initial_value": _Data.config_data["PlayerSprintSpeed"], "key": "PlayerSprintSpeed"},
			]
		},
		{
			"name": "Player Dive Distance",
			"requireRestart": true,
			"description": "Adjusts the distance you are shot when you dive.\nDefault value is 9\nNyoom value is 15",
			"elements": [
				{"type": "float", "name": "PlayerDiveDistance", "initial_value": _Data.config_data["PlayerDiveDistance"], "key": "PlayerDiveDistance"},
			]
		},
		{
			"name": "Player Jump Height",
			"requireRestart": true,
			"description": "Adjusts the max jump height.\nDefault value is 6\nNyoom value is 7.5",
			"elements": [
				{"type": "float", "name": "PlayerJumpHeight", "initial_value": _Data.config_data["PlayerJumpHeight"], "key": "PlayerJumpHeight"},
			]
		},
		{
			"name": "Player Speed Multiplier",
			"requireRestart": true,
			"description": "Speed multiplier applied to stuff like diving.\nDefault value is 1\nNyoom value is 1.35",
			"elements": [
				{"type": "float", "name": "PlayerSpeedMult", "initial_value": _Data.config_data["PlayerSpeedMult"], "key": "PlayerSpeedMult"},
			]
		},
		{
			"name": "Player Gravity",
			"requireRestart": true,
			"description": "A fun one.\nDefault value is 32",
			"elements": [
				{"type": "float", "name": "PlayerGravity", "initial_value": _Data.config_data["PlayerGravity"], "key": "PlayerGravity"},
			]
		},
		{
			"name": "Player Walkspeed",
			"requireRestart": true,
			"description": "A fun one.\nDefault value is 3.2",
			"elements": [
				{"type": "float", "name": "PlayerWalkSpeed", "initial_value": _Data.config_data["PlayerWalkSpeed"], "key": "PlayerWalkSpeed"},
			]
		},
		{
			"name": "Uncap Zoom",
			"requireRestart": true,
			"description": "Uncaps zooming, which will allow you to zoom as far out as you want.",
			"elements": [
				{"type": "boolean", "name": "ZoomUncapped", "initial_value": _Data.config_data["UncapZoom"], "key": "UncapZoom"},
			]
		},
		{
			"name": "Fishing Without Bait",
			"requireRestart": true,
			"description": "Lets you be able to fish with no bait equipped.",
			"elements": [
				{"type": "boolean", "name": "AllowFishingWithNoBait", "initial_value": _Data.config_data["AllowFishingWithNoBait"], "key": "AllowFishingWithNoBait"},
			]
		},
		{
			"name": "No Bait OP",
			"requireRestart": true,
			"description": "Makes fishing with no bait overpowered. If this is disabled, fishing without bait will just make you catch nothing without bait.",
			"elements": [
				{"type": "boolean", "name": "NoBaitOP", "initial_value": _Data.config_data["NoBaitOP"], "key": "NoBaitOP"},
			]
		},
		{
			"name": "Fish Anywhere",
			"requireRestart": true,
			"description": "Fun value. Lets you fish [b]anywhere[/b]. This means you can fish on the ground and other stuff.",
			"elements": [
				{"type": "boolean", "name": "FishAnywhere", "initial_value": _Data.config_data["FishAnywhere"], "key": "FishAnywhere"},
			]
		},
		{
			"name": "Instant Catch",
			"requireRestart": true,
			"description": "Any bait used will immediately catch something.",
			"elements": [
				{"type": "boolean", "name": "InstantCatch", "initial_value": _Data.config_data["InstantCatch"], "key": "InstantCatch"},
			]
		},
		{
			"name": "Belly Slide",
			"requireRestart": true,
			"description": "Allows inputs while in dive mode on the ground.",
			"elements": [
				{"type": "boolean", "name": "BellySlide", "initial_value": _Data.config_data["BellySlide"], "key": "BellySlide"},
			]
		},
		{
			"name": "Freecam Movement Speed",
			"requireRestart": true,
			"description": "Increase the speed. Simple as that.\nDefault is 4.0",
			"elements": [
				{"type": "float", "name": "FreecamMovementSpeed", "initial_value": _Data.config_data["FreecamMovementSpeed"], "key": "FreecamMovementSpeed"},
			]
		},
		{
			"name": "Uncap Freecam",
			"requireRestart": true,
			"description": "Lets you move further than 15 from your player origin.",
			"elements": [
				{"type": "boolean", "name": "UncapFreecamMovement", "initial_value": _Data.config_data["UncapFreecamMovement"], "key": "UncapFreecamMovement"},
			]
		},
		{
			"name": "No Item Cooldown",
			"requireRestart": true,
			"description": "Oh boy i sure wonder what this does! (this actually just removes the cooldown from boxing gloves Have fun with that)",
			"elements": [
				{"type": "boolean", "name": "NoItemCooldown", "initial_value": _Data.config_data["NoItemCooldown"], "key": "NoItemCooldown"},
			]
		},
		
	]
	
	_load_panels()

func _load_panels() -> void:
	var button = Button.new()
	button.text = "Restart Game"
	button.connect("pressed", self, "_restart_game")
	xenon_interface.add_child(button)
	
	var tooltip = preload("res://Scenes/Singletons/Tooltips/tooltip_node.tscn").instance()
	tooltip.header = "[color=#6a4420]Restart Game"
	tooltip.body = "Restarts the game. Skibidi toilet.\n\nAlso if you're in a game you will rejoin it."
	button.add_child(tooltip)
	
	for panel_info in xenon_panels_data:
		_add_panel_to_interface(panel_info)

func _add_panel_to_interface(panel_info: Dictionary) -> void:
	print("[XENON_GD]: Adding panel: " + panel_info.name + " to interface")
	var xenon_button_panel = preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/xenon_panel.tscn").instance()
	xenon_button_panel.get_node("HBoxContainer/Info/Name").bbcode_text = panel_info.name

	for element in panel_info.elements:
		if element["type"] == "button":
			var button = Button.new()
			button.text = element["text"]
			var params = element.get("params", [])
			button.connect("pressed", self, element["handler"], params)
			xenon_button_panel.get_node("HBoxContainer").add_child(button)

		elif element["type"] == "input":
			var text_input = LineEdit.new()
			text_input.text = element["initial_value"]
			text_input.name = element["name"]
			text_input.connect("text_changed", self, "_on_text_changed", [element["key"]])
			xenon_button_panel.get_node("HBoxContainer").add_child(text_input)

		elif element["type"] == "boolean":
			var option = OptionButton.new()
			option.add_item("Enabled")
			option.add_item("Disabled")
			option.selected = 0 if _Data.config_data[element["key"]] else 1
			option.connect("item_selected", self, "_on_option_selected", [element["key"]])
			xenon_button_panel.get_node("HBoxContainer").add_child(option)

		elif element["type"] == "float" or element["type"] == "integer":
			var number_input = LineEdit.new()
			number_input.text = str(element["initial_value"])
			number_input.name = element["name"]
			number_input.connect("text_changed", self, "_on_number_changed", [element["key"], element["type"]])
			xenon_button_panel.get_node("HBoxContainer").add_child(number_input)

		elif element["type"] == "string":
			var string_input = LineEdit.new()
			string_input.text = element["initial_value"]
			string_input.name = element["name"]
			string_input.connect("text_changed", self, "_on_string_changed", [element["key"]])
			xenon_button_panel.get_node("HBoxContainer").add_child(string_input)

	xenon_interface.add_child(xenon_button_panel)
	var tooltip = preload("res://Scenes/Singletons/Tooltips/tooltip_node.tscn").instance()
	tooltip.header = "[color=#6a4420]" + panel_info.name
	tooltip.body = panel_info.description
	if panel_info.requireRestart:
		tooltip.body += "\n\n[b][color=red]The game must be restarted for changes to this configuration to take effect.[/color][/b]"
	xenon_button_panel.get_node("HBoxContainer/Info/Name").add_child(tooltip)

func _on_option_selected(selected_index: int, key: String) -> void:
	print("[XENON_GD]: Option selected for key '" + key + "': " + str(selected_index))
	_Data.config_data[key] = selected_index == 0
	_Data._save_config()

func _on_number_changed(current_text: String, key: String, value_type: String) -> void:
	print("[XENON_GD]: Number changed in input field for key '" + key + "': " + current_text)
	if key in _Data.config_data:
		if value_type == "float":
			_Data.config_data[key] = float(current_text)
		elif value_type == "integer":
			_Data.config_data[key] = int(current_text)
		_Data._save_config()

func _on_string_changed(current_text: String, key: String) -> void:
	print("[XENON_GD]: String changed in input field for key '" + key + "': " + current_text)
	if key in _Data.config_data:
		_Data.config_data[key] = current_text
		_Data._save_config()

func _restart_game():
	var steam_app_id = "3146520"
	var steamjoinarg = "steam://run/" + steam_app_id
	print("[XENON_GD]: ", steamjoinarg)
	
	if _Network.LOBBY_CODE:
		var file = File.new()
		var save_path = "user://lobbyCODESAVETEMP.save"
		
		if file.open(save_path, File.WRITE) == OK:
			file.store_string(_Network.LOBBY_CODE)
			file.close()
			print("[XENON_GD]: Lobby code saved to ", save_path)
		else:
			print("[XENON_GD]: Failed to save lobby code to ", save_path)
		
	OS.shell_open(steamjoinarg)
	xenon_interface.get_tree().quit()
