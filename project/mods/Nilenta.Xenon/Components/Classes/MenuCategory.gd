extends Node

signal option_updated(key, value)
signal panel_added(panel_name)

var _options = {}
var hooks
var xenon_interface: VBoxContainer

func register_option(key: String, default_value) -> void:
	if not _options.has(key):
		_options[key] = default_value
		print("[PanelBase]: Registered option '" + key + "' with default value: " + str(default_value))

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
			if element.has("placeholder"):
				text_input.placeholder_text = element["placeholder"]
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
			if element.has("placeholder"):
				number_input.placeholder_text = element["placeholder"]
			number_input.connect("text_changed", self, "_on_number_changed", [element["key"], element["type"]])
			xenon_button_panel.get_node("HBoxContainer").add_child(number_input)
		elif element["type"] == "string":
			var string_input = LineEdit.new()
			string_input.text = element["initial_value"]
			string_input.name = element["name"]
			if element.has("placeholder"):
				string_input.placeholder_text = element["placeholder"]
			string_input.connect("text_changed", self, "_on_string_changed", [element["key"]])
			xenon_button_panel.get_node("HBoxContainer").add_child(string_input)

	xenon_interface.add_child(xenon_button_panel)

	emit_signal("panel_added", panel_info.name)

	var tooltip = preload("res://Scenes/Singletons/Tooltips/tooltip_node.tscn").instance()
	tooltip.header = "[color=#6a4420]" + panel_info.name
	tooltip.body = panel_info.description
	xenon_button_panel.get_node("HBoxContainer/Info/Name").add_child(tooltip)

func _on_option_selected(selected_index: int, key: String) -> void:
	print("[XENON_GD]: Option selected for key '" + key + "': " + str(selected_index))
	_options[key] = selected_index == 0
	if hooks: 
		hooks._set_option(key, selected_index == 0)
	
	emit_signal("option_updated", key, _options[key])

func _on_number_changed(current_text: String, key: String, value_type: String) -> void:
	print("[XENON_GD]: Number changed in input field for key '" + key + "': " + current_text)
	if key in _options:
		if value_type == "float":
			_options[key] = float(current_text)
			if hooks: 
				hooks._set_option(key, float(current_text))
		elif value_type == "integer":
			_options[key] = int(current_text)
			if hooks: 
				hooks._set_option(key, int(current_text))

	emit_signal("option_updated", key, _options[key])

func _on_string_changed(current_text: String, key: String) -> void:
	print("[XENON_GD]: String changed in input field for key '" + key + "': " + current_text)
	if key in _options:
		_options[key] = current_text
		if hooks: 
			hooks._set_option(key, current_text)

	emit_signal("option_updated", key, _options[key])

func _on_dropdown_selected(selected_index: int, key: String, options: Array) -> void:
	print("[XENON_GD]: Dropdown selected for key '" + key + "': " + options[selected_index])
	_options[key] = options[selected_index]
	if hooks: 
		hooks._set_option(key, options[selected_index])

	emit_signal("option_updated", key, _options[key])
