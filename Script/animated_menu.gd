extends Node
class_name AnimatedMenu

signal option_selected(index: int)

var indicator: Control
var buttons: Array[Button]
var button_height: float = 30.0
var button_spacing: float = 10.0
var initial_top_margin: float = 6.0

var selected_button: int = 0
var indicator_y: float = 0.0
var indicator_velocity: float = 0.0
const SPRING_STRENGTH: float = 400.0
const DAMPING: float = 0.85
const REF_FPS: float = 60.0

var hover_stylebox: StyleBox
var is_active: bool = true

func _ready() -> void:
	if buttons.is_empty():
		return
		
	hover_stylebox = buttons[0].get_theme_stylebox("hover").duplicate()
	indicator_y = _button_y_position(selected_button)
	if indicator:
		indicator.position.y = indicator_y
	_update_button_states()
	
	# Connect UI interactions programmatically to avoid `.tscn` signal clutter
	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.mouse_entered.connect(_on_button_mouse_entered.bind(i))
		btn.pressed.connect(_on_button_pressed.bind(i))

func _process(delta: float) -> void:
	if not is_active or buttons.is_empty():
		return
		
	var target_y = _button_y_position(selected_button)
	
	var displacement = target_y - indicator_y
	var acceleration = displacement * SPRING_STRENGTH
	indicator_velocity += acceleration * delta
	indicator_velocity *= pow(DAMPING, delta * REF_FPS)
	indicator_y += indicator_velocity * delta
	
	if indicator:
		indicator.position.y = indicator_y
	
	if Input.is_action_just_pressed("ui_up"):
		selected_button = max(0, selected_button - 1)
		_reset_spring()
		_update_button_states()
	elif Input.is_action_just_pressed("ui_down"):
		selected_button = min(buttons.size() - 1, selected_button + 1)
		_reset_spring()
		_update_button_states()
	
	if Input.is_action_just_pressed("ui_accept"):
		_on_button_pressed(selected_button)

func _button_y_position(button_index: int) -> float:
	return initial_top_margin + button_index * (button_height + button_spacing)

func _reset_spring() -> void:
	indicator_velocity = 0.0

func _update_button_states() -> void:
	for i in buttons.size():
		if i == selected_button:
			buttons[i].add_theme_stylebox_override("normal", hover_stylebox)
		else:
			buttons[i].remove_theme_stylebox_override("normal")

func _on_button_mouse_entered(index: int) -> void:
	if not is_active: return
	selected_button = index
	_reset_spring()
	_update_button_states()

func _on_button_pressed(index: int) -> void:
	if not is_active: return
	option_selected.emit(index)
