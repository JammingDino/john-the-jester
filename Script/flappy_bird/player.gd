extends Node3D

var velocity: float = 0.0
var rotation_accumulator: float = 0.0
const GRAVITY: float = 980.0
const JUMP_FORCE: float = -550.0
const MAX_ROTATION: float = 45.0
const ROTATION_SPEED: float = 8.0  # how quickly we reach max rotation

@onready var animation_player: AnimationPlayer = $"Facing/the fool/AnimationPlayer"

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# Input handling
	if Input.is_action_pressed("ui_accept"):
		velocity = JUMP_FORCE
		animation_player.play("flying")
	else:
		velocity += GRAVITY * delta

	# Update vertical movement
	position = position + (Vector3(0, -velocity * delta * 0.003, 0))
	
	var target_rotation: float = clamp(velocity * 0.05, -MAX_ROTATION, MAX_ROTATION)
	
	rotation_degrees.x = lerp(rotation_degrees.x, target_rotation, ROTATION_SPEED * delta)
