extends Control

@onready var container = $VBoxContainer
@onready var indicator = $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer/Indicator
@onready var buttons: Array[Button] = [
	$VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Audio,
	$VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Graphics,
	$VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Back
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
		0: pass
		1: pass
		2: 
			# Back out to main menu
			MenuManager.close_options_menu()
