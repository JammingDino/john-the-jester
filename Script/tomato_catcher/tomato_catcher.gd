extends Node3D

@export var tomato_scene: PackedScene = preload("res://Scenes/tomato.tscn")
@export var min_spawn_delay: float = 0.4
@export var max_tomato_speed: float = 5.0

var spawn_timer: float = 0.0
var current_spawn_delay: float = 2.0
var current_tomato_speed: float = 2.0
var time_elapsed: float = 0.0

var active_tomatoes: Array[Node3D] = []

@onready var catch_area: Area3D = $Player/Facing/Area3D

func _ready() -> void:
	if catch_area:
		catch_area.area_entered.connect(_on_catch_area_entered)

func _on_catch_area_entered(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent in active_tomatoes:
		parent.queue_free()
		active_tomatoes.erase(parent)

func _process(delta: float) -> void:
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
			var speed = tomato.get_meta("speed", current_tomato_speed)
			var direction = tomato.get_meta("direction", Vector3.ZERO)
			var rot_speed = tomato.get_meta("rot_speed", Vector3.ZERO)
			
			tomato.global_position += direction * speed * delta
			tomato.rotation += rot_speed * delta
			
			# If tomato passes far beyond the center, despawn it
			if tomato.global_position.distance_to(Vector3(0, 0.55, 0)) > 20.0:
				tomato.queue_free()
				active_tomatoes.remove_at(i)
		else:
			active_tomatoes.remove_at(i)

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
	var spawn_distance = 15.0
	var spawn_pos = Vector3(cos(angle) * spawn_distance, 0.55, sin(angle) * spawn_distance)
	
	tomato.global_position = spawn_pos
	
	# Move towards the center at the current speed
	var direction = (Vector3(0, 0.55, 0) - spawn_pos).normalized()
	tomato.set_meta("speed", current_tomato_speed)
	tomato.set_meta("direction", direction)
