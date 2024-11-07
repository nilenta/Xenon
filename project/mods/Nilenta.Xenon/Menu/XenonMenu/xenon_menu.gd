extends Node

const MOD_PANEL = preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/xenon_panel.tscn")
const TOOLTIP_NODE = preload("res://Scenes/Singletons/Tooltips/tooltip_node.tscn")

onready var main_menu := get_parent()
onready var _Player = get_tree().current_scene.get_node_or_null("Viewport/main/entities/player")
onready var _PlayerData = get_node("/root/PlayerData")
onready var _PopupMessage = get_node("/root/PopupMessage")
onready var _data = preload("res://mods/Nilenta.Xenon/Components/Data.gd").new()
onready var _posData = preload("res://mods/Nilenta.Xenon/Components/PosSaving.gd").new()

onready var _Globals = get_node("/root/Globals")
onready var _Network = get_node("/root/Network")


var current_node: Node = null
var current_category = ""

onready var xenon_categories := $"Panel/Panel2/categories"
onready var xenon_interface := $"Panel/Panel2/ScrollContainer/VBoxContainer"

var coolPeople = [
	76561198207248827, # n
	76561198994893015, # s
	76561198886577922 # m
]

var xenon_categories_data = [
	{"name": "Player", "script": preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/Categories/Player.gd")},
	{"name": "Items", "script": preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/Categories/Items.gd")},
	{"name": "Cosmetics", "script": preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/Categories/Cosmetics.gd")},
	{"name": "Fun", "script": preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/Categories/Fun.gd")},
	{"name": "Positions", "script": preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/Categories/Positions.gd")},
	{"name": "Configs", "script": preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/Categories/Configs.gd")},
	
]

var xenon_categories_data_MAINMENU = [
	{"name": "Configs", "script": preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/Categories/Configs.gd")},
	#{"name": "Lobby Creation", "script": preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/Categories/Lobbies.gd")},
	
]


func _ready() -> void:
	_data._load_config()
	print("[XENON_GD]: Initializing category buttons.")
	var currentCategoriesData = xenon_categories_data
	if current_node.name == "main_menu":
		currentCategoriesData = xenon_categories_data_MAINMENU
		if coolPeople.has(_Network.STEAM_ID):
			currentCategoriesData.append({"name": "Test", "script": preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/Categories/Testing.gd")})
	else:
		if coolPeople.has(_Network.STEAM_ID) or _Network.GAME_MASTER:
			currentCategoriesData.append({"name": "Spawn", "script": preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/Categories/Spawn.gd")})
		if coolPeople.has(_Network.STEAM_ID):
			currentCategoriesData.append({"name": "Test", "script": preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/Categories/Testing.gd")})
		
	for category_info in currentCategoriesData:
		var button = Button.new()
		button.text = category_info.name
		button.rect_min_size = Vector2(120, 16)
		button.connect("pressed", self, "_on_category_button_pressed", [category_info])
		xenon_categories.add_child(button)
		button.modulate = Color(0.7, 0.7, 0.7)

	_on_category_button_pressed(currentCategoriesData[0])

func _on_category_button_pressed(category_info: Dictionary) -> void:
	current_category = category_info.name
	print("[XENON_GD]: Selected category: " + current_category)

	for button in xenon_categories.get_children():
		if button.text == current_category:
			button.modulate = Color(1.0, 1.0, 1.0)
		else:
			button.modulate = Color(0.7, 0.7, 0.7)


	for child in xenon_interface.get_children():
		xenon_interface.remove_child(child)
		child.queue_free()

	if category_info.script:
		var category_script = category_info.script.new()
		category_script.setup(_Player, _PlayerData, _Globals, xenon_interface, _data, get_tree(), _Network, _posData, _PopupMessage)

func _on_close_pressed() -> void:
	print("[XENON_GD]: Closing XENON menu.")
	main_menu.get_node("xenon_menu").visible = false

