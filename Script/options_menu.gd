extends Control

@onready var indicator = $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer/Indicator
@onready var btn_mute: Button = $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Mute
@onready var btn_sfx: Button = $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/SFX
@onready var btn_music: Button = $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Music
@onready var btn_fullscreen: Button = $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Fullscreen
@onready var btn_back: Button = $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/Back

var animated_menu: AnimatedMenu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_refresh_labels()
	var buttons: Array[Button] = [btn_mute, btn_sfx, btn_music, btn_fullscreen, btn_back]
	animated_menu = AnimatedMenu.new()
	animated_menu.indicator = indicator
	animated_menu.buttons = buttons
	animated_menu.option_selected.connect(_on_menu_option_selected)
	add_child(animated_menu)

func _refresh_labels() -> void:
	btn_mute.text = "Mute: ON" if SettingsManager.muted else "Mute: OFF"
	btn_sfx.text = "SFX: %d%%" % SettingsManager.sfx_volume
	btn_music.text = "Music: %d%%" % SettingsManager.music_volume
	btn_fullscreen.text = "Fullscreen: ON" if SettingsManager.fullscreen else "Fullscreen: OFF"

func _on_menu_option_selected(index: int) -> void:
	match index:
		0:
			SettingsManager.muted = not SettingsManager.muted
			SettingsManager.apply_settings()
			SettingsManager.save_settings()
			_refresh_labels()
		1:
			SettingsManager.sfx_volume -= 10
			if SettingsManager.sfx_volume < 0:
				SettingsManager.sfx_volume = 100
			SettingsManager.apply_settings()
			SettingsManager.save_settings()
			_refresh_labels()
		2:
			SettingsManager.music_volume -= 10
			if SettingsManager.music_volume < 0:
				SettingsManager.music_volume = 100
			SettingsManager.apply_settings()
			SettingsManager.save_settings()
			_refresh_labels()
		3:
			SettingsManager.fullscreen = not SettingsManager.fullscreen
			SettingsManager.apply_settings()
			SettingsManager.save_settings()
			_refresh_labels()
		4:
			MenuManager.close_options_menu()
