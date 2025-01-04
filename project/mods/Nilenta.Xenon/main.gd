extends Node

const XENON_MENU = preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/xenon_menu.tscn")
const FRIENDS_MENU = preload("res://mods/Nilenta.Xenon/Menu/Friends/friends_menu.tscn")

const XENON_BUTTON = preload("res://mods/Nilenta.Xenon/Menu/xenon_button.tscn")
const FRIENDS_BUTTON = preload("res://mods/Nilenta.Xenon/Menu/friends_button.tscn")

onready var _data = preload("res://mods/Nilenta.Xenon/Components/Data.gd").new()
onready var _Player = get_tree().current_scene.get_node_or_null("Viewport/main/entities/player")
onready var _PlayerData = get_node("/root/PlayerData")
onready var _Globals = get_node("/root/Globals")
onready var _Network = get_node("/root/Network")
var hooks

var alreadyAttempted = false

const MOD_PATHS = [
	"res://mods/Nilenta.Xenon/Mods/Test.gd"
]

func _ready():
	print("[XENON_GD]: Starting to load configuration")
	_data._load_config()
	
	for mod in MOD_PATHS:
		_add_mod(mod)

	hooks = preload("res://mods/Nilenta.Xenon/Menu/XenonMenu/Hooks.gd").new()
	add_child(hooks)
	
	hooks.setup()

	get_tree().connect("node_added", self, "_add_mod_menu")
	get_tree().root.connect("child_entered_tree", self, "_add_startup_hooks_which_sucks_ass")
	
	print("[XENON_GD]: Loaded")

func _add_mod(mod_path: String):
	var mod_instance = load(mod_path).new()
	add_child(mod_instance)


func _add_mod_menu(node: Node) -> void:
	if node.name == "esc_menu" or node.name == "main_menu":
		# handle saved lobby code
		var lobby_code = _data._load_saved_lobby_code()
		if lobby_code and not alreadyAttempted:
			# not nul woah!
			alreadyAttempted = true
			_Network._search_for_lobby(lobby_code) # hopefully this doesnt break it
		
		var xenon_menu: Node = XENON_MENU.instance()
		xenon_menu.visible = false
		xenon_menu.current_node = node
		
		node.add_child(xenon_menu)
		hooks.setup()
		var menu_list: Node = node.get_node("VBoxContainer")
		var button: Button = XENON_BUTTON.instance()
		var settings_button: Node = menu_list.get_node("settings")
		
		menu_list.add_child(button)
		menu_list.move_child(button, settings_button.get_index() + 1)
		
		menu_list.margin_top -= 24
		menu_list.margin_bottom += 24
