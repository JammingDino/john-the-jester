extends Node3D

# Pipe configuration
@export var pipe_scene: PackedScene
@export var pipe_spawn_interval: float = 2.0
@export var initial_pipe_speed: float = 2.5
@export var max_pipe_speed: float = 8.0
@export var speed_increase_rate: float = 0.05
@export var initial_pipe_gap: float = 2.0
@export var min_pipe_gap: float = 1.0
@export var gap_decrease_rate: float = 0.02
@export var min_pipe_height: float = 1.0
@export var max_pipe_height: float = 4.0

# Game state
var cam_overides: Dictionary = {
	"rotation" : Vector3(-25, 90, 0),
	"spinning" : false,
	"distance" : Vector3(4, 4, 0)
}

@onready var player: Node3D = $Player
@onready var counter: Label = $Control/MarginContainer/VBoxContainer/Counter
@onready var restart_prompt: Label = $Control/MarginContainer/VBoxContainer/MarginContainer/RestartPrompt
@onready var animation_player: AnimationPlayer = $"Player/Facing/the fool/AnimationPlayer"
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


var game_over : bool = false
var score: int = 0
var high_score: int = 0
var pipe_timer: float = 0.0
var active_pipes: Array[Node3D] = []
var active_backgrounds: Array[Node3D] = []

var current_pipe_speed: float = 2.5
var current_pipe_gap: float = 2.0

const SAVE_FILE = "user://flappy_bird_highscore.save"
const WALL_BACKGROUND = preload("uid://bm74jd3l35nls")
const BG_LENGTH: float = 5.9

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_pipe_speed = initial_pipe_speed
	current_pipe_gap = initial_pipe_gap
	
	load_high_score()
	update_score_display()
	
	# Set up collision detection for player
	var player_area = player.get_node_or_null("Facing/Area3D")
	if player_area:
		player_area.area_entered.connect(_on_player_area_entered)
		
	# Spawn initial backgrounds
	for i in range(4):
		var bg = WALL_BACKGROUND.instantiate() as Node3D
		add_child(bg)
		bg.position.z = (i - 1) * BG_LENGTH
		active_backgrounds.append(bg)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_over:
		if Input.is_action_just_pressed("ui_accept"):
			self.queue_free()  # Free the current game scene
		return
	
	# Evolve difficulty over time
	current_pipe_speed = min(current_pipe_speed + speed_increase_rate * delta, max_pipe_speed)
	current_pipe_gap = max(current_pipe_gap - gap_decrease_rate * delta, min_pipe_gap)
	
	# Update pipe spawn timer
	pipe_timer -= delta
	if pipe_timer <= 0:
		pipe_timer = pipe_spawn_interval
		_spawn_pipe_pair()
	
	# Move active pipes
	for i in range(active_pipes.size() - 1, -1, -1):
		var pipe = active_pipes[i]
		if is_instance_valid(pipe):
			pipe.global_position += Vector3(0, 0, -current_pipe_speed * delta)
			
			# Remove pipes that are far off screen (behind player)
			if pipe.global_position.z < -10:
				pipe.queue_free()
				active_pipes.remove_at(i)
		else:
			active_pipes.remove_at(i)
	
	# Move backgrounds
	for bg in active_backgrounds:
		bg.position.z -= current_pipe_speed * delta * 0.2
		if bg.position.z < -BG_LENGTH * 1.5:
			var max_z = -1000.0
			for other_bg in active_backgrounds:
				if other_bg.position.z > max_z:
					max_z = other_bg.position.z
			bg.position.z = max_z + BG_LENGTH
	
	# Check if player fell too low
	if player.position.y < 0.1:
		_trigger_game_over()

func _on_player_area_entered(area: Area3D) -> void:
	# Check if we collided with a pipe by checking it and its parents
	var current_node = area
	while current_node:
		if current_node.is_in_group("pipes"):
			_trigger_game_over()
			return
		current_node = current_node.get_parent()

func _trigger_game_over() -> void:
	game_over = true
	
	if player.has_method("die"):
		player.die()
	else:
		player.set("is_dead", true)
	
	# Update high score
	if score > high_score:
		high_score = score
		save_high_score()
		update_score_display()
	
	# Show restart prompt
	if restart_prompt:
		restart_prompt.visible = true
	
	# Play death animation
	if animation_player:
		animation_player.play("dead")
	
	$AudioStreamPlayer.play()


func _spawn_pipe_pair() -> void:
	if not pipe_scene:
		return
	
	# Calculate random gap center position
	var gap_y = randf_range(min_pipe_height, max_pipe_height)
	
	# Fixed pipe size so they don't stretch weirdly, making gaps inconsistent
	var pipe_size_y = 1
	var half_pipe = pipe_size_y / 2.0
	var half_gap = current_pipe_gap / 2.0
	
	# Create top pipe
	var top_pipe = pipe_scene.instantiate() as Node3D
	add_child(top_pipe)
	active_pipes.append(top_pipe)
	# Position the bottom edge of the top pipe at gap_y + half_gap
	top_pipe.global_position = Vector3(0, gap_y + half_gap + half_pipe, 10)
	top_pipe.scale = Vector3(1, -pipe_size_y, 1)
	top_pipe.add_to_group("pipes")
	
	# Create bottom pipe
	var bottom_pipe = pipe_scene.instantiate() as Node3D
	add_child(bottom_pipe)
	active_pipes.append(bottom_pipe)
	# Position the top edge of the bottom pipe at gap_y - half_gap
	bottom_pipe.global_position = Vector3(0, gap_y - half_gap - half_pipe, 10)
	bottom_pipe.scale = Vector3(1, pipe_size_y, 1)
	bottom_pipe.add_to_group("pipes")
	
	# Increment score when pipes are spawned
	score += 1
	update_score_display()

func load_high_score() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			high_score = file.get_32()
			file.close()

func save_high_score() -> void:
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_32(high_score)
		file.close()

func update_score_display() -> void:
	if counter:
		counter.text = str(score) + " / " + str(high_score)
