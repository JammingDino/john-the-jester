extends Node3D

var cam_overides: Dictionary = {
	"rotation" : Vector3(-25, 90, 0),
	"spinning" : false,
	"distance" : Vector3(4, 4, 0)
}

@onready var player: Node3D = $Player

var game_over : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_over:
		return
	
	if player.position.y < 0.1:
		_trigger_game_over()

func _trigger_game_over() -> void:
	game_over = true
	self.queue_free()
