extends Node

var _Player: Node
var _PlayerData: Node
var _Globals: Node
var xenon_interface: VBoxContainer
var _Network: Node
var _options = {
	"Message": "",
	"ChalkSize": 2
}
var xenon_panels_data: Array = []
var hooks

func setup(Player: Node, PlayerData: Node, Globals: Node, Interface: VBoxContainer, Data, _tree, Network, _posData, PopupMsg) -> void:
	_Player = Player
	_PlayerData = PlayerData
	_Globals = Globals
	_Network = Network
	xenon_interface = Interface
	
	var hooks_nodes = _tree.get_nodes_in_group("HooksGroup")
	if hooks_nodes.size() > 0:
		hooks = hooks_nodes[0]
		_options = hooks._get_options()
		hooks._set_player(_Player)
	
	xenon_panels_data = [
		{
			"name": "Chalk Size",
			"description": "can be between 0.1 and 10.",
			"elements": [
				{"type": "float", "name": "ChalkSize", "initial_value": _options["ChalkSize"], "key": "ChalkSize"},
			]
		},
		{
			"name": "Punch Yourself",
			"description": "ffuck you in particular\n\nOnly works if griefing enabled",
			"elements": [
				{"type": "button", "text": "Punch", "handler": "_punchself", "params": []}
			]
		},
		{
			"name": "Crash Game",
			"description": "This will crash your game.",
			"elements": [
				{"type": "button", "text": "Crash", "handler": "_CRASH", "params": []}
			]
		}
	]
	
	
	
	_load_panels()

func _load_panels() -> void:
	if _Network.GAME_MASTER:
		for panel_data in xenon_panels_data:
			if panel_data.get("name") == "Punch Yourself":
				panel_data["name"] = "Punch"
				panel_data["elements"].append({
					"type": "button",
					"text": "Punch Everyone",
					"handler": "_punchall",
					"params": []
				})
			break
	
	for panel_info in xenon_panels_data:
		_add_panel_to_interface(panel_info)

func _add_panel_to_interface(panel_info: Dictionary) -> void:
	print("[XENON_GD]: Adding panel: " + panel_info.name + " to interface")
	var xenon_button_panel = preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/xenon_panel.tscn").instance()
	xenon_button_panel.get_node("HBoxContainer/Info/Name").bbcode_text = panel_info.name

	for element in panel_info.elements:
		if element["type"] == "button":
			var button = Button.new()
			button.text = "   " + element["text"] + "   "
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
			option.selected = 0 if _options[element["key"]] else 1
			option.connect("item_selected", self, "_on_option_selected", [element["key"]])
			xenon_button_panel.get_node("HBoxContainer").add_child(option)
		elif element["type"] == "dropdown":
			var option_button = OptionButton.new()
			for option in element["options"]:
				option_button.add_item(option)
			option_button.name = element["name"]
			option_button.selected = element["options"].find(_options[element["key"]]) if _options.has(element["key"]) else 0
			option_button.connect("item_selected", self, "_on_dropdown_selected", [element["key"], element["options"]])
			xenon_button_panel.get_node("HBoxContainer").add_child(option_button)
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
	xenon_button_panel.get_node("HBoxContainer/Info/Name").add_child(tooltip)


# ELEMENT HANDLERS
func _on_option_selected(selected_index: int, key: String) -> void:
	print("[XENON_GD]: Option selected for key '" + key + "': " + str(selected_index))
	_options[key] = selected_index == 0
	if hooks: hooks._set_option(key, selected_index == 0)

func _on_number_changed(current_text: String, key: String, value_type: String) -> void:
	print("[XENON_GD]: Number changed in input field for key '" + key + "': " + current_text)
	if key in _options:
		if value_type == "float":
			_options[key] = float(current_text)
			if hooks: hooks._set_option(key, float(current_text))
		elif value_type == "integer":
			_options[key] = int(current_text)
			if hooks: hooks._set_option(key, int(current_text))

func _on_string_changed(current_text: String, key: String) -> void:
	print("[XENON_GD]: String changed in input field for key '" + key + "': " + current_text)
	if key in _options:
		_options[key] = current_text
		if hooks: hooks._set_option(key, current_text)

func _on_dropdown_selected(selected_index: int, key: String, options: Array) -> void:
	print("[XENON_GD]: Dropdown selected for key '" + key + "': " + options[selected_index])
	_options[key] = options[selected_index]
	if hooks: hooks._set_option(key, options[selected_index])

# FUNCS
func _chatmsg() -> void:
	print("GO")
	_Network._send_P2P_Packet({"type": "message", "message": _options["Message"], "sender": 1, "local": false, "position": _Player.global_transform.origin, "zone": "Global", "zone_owner": 1}, "all", 2)
	_PlayerData._send_notification("(XENON): Sent message")
	#_Network._send_P2P_Packet({"type": "message", "message": _options["Message"], "sender": 1, "local": false, "position": _Player.global_transform.origin, "zone": "Global", "zone_owner": 1}, "all", 2)
func _banself() -> void:
	_Network._send_P2P_Packet({"type": "ban", "new_host": "0"}, str(_Network.STEAM_ID), 2)

func _punchself() -> void:
	_Network._send_P2P_Packet({"type": "player_punch", "from_pos": Vector3(0,0,0), "player": _Network.STEAM_ID, "punch_type": 1}, str(_Network.STEAM_ID), 2)

func _punchall() -> void:
	_Network._send_P2P_Packet({"type": "player_punch", "from_pos": Vector3(0,0,0), "player": _Network.STEAM_ID, "punch_type": 1}, "all", 2)

func _CRASH() -> void:
	xenon_panels_data[90151].name = "yes" #  this will cause a crash
