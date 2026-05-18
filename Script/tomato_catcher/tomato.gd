extends Node3D


var tomatos : Array = [
	"res://Scenes/dan_tomato.tscn",
	"res://Scenes/oscar_tomato.tscn"
]

func _ready() -> void:
	randomize()
	var new_tomato = load(tomatos[randi_range(0,1)]).instantiate()
	self.add_child(new_tomato)
