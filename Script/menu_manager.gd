extends Node

var pause_menu_scene = preload("res://Scenes/pause_menu.tscn")
var options_menu_scene = preload("res://Scenes/options_menu.tscn")

var pause_menu_instance: Control = null
var options_menu_instance: Control = null
var is_game_active: bool = false 
var current_game_scene: Node = null

signal options_opened
signal options_closed

func _ready() -> void:
	# Ensure the manager continues running when the tree is paused!
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	# Only allow pausing if we are actually playing a game (not on the main menu)
	if is_game_active and event.is_action_pressed("ui_cancel"):
		if options_menu_instance != null:
			close_options_menu()
		else:
			toggle_pause_menu()

func toggle_pause_menu() -> void:
	if pause_menu_instance == null:
		pause_menu_instance = pause_menu_scene.instantiate()
		get_tree().root.add_child(pause_menu_instance)
		get_tree().paused = true
	else:
		pause_menu_instance.queue_free()
		pause_menu_instance = null
		get_tree().paused = false

func open_options_menu() -> void:
	if options_menu_instance == null:
		options_menu_instance = options_menu_scene.instantiate()
		get_tree().root.add_child(options_menu_instance)
		if pause_menu_instance:
			pause_menu_instance.hide() # hide pause menu while options are visible
			if pause_menu_instance.has_method("get"):
				var am = pause_menu_instance.get("animated_menu")
				if am: am.is_active = false
		options_opened.emit()
		
func close_options_menu() -> void:
	if options_menu_instance != null:
		options_menu_instance.queue_free()
		options_menu_instance = null
		if pause_menu_instance:
			pause_menu_instance.show() # reveal pause menu again
			if pause_menu_instance.has_method("get"):
				var am = pause_menu_instance.get("animated_menu")
				if am: am.is_active = true
		options_closed.emit()

func quit_to_main_menu() -> void:
	if current_game_scene != null:
		# Duck-typing check to dynamically save score no matter the minigame
		var score_val = current_game_scene.get("score")
		var high_score_val = current_game_scene.get("high_score")
		
		if score_val != null and high_score_val != null:
			if score_val > high_score_val:
				current_game_scene.set("high_score", score_val)
				if current_game_scene.has_method("save_high_score"):
					current_game_scene.save_high_score()
					
		# Delete the game scene, effectively returning to main menu
		current_game_scene.queue_free()
		current_game_scene = null
		
	# Make sure to close the pause menu correctly
	if pause_menu_instance != null:
		toggle_pause_menu()
