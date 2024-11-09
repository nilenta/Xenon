extends "res://mods/Nilenta.Xenon/Components/Classes/MenuCategory.gd"

var _Player: Node
var _PlayerData: Node
var _Globals: Node
var _Network: Node
var xenon_panels_data: Array = []
var parentTree
var _PopupMessage: Node
var _baitData

var BAIT_DATA_DEFAULTS = {
	"": {"catch": 0.0, "max_tier": 0, "quality": []}, 
	"worms": {"catch": 0.06, "max_tier": 1, "quality": [1.0]}, 
	"cricket": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.05]}, 
	"leech": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.15, 0.05]}, 
	"minnow": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.5, 0.25, 0.05]}, 
	"squid": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.8, 0.45, 0.15, 0.05]}, 
	"nautilus": {"catch": 0.06, "max_tier": 2, "quality": [1.0, 0.98, 0.75, 0.55, 0.25, 0.05]}, 
}

func capitalize_first_letter(text: String) -> String:
	if text.length() == 0:
		return text
	return text[0].to_upper() + text.substr(1).to_lower()

func setup(Player: Node, PlayerData: Node, Globals: Node, Interface: VBoxContainer, Data, _tree, Network, _posData, pop, bd) -> void:
	_Player = Player
	_PlayerData = PlayerData
	_Globals = Globals
	_Network = Network
	xenon_interface = Interface
	parentTree = _tree
	_PopupMessage = pop
	_baitData = bd
	_baitData._load_bait_data()
	
	connect("option_updated", self, "_on_option_updated")
	
	var defaultDesc = """[color=red]All numbers can be a value between 0 and 1.[/color]
	
First value is how common it is to reel something in
Second value is [color=#d5aa73]Normal[/color] fish chance
Third value is [color=#d5aa73]Shining[/color] fish chance
Fourth value is [color=#a49d9c]Glistening[/color] fish chance
Fifth value is [color=#008583]Opulent[/color] fish chance
Sixth value is [color=#e69d00]Radiant[/color] fish chance
Seventh value is [color=#cd0462]Alpha[/color] fish chance"""

	for bait_name in _baitData.bait_data.keys():
		var bait_info = _baitData.bait_data[bait_name]
		var bait_mod_name = bait_name if bait_name.length() > 0 else "NoBait"
		var display_name = capitalize_first_letter(bait_name) if bait_name.length() > 0 else "No Bait" # lol
		var quality_values = bait_info.get("quality", [])
		var chance_names = ["NormalChance", "ShiningChance", "GlisteningChance", "OpulentChance", "RadiantChance", "AlphaChance"]
		register_option(bait_mod_name + "CatchChance", bait_info["catch"])
		
		for i in range(chance_names.size()):
			var chance_value = 0.0
			if i < quality_values.size():
				chance_value = quality_values[i]
			register_option(bait_mod_name + chance_names[i], chance_value)
			
		var panelData = {
			"name": display_name,
			"description": defaultDesc,
			"elements": [
				{"type": "float", "name": bait_mod_name + "CatchChance", "initial_value": _options[bait_mod_name + "CatchChance"], "key": bait_mod_name + "CatchChance"},
				{"type": "float", "name": bait_mod_name + "NormalChance", "initial_value": _options[bait_mod_name + "NormalChance"], "key": bait_mod_name + "NormalChance"},
				{"type": "float", "name": bait_mod_name + "ShiningChance", "initial_value": _options[bait_mod_name + "ShiningChance"], "key": bait_mod_name + "ShiningChance"},
				{"type": "float", "name": bait_mod_name + "GlisteningChance", "initial_value": _options[bait_mod_name + "GlisteningChance"], "key": bait_mod_name + "GlisteningChance"},
				{"type": "float", "name": bait_mod_name + "OpulentChance", "initial_value": _options[bait_mod_name + "OpulentChance"], "key": bait_mod_name + "OpulentChance"},
				{"type": "float", "name": bait_mod_name + "RadiantChance", "initial_value": _options[bait_mod_name + "RadiantChance"], "key": bait_mod_name + "RadiantChance"},
				{"type": "float", "name": bait_mod_name + "AlphaChance", "initial_value": _options[bait_mod_name + "AlphaChance"], "key": bait_mod_name + "AlphaChance"},
				{"type": "button", "text": "Reset", "handler": "_reset_bait_data", "params": [bait_mod_name]}
			]
		}
		
		xenon_panels_data.append(panelData)
	
	print(_options)
	_load_panels()

func _load_panels() -> void:
	for child in xenon_interface.get_children():
		xenon_interface.remove_child(child)
		child.queue_free()
	
	for panel_info in xenon_panels_data:
		_add_panel_to_interface(panel_info)

func _reset_bait_data(bn: String) -> void:
	var bait_mod_name = bn
	if bn == "NoBait": bait_mod_name = ""
	var default_data = BAIT_DATA_DEFAULTS.get(bait_mod_name, null)
	if default_data == null:
		print("[XENON_GD]: No default data found for bait '" + bait_mod_name + "'")
		return
	
	if _baitData.bait_data.has(bait_mod_name):
		var bait_info = _baitData.bait_data[bait_mod_name]
		bait_info["catch"] = default_data["catch"]
		bait_info["quality"] = default_data["quality"].duplicate()

		_baitData.save_bait(bait_mod_name, bait_info["catch"], bait_info["quality"])
		_Player.BAIT_DATA = _baitData.get_bait_data()

		_options[bait_mod_name + "CatchChance"] = bait_info["catch"]
		for i in range(default_data["quality"].size()):
			var chance_names = ["NormalChance", "ShiningChance", "GlisteningChance", "OpulentChance", "RadiantChance", "AlphaChance"]
			if i < chance_names.size():
				_options[bait_mod_name + chance_names[i]] = default_data["quality"][i]
		
		print("[XENON_GD]: Bait data reset to defaults for '" + bait_mod_name + "'")
		_load_panels()


func _on_option_updated(key: String, value) -> void:
	if value > 1:
		value = 1.0
	
	var chance_types = {
		"NormalChance": 0,
		"ShiningChance": 1,
		"GlisteningChance": 2,
		"OpulentChance": 3,
		"RadiantChance": 4,
		"AlphaChance": 5
	}

	var property_name = ""
	var bait_mod_name = key
	
	for chance_type in chance_types.keys():
		if key.ends_with("CatchChance"):
			property_name = "CatchChance"
			bait_mod_name = key.substr(0, key.length() - "CatchChance".length())
			break
		if key.ends_with(chance_type):
			property_name = chance_type
			bait_mod_name = key.substr(0, key.length() - chance_type.length())
			break
	
	
	if bait_mod_name == "NoBait":
		bait_mod_name = ""

	_options[key] = value

	if _baitData.bait_data.has(bait_mod_name):
		var bait_info = _baitData.bait_data[bait_mod_name]
		
		if property_name == "CatchChance":
			bait_info["catch"] = value
		elif property_name in chance_types:
			var quality_index = chance_types[property_name]
			
			while bait_info["quality"].size() <= quality_index:
				bait_info["quality"].append(0.0)
				
			bait_info["quality"][quality_index] = value

		_baitData.save_bait(bait_mod_name, bait_info["catch"], bait_info["quality"])
		print("[XENON_GD]: Bait updated for '" + bait_mod_name + "' with catch: " + str(bait_info["catch"]) + " and quality: " + str(bait_info["quality"]))
		_Player.BAIT_DATA = _baitData.get_bait_data()
