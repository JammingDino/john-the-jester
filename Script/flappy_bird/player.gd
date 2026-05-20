extends Node3D

var velocity: float = 0.0
var rotation_accumulator: float = 0.0
var is_dead: bool = false
const GRAVITY: float = 980.0
const JUMP_FORCE: float = -550.0
const MAX_ROTATION: float = 45.0
const ROTATION_SPEED: float = 8.0  # how quickly we reach max rotation

@onready var animation_player: AnimationPlayer = $"Facing/the fool/AnimationPlayer"

func _ready() -> void:
	pass

func reset(player_node) -> void:
	# Reset player state
	velocity = 0.0
	rotation_accumulator = 0.0
	is_dead = false
	player_node.global_position = Vector3(0, 2, 0)
	player_node.rotation_degrees = Vector3.ZERO
	if animation_player:
		animation_player.play("flying")

func _process(delta: float) -> void:
	# Input handling
	if not is_dead and Input.is_action_just_pressed("ui_accept"):
		velocity = JUMP_FORCE
		if animation_player:
			animation_player.play("flying")
	else:
		velocity += GRAVITY * delta

	# Update vertical movement
	position = position + (Vector3(0, -velocity * delta * 0.005, 0))
	
	var target_rotation: float = clamp(velocity * 0.05, -MAX_ROTATION, MAX_ROTATION)
	
	rotation_degrees.x = lerp(rotation_degrees.x, target_rotation, ROTATION_SPEED * delta)
