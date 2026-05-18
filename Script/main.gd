extends Control

var is_busy: bool = false
var animated_menu: AnimatedMenu

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

func _ready() -> void:
	animated_menu = AnimatedMenu.new()
	animated_menu.indicator = indicator
	animated_menu.buttons = buttons
	animated_menu.option_selected.connect(_on_menu_option_selected)
	add_child(animated_menu)
	
	MenuManager.options_opened.connect(_on_options_opened)
	MenuManager.options_closed.connect(_on_options_closed)

func _on_options_opened() -> void:
	if not is_busy and MenuManager.current_game_scene == null:
		_hide_ui()

func _on_options_closed() -> void:
	if not is_busy and MenuManager.current_game_scene == null:
		_show_ui()

func _show_ui() -> void:
	menu_ui_root.show()
	animated_menu.is_active = true

func _hide_ui() -> void:
	menu_ui_root.hide()
	animated_menu.is_active = false


func _on_resume_menu() -> void:
	is_busy = false
	MenuManager.is_game_active = false
	MenuManager.current_game_scene = null
	_apply_cam_overides(menu_cam_overides)
	_show_ui()

func _apply_cam_overides(current_cam) -> void:
	target_cam_rotation = current_cam["rotation"]
	target_cam_distance = current_cam["distance"]
	target_cam_spinning = current_cam["spinning"]

func _on_play_pressed() -> void:
	is_busy = true
	_hide_ui()
	MenuManager.is_game_active = true
	
	var game_scene = load(levels[current_level]).instantiate()
	current_level = (current_level+1) % len(levels)
	get_tree().root.add_child(game_scene)
	game_scene.tree_exited.connect(_on_resume_menu)
	MenuManager.current_game_scene = game_scene
	
	var current_cam = game_scene.cam_overides
	_apply_cam_overides(current_cam)
	

func _on_options_pressed() -> void:
	MenuManager.open_options_menu()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_menu_option_selected(index: int) -> void:
	if is_busy:
		return
	match index:
		0: _on_play_pressed()
		1: _on_options_pressed()
		2: _on_quit_pressed()

func _process(delta: float) -> void:

	camera_3d.position = camera_3d.position.lerp(target_cam_distance, delta * 10.0)
	camera_3d.rotation_degrees = camera_3d.rotation_degrees.lerp(target_cam_rotation, delta * 10.0)
	
	if target_cam_spinning:
		animation_player.play("loop")
	else:
		animation_player.stop()
