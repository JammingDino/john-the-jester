extends Control

var is_busy: bool = false
var selected_button: int = 0
var indicator_y: float = 0.0
var indicator_velocity: float = 0.0
const SPRING_STRENGTH: float = 400.0
const DAMPING: float = 0.85
const REF_FPS: float = 60.0
const BUTTON_HEIGHT: float = 30.0
const BUTTON_SPACING: float = 10.0

@onready var menu_ui_root: VBoxContainer = $VBoxContainer
@onready var indicator: ColorRect = $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer/Indicator
@onready var buttons: Array[Button] = [
	$VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Play,
	$VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Options,
	$VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Quit
]

var current_level = 0
@onready var levels: Array[String] = [
	"res://Scenes/tomato_catcher.tscn",
	"res://Scenes/flappy_bird.tscn"
]

var menu_cam_overides: Dictionary = {
	"rotation" : Vector3(-40, 0, 0),
	"spinning" : true,
	"distance" : Vector3(0, 3.712, 4.0)
}

var target_cam_rotation: Vector3 = menu_cam_overides["rotation"]
var target_cam_distance: Vector3 = menu_cam_overides["distance"]
var target_cam_spinning: bool = menu_cam_overides["spinning"]


@onready var animation_player: AnimationPlayer = $SubViewportContainer/SubViewport/Pivot/AnimationPlayer
@onready var camera_3d: Camera3D = $SubViewportContainer/SubViewport/Pivot/Camera3D

var hover_stylebox: StyleBox

func _ready() -> void:
	hover_stylebox = buttons[0].get_theme_stylebox("hover").duplicate()
	indicator.position.y = _button_y_position(selected_button)
	_update_button_states()

func _show_ui() -> void:
	menu_ui_root.show()

func _hide_ui() -> void:
	menu_ui_root.hide()


func _on_resume_menu() -> void:
	is_busy = false
	_apply_cam_overides(menu_cam_overides)
	_show_ui()

func _apply_cam_overides(current_cam) -> void:
	target_cam_rotation = current_cam["rotation"]
	target_cam_distance = current_cam["distance"]
	target_cam_spinning = current_cam["spinning"]

func _on_play_pressed() -> void:
	is_busy = true
	_hide_ui()
	
	var game_scene = load(levels[current_level]).instantiate()
	current_level = (current_level+1) % len(levels)
	get_tree().root.add_child(game_scene)
	game_scene.tree_exited.connect(_on_resume_menu)
	
	var current_cam = game_scene.cam_overides
	_apply_cam_overides(current_cam)
	

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

	camera_3d.position = camera_3d.position.lerp(target_cam_distance, delta * 10.0)
	camera_3d.rotation_degrees = camera_3d.rotation_degrees.lerp(target_cam_rotation, delta * 10.0)
	
	if target_cam_spinning:
		animation_player.play("loop")
	else:
		animation_player.stop()

	if is_busy:
		return
	
	var target_y = _button_y_position(selected_button)
	
	var displacement = target_y - indicator_y
	var acceleration = displacement * SPRING_STRENGTH
	indicator_velocity += acceleration * delta
	indicator_velocity *= pow(DAMPING, delta * REF_FPS)
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
