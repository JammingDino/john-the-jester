extends Area3D

signal paddle_hit

var velocity: Vector3 = Vector3.ZERO
var width: float = 3.0
const GRAVITY: float = 3.8
const MAX_FALL_SPEED: float = 4.0
const LAUNCH_SPEED: float = 5.0
const H_DAMPING: float = 0.8
const MIN_H_SPEED: float = 1.0

func _ready() -> void:
	_launch()

func _launch() -> void:
	# Random angle between 40-70 degrees so neither axis is near-zero
	var angle = randf_range(deg_to_rad(40), deg_to_rad(70))
	var z_dir = 1.0 if randf() > 0.5 else -1.0
	velocity = Vector3(0.0, sin(angle) * LAUNCH_SPEED, cos(angle) * LAUNCH_SPEED * z_dir)

func _physics_process(delta: float) -> void:
	velocity.y = max(velocity.y - GRAVITY * delta, -MAX_FALL_SPEED)

	velocity.z *= pow(H_DAMPING, delta)
	if abs(velocity.z) < MIN_H_SPEED:
		velocity.z = move_toward(velocity.z, sign(velocity.z) * MIN_H_SPEED, delta * 3.0)

	if abs(position.z) > width:
		velocity.z = -velocity.z
		position.z = sign(position.z) * width

	position += velocity * delta

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("PlayerArea"):
		velocity.y = 4
		velocity.z += randf_range(-1.0, 1.0)
		paddle_hit.emit()
