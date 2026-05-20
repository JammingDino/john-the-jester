extends Node3D

var cam_overides: Dictionary = {
	"rotation" : Vector3(-25, 90, 0),
	"spinning" : false,
	"distance" : Vector3(4, 4, 0)
}

@onready var counter: Label = $Control/MarginContainer/VBoxContainer/Counter
@onready var restart_prompt: Label = $Control/MarginContainer/VBoxContainer/MarginContainer/RestartPrompt
@onready var animation_player: AnimationPlayer = $"Player/Facing/the fool/AnimationPlayer"
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var pong_ball = $PongBall

const SAVE_FILE = "user://pong_highscore.save"

var score: int = 0
var high_score: int = 0
var game_over: bool = false

func _ready() -> void:
	load_high_score()
	update_score_display()
	pong_ball.paddle_hit.connect(_on_paddle_hit)

func _process(_delta: float) -> void:
	if game_over:
		if Input.is_action_just_pressed("ui_accept"):
			queue_free()
		return

	if pong_ball.position.y < 0.2:
		_trigger_game_over()

func _trigger_game_over() -> void:
	game_over = true
	save_high_score()
	update_score_display()

	if counter:
		counter.modulate = Color(1.0, 0.2, 0.2)
		var tween = create_tween()
		tween.tween_property(counter, "scale", Vector2(2.0, 2.0), 0.5).set_trans(Tween.TRANS_SPRING)

	if restart_prompt:
		restart_prompt.visible = true

	if animation_player:
		animation_player.play("dead")

	audio_stream_player.play()

func _on_paddle_hit() -> void:
	score += 1
	update_score_display()

	if counter:
		counter.pivot_offset = counter.size / 2.0
		var tween = create_tween()
		counter.scale = Vector2(1.5, 1.5)
		counter.modulate = Color(1.0, 0.9, 0.3)
		tween.tween_property(counter, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(counter, "modulate", Color.WHITE, 0.3)

func update_score_display() -> void:
	if counter:
		counter.text = str(score) + " / " + str(high_score)

func load_high_score() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			high_score = file.get_32()
			file.close()

func save_high_score() -> void:
	if score > high_score:
		high_score = score
		var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
		if file:
			file.store_32(high_score)
			file.close()
