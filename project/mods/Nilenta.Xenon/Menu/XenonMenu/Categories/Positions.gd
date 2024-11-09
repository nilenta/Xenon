extends "res://mods/Nilenta.Xenon/Components/Classes/MenuCategory.gd"

var _Player: Node
var _PlayerData: Node
var _Globals: Node
var _Network: Node
var xenon_panels_data: Array = []
var _pos_data

var pos_name_text_box: LineEdit
var pos_list_panel: VBoxContainer

func setup(Player: Node, PlayerData: Node, Globals: Node, Interface: VBoxContainer, Data, _tree, Network, _posData, PopupMsg, bd) -> void:
	_Player = Player
	_PlayerData = PlayerData
	_Globals = Globals
	_Network = Network
	xenon_interface = Interface
	_pos_data = _posData
	
	register_option("PosName", "")
	
	_pos_data._load_position_data()
	
	_create_position_panel()
	_load_panels()

func _create_position_panel() -> void:
	pos_name_text_box = LineEdit.new()
	pos_name_text_box.placeholder_text = "Enter position name"
	xenon_interface.add_child(pos_name_text_box)
	
	var buttonSavePos = Button.new()
	buttonSavePos.text = "Save Position"
	buttonSavePos.connect("pressed", self, "_save_pos")
	xenon_interface.add_child(buttonSavePos)
	
	pos_list_panel = VBoxContainer.new()
	pos_list_panel.name = "Position List"
	xenon_interface.add_child(pos_list_panel)

func _load_panels() -> void:
	for child in pos_list_panel.get_children():
		pos_list_panel.remove_child(child)
		child.queue_free()
	
	for name in _pos_data.position_data.keys():
		_add_position_button(name)

func _add_position_button(name: String) -> void:
	_cust_add_panel({
			"name": name,
			"elements": [
				{"type": "button", "text": "Delete", "handler": "_delete_pos", "params": [name]},
				{"type": "button", "text": "Teleport", "handler": "_on_position_selected", "params": [name]},
			]
		})
	#var pos_button = Button.new()
	#pos_button.text = name
	#pos_button.connect("pressed", self, "_on_position_selected", [name])
	#pos_list_panel.add_child(pos_button)

func _cust_add_panel(panel_info: Dictionary) -> void:
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

	pos_list_panel.add_child(xenon_button_panel)

func _save_pos() -> void:
	var player_pos = _Player.global_transform.origin
	var pos_name = pos_name_text_box.text.strip_edges()
	var current_zone = _PlayerData.player_saved_zone
	
	if pos_name != "":
		if current_zone == "":
			current_zone = "main_zone" # fallback
		_pos_data.save_position(pos_name, player_pos, current_zone)
		_load_panels()
	else:
		print("[XENON_GD]: Position name cannot be empty.")

func _delete_pos(name: String) -> void:
	var saved_data = _pos_data.load_position(name)
	if saved_data != null:
		_pos_data.delete_position(name)
		_load_panels()
	else:
		print("[XENON_GD]: Position not found.")

func _on_position_selected(name: String) -> void:
	var saved_data = _pos_data.load_position(name)
	if saved_data != null:
		var saved_pos = saved_data["position"]
		var saved_zone = saved_data["zone"]
		print("[XENON_GD]: Selected position: ", saved_pos, " in zone ", saved_zone)
		
		_Player.global_transform.origin = saved_pos
		_Player.world._enter_zone(saved_zone, -1)
		_PlayerData.player_saved_zone = saved_zone
		_PlayerData.player_saved_zone_owner = -1
		
		_PlayerData._send_notification("(XENON): Teleported to " + name)
	else:
		print("[XENON_GD]: Position not found.")
