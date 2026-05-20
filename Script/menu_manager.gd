extends Node

var pause_menu_scene = preload("res://Scenes/pause_menu.tscn")
var options_menu_scene = preload("res://Scenes/options_menu.tscn")

var pause_menu_instance: Control = null
var options_menu_instance: Control = null
var is_game_active: bool = false 
var current_game_scene: Node = null

var hover_player: AudioStreamPlayer
var press_player: AudioStreamPlayer
var music_player: AudioStreamPlayer

var ui_music: AudioStream
var game_music_1: AudioStream
var game_music_2: AudioStream

var music_acceleration: float = 0.003

signal options_opened
signal options_closed

func _ready() -> void:
	# Ensure the manager continues running when the tree is paused!
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	hover_player = AudioStreamPlayer.new()
	hover_player.stream = load("res://Assets/Sounds/UI_Hover.ogg")
	hover_player.bus = "SFX"
	add_child(hover_player)
	
	press_player = AudioStreamPlayer.new()
	press_player.stream = load("res://Assets/Sounds/UI_Press.ogg")
	press_player.bus = "SFX"
	add_child(press_player)
	
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	ui_music = load("res://Assets/Music/UI_Track.ogg")
	game_music_1 = load("res://Assets/Music/Game_Track_1.ogg")
	game_music_2 = load("res://Assets/Music/Game_Track_2.ogg")

func _process(delta: float) -> void:
	# Gradually speed up the music if we are actively playing the game, capping at 2x speed
	if is_game_active and not get_tree().paused:
		music_player.pitch_scale = min(music_player.pitch_scale + music_acceleration * delta, 2.0)

func play_main_menu_music() -> void:
	if music_player.stream != ui_music or not music_player.playing:
		music_player.stream = ui_music
		music_player.pitch_scale = 1.0
		music_player.play()

func play_game_music() -> void:
	music_player.pitch_scale = 1.0
	if randf() > 0.5:
		music_player.stream = game_music_1
	else:
		music_player.stream = game_music_2
	music_player.play()

func play_hover_sound() -> void:
	if hover_player: hover_player.play()

func play_press_sound() -> void:
	if press_player: press_player.play()

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
