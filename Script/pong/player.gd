extends Node3D

var velocity: float = 0.0
var speed: float = 20.0
var max_speed: float = 4.0
var decel: float = 15

var current_rot_y: float = 90.0
var rotation_velocity: float = 0.0
const SPRING_STRENGTH: float = 400.0
const DAMPING: float = 0.85
const REF_FPS: float = 60.0

@onready var animation_player: AnimationPlayer = $"Facing/the fool/AnimationPlayer"
@onready var animation_tree: AnimationTree = $"Facing/the fool/AnimationTree"

func _process(delta: float) -> void:
	var dir = (Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"))

	if dir != 0:
		velocity += dir * speed * delta
		velocity = clamp(velocity, -max_speed, max_speed)
	else:
		velocity = move_toward(velocity, 0.0, delta * decel)

	self.position.z += velocity * delta
	animation_tree.set("parameters/blend_position", abs(velocity))

	var target_rot_y = 180.0 - ((3.0 + velocity) * 30.0)
	var displacement = wrapf(target_rot_y - current_rot_y, -180.0, 180.0)
	rotation_velocity += displacement * SPRING_STRENGTH * delta
	rotation_velocity *= pow(DAMPING, delta * REF_FPS)
	current_rot_y += rotation_velocity * delta

	self.rotation_degrees.y = current_rot_y
