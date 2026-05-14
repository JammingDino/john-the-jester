extends Control

var selected_button: int = 0
var indicator_y: float = 0.0
var indicator_velocity: float = 0.0
const SPRING_STRENGTH: float = 300.0
const DAMPING: float = 0.8
const BUTTON_HEIGHT: float = 30.0
const BUTTON_SPACING: float = 10.0

@onready var indicator: ColorRect = $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer/Indicator
@onready var buttons: Array[Button] = [
	$VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Play,
	$VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Options,
	$VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Quit
]

var hover_stylebox: StyleBox

func _ready() -> void:
	hover_stylebox = buttons[0].get_theme_stylebox("hover").duplicate()
	indicator.position.y = _button_y_position(selected_button)
	_update_button_states()

func _on_play_pressed() -> void:
	pass

func _on_options_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_mouse_entered() -> void:
	selected_button = 0
	_reset_spring()
	_update_button_states()

func _on_options_mouse_entered() -> void:
	selected_button = 1
	_reset_spring()
	_update_button_states()

func _on_quit_mouse_entered() -> void:
	selected_button = 2
	_reset_spring()
	_update_button_states()

func _process(delta: float) -> void:
	var target_y = _button_y_position(selected_button)
	
	var displacement = target_y - indicator_y
	var acceleration = displacement * SPRING_STRENGTH
	indicator_velocity += acceleration * delta
	indicator_velocity *= DAMPING
	indicator_y += indicator_velocity * delta
	
	indicator.position.y = indicator_y
	
	if Input.is_action_just_pressed("ui_up"):
		selected_button = max(0, selected_button - 1)
		_reset_spring()
		_update_button_states()
	elif Input.is_action_just_pressed("ui_down"):
		selected_button = min(2, selected_button + 1)
		_reset_spring()
		_update_button_states()
	
	if Input.is_action_just_pressed("ui_accept"):
		match selected_button:
			0: _on_play_pressed()
			1: _on_options_pressed()
			2: _on_quit_pressed()

func _button_y_position(button_index: int) -> float:
	var button_top_margin = 6.0
	var offset = button_top_margin + button_index * (BUTTON_HEIGHT + BUTTON_SPACING)
	return offset

func _reset_spring() -> void:
	indicator_velocity = 0.0

func _update_button_states() -> void:
	for i in buttons.size():
		if i == selected_button:
			buttons[i].add_theme_stylebox_override("normal", hover_stylebox)
		else:
			buttons[i].remove_theme_stylebox_override("normal")
