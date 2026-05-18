extends Node3D

@export var tomato_scene: PackedScene = preload("res://Scenes/tomato.tscn")
@export var min_spawn_delay: float = 0.4
@export var max_tomato_speed: float = 5.0
@export var spawn_distance: float = 3.0
@export var despawn_distance: float = 6.0

var spawn_timer: float = 0.0
var current_spawn_delay: float = 2.0
var current_tomato_speed: float = 2.0
var time_elapsed: float = 0.0

var active_tomatoes: Array[Node3D] = []

@onready var catch_area: Area3D = $Player/Facing/Area3D
@onready var counter: Label = $Control/MarginContainer/VBoxContainer/Counter
@onready var restart_prompt: Label = $Control/MarginContainer/VBoxContainer/MarginContainer/RestartPrompt
@onready var animation_player: AnimationPlayer = $"Player/Facing/the fool/AnimationPlayer"


const SAVE_FILE = "user://tomato_highscore.save"

var score: int = 0
var high_score: int = 0
var game_over: bool = false

var cam_overides: Dictionary = {
	"rotation" : Vector3(-45, 0, 0),
	"spinning" : true,
	"distance" : Vector3(0, 3.712, 3.595)
}

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

func _ready() -> void:
	load_high_score()
	if catch_area:
		catch_area.area_entered.connect(_on_catch_area_entered)
	update_score_display()

func _on_catch_area_entered(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent in active_tomatoes:
		parent.queue_free()
		active_tomatoes.erase(parent)
		
		score += 1
		update_score_display()
		if counter:
			counter.pivot_offset = counter.size / 2.0
			
			var tween = create_tween()
			counter.scale = Vector2(1.5, 1.5)
			randomize()
			counter.rotation = randf_range(-0.5, 0.5)
			counter.modulate = Color(1.0, 0.9, 0.3) # Flash yellowish/gold
			
			tween.tween_property(counter, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(counter, "rotation", 0.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(counter, "modulate", Color.WHITE, 0.3)

func _process(delta: float) -> void:
	if game_over:
		
		if Input.is_action_just_pressed("ui_accept"):
			self.queue_free()
		
		return
	
	time_elapsed += delta
	
	# Increase difficulty over time
	current_spawn_delay = max(min_spawn_delay, 2.0 - (time_elapsed * 0.03))
	current_tomato_speed = min(max_tomato_speed, 2.0 + (time_elapsed * 0.1))
	
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = current_spawn_delay
		spawn_tomato()
		
	# Move active tomatoes
	for i in range(active_tomatoes.size() - 1, -1, -1):
		var tomato = active_tomatoes[i]
		if is_instance_valid(tomato):
			var delay = tomato.get_meta("move_delay", 0.0)
			if delay > 0.0:
				delay -= delta
				tomato.set_meta("move_delay", delay)
				continue
				
			var speed = tomato.get_meta("speed", current_tomato_speed)
			var direction = tomato.get_meta("direction", Vector3.ZERO)
			var rot_speed = tomato.get_meta("rot_speed", Vector3.ZERO)
			
			tomato.global_position += direction * speed * delta
			tomato.rotation += rot_speed * delta
			
			# If tomato passes through the center, it's game over!
			var to_center = Vector3(0, 0.55, 0) - tomato.global_position
			if to_center.dot(direction) <= 0.0:
				tomato.queue_free()
				active_tomatoes.remove_at(i)
				_trigger_game_over()
		else:
			active_tomatoes.remove_at(i)

func _trigger_game_over() -> void:
	game_over = true
	
	if score > high_score:
		high_score = score
		save_high_score()
		update_score_display()
		
	print("Game Over! Tomato hit the center! Final score: ", score)
	
	# Optional juiciness for Game Over UI (flashing the counter red)
	if counter:
		counter.modulate = Color(1.0, 0.2, 0.2)
		var tween = create_tween()
		tween.tween_property(counter, "scale", Vector2(2.0, 2.0), 0.5).set_trans(Tween.TRANS_SPRING)
		
	# Clean up remaining tomatoes
	for tomato in active_tomatoes:
		if is_instance_valid(tomato):
			tomato.queue_free()
	active_tomatoes.clear()
	
	restart_prompt.visible = true
	
	animation_player.play("dead")

func spawn_tomato() -> void:
	if not tomato_scene:
		return
		
	var tomato = tomato_scene.instantiate() as Node3D
	add_child(tomato)
	active_tomatoes.append(tomato)
	
	# Add an Area3D to make it detectable by the player's Area3D
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.15
	collision.shape = shape
	area.add_child(collision)
	tomato.add_child(area)
	
	# Random scale (+-50%)
	var scale_factor = randf_range(0.5, 1.5)
	tomato.scale = Vector3(scale_factor, scale_factor, scale_factor)
	
	# Randomize rotation vectors
	tomato.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
	var rot_speed = Vector3(randf_range(-TAU, TAU), randf_range(-TAU, TAU), randf_range(-TAU, TAU))
	tomato.set_meta("rot_speed", rot_speed)
	
	# Random spawn location on a circle around the center at y=0.55
	var angle = randf() * TAU
	var spawn_pos = Vector3(cos(angle) * spawn_distance, 0.55, sin(angle) * spawn_distance)
	
	tomato.global_position = spawn_pos
	
	# Setting move delay and triggering particle
	tomato.set_meta("move_delay", 1.0)
	var particles = tomato.get_node_or_null("CPUParticles3D")
	if particles:
		particles.emitting = true
	
	# Move towards the center at the current speed
	var direction = (Vector3(0, 0.55, 0) - spawn_pos).normalized()
	tomato.set_meta("speed", current_tomato_speed)
	tomato.set_meta("direction", direction)
