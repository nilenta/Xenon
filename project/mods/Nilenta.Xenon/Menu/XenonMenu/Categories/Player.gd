extends Node

var _Player: Node
var _PlayerData: Node
var _Globals: Node
var xenon_interface: VBoxContainer
var _Network: Node

var _options = {
	"ScaleChange": 0.5,
	"Money": 10000,
	"XP": 100
}

var xenon_panels_data: Array = [
	{
		"name": "Player Size",
		"description": "You wanna grow? You wanna shrink? Yea go on. Press that button.\nGrow Y and Shrink Y both mess with your Y values.",
		"elements": [
			{"type": "input", "name": "Scale Change", "initial_value": str(_options["ScaleChange"]), "key": "ScaleChange"},
			{"type": "button", "text": "Grow", "handler": "_on_grow_button_pressed", "params": []},
			{"type": "button", "text": "Shrink", "handler": "_on_shrink_button_pressed", "params": []},
			
			{"type": "button", "text": "Reset", "handler": "_on_size_reset_button_pressed"}
			
		]
	},
	{
		"name": "Give Money",
		"description": "Hawk Tuna Reel on that Thang",
		"elements": [
			{"type": "input", "name": "Amount", "initial_value": str(_options["Money"]), "key": "Money"},
			{"type": "button", "text": "Add", "handler": "_give_money", "params": []},
			{"type": "button", "text": "Deduct", "handler": "_deduct_money", "params": []}
		]
	},
	{
		"name": "Give XP",
		"description": "Biog Fat Weuiner",
		"elements": [
			{"type": "input", "name": "Amount", "initial_value": str(_options["XP"]), "key": "XP"},
			{"type": "button", "text": "Add", "handler": "_give_xp", "params": []},
			{"type": "button", "text": "Deduct", "handler": "_deduct_xp", "params": []}
		]
	}
]

func setup(Player: Node, PlayerData: Node, Globals: Node, Interface: VBoxContainer, Data, _tree, Network, _posData, PopupMsg, bd) -> void:
	_Player = Player
	_PlayerData = PlayerData
	_Globals = Globals
	_Network = Network
	xenon_interface = Interface
	_load_panels()

func _load_panels() -> void:
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

	xenon_interface.add_child(xenon_button_panel)
	var tooltip = preload("res://Scenes/Singletons/Tooltips/tooltip_node.tscn").instance()
	tooltip.header = "[color=#6a4420]" + panel_info.name
	tooltip.body = panel_info.description
	xenon_button_panel.get_node("HBoxContainer/Info/Name").add_child(tooltip)

func _on_text_changed(current_text: String, key: String) -> void:
	print("[XENON_GD]: Text changed in input field for key '" + key + "': " + current_text)
	if key in _options:
		_options[key] = float(current_text)

func _on_grow_button_pressed() -> void:
	print("[XENON_GD]: Grow button pressed. Changing scale by: " + str(_options["ScaleChange"]))
	_PlayerData._send_notification("(XENON): Added " + str(_options["ScaleChange"]) + " to your scale.")
	_Player.player_scale += _options["ScaleChange"]

func _on_shrink_button_pressed() -> void:
	print("[XENON_GD]: Shrink button pressed. Changing scale by: " + str(_options["ScaleChange"]))
	_PlayerData._send_notification("(XENON): Removed " + str(_options["ScaleChange"]) + " from your scale.")
	_Player.player_scale -= _options["ScaleChange"]


func _on_size_reset_button_pressed() -> void:
	print("[XENON_GD]: Reset size button pressed. Resetting player scale to 1.")
	_PlayerData._send_notification("(XENON): Reset your scale.")
	_Player.player_scale = 1
	_Player.player_scale_y = 1

func _give_money() -> void:
	print("[XENON_GD]: Giving player $", str(_options["Money"]))
	_PlayerData._send_notification("(XENON): Gave $" + str(_options["Money"]))
	_PlayerData._set_cash(_PlayerData.money + _options["Money"])

func _deduct_money() -> void:
	print("[XENON_GD]: Deducting player $", str(_options["Money"]))
	_PlayerData._send_notification("(XENON): Deducted $" + str(_options["Money"]))
	_PlayerData._set_cash(_PlayerData.money - _options["Money"])

func _give_xp() -> void:
	print("[XENON_GD]: Giving player ", str(_options["XP"]), " xp")
	_PlayerData._send_notification("(XENON): Gave " + str(_options["XP"]) + " XP")
	_PlayerData._add_xp(_options["XP"])

func _deduct_xp() -> void:
	print("[XENON_GD]: Deducting player ", str(_options["XP"]), " xp")
	_PlayerData._send_notification("(XENON): Deducted " + str(_options["XP"]) + " XP")
	_PlayerData._add_xp(-_options["XP"])
