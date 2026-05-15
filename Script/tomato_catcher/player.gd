extends MeshInstance3D

var input_dir : Vector2 = Vector2(1, 0)
var current_angle : float = 0.0
var angle_velocity : float = 0.0
const SPRING_STRENGTH : float = 400.0
const DAMPING : float = 0.85
const REF_FPS: float = 60.0

@onready var facing: Node3D = $Facing
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _process(delta: float) -> void:
	
	_manage_bite()
	_manage_dir(delta)

func _manage_bite() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		animation_player.play("Bite")

func _manage_dir(delta) -> void:
	var dir = Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")
	if dir != Vector2.ZERO:
		input_dir = dir
	
	var target_angle = input_dir.angle()
	# wrapf ensures we always rotate the shortest directiondsd
	var displacement = wrapf(target_angle - current_angle, -PI, PI)
	
	var acceleration = displacement * SPRING_STRENGTH
	angle_velocity += acceleration * delta
	angle_velocity *= pow(DAMPING, delta * REF_FPS)
	current_angle += angle_velocity * delta
	current_angle = wrapf(current_angle, -PI, PI)
	
	var cam_rotation: float = 0.0
	var cam_pivots = get_tree().get_nodes_in_group("CamPivot")
	if cam_pivots.size() > 0:
		cam_rotation = cam_pivots[0].global_rotation.y
		#print("Camera rotation: ", cam_rotation)
		
	var effective_angle = current_angle - cam_rotation
	
	var look_dir = Vector2(cos(effective_angle), sin(effective_angle))
	
	facing.look_at_from_position(Vector3(0, 0.55, 0), Vector3(look_dir.x, 0.55 ,look_dir.y))
