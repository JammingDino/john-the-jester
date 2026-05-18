extends Control

@onready var container = $VBoxContainer
@onready var indicator = $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer/Indicator
@onready var buttons: Array[Button] = [
	$VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Resume,
	$VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Options,
	$VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/MainMenu,
	$VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Quit
]

var animated_menu: AnimatedMenu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	animated_menu = AnimatedMenu.new()
	animated_menu.indicator = indicator
	animated_menu.buttons = buttons
	animated_menu.option_selected.connect(_on_menu_option_selected)
	add_child(animated_menu)

func _on_menu_option_selected(index: int) -> void:
	match index:
		0: MenuManager.toggle_pause_menu()
		1: MenuManager.open_options_menu()
		2: MenuManager.quit_to_main_menu()
		3: get_tree().quit()
