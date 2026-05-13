extends Node

var development_resolution : Vector2i = Vector2i(1152, 648)
var development_stetch_shrink : int = 4
var current_resolution_scale : int = 1

func _ready() -> void:
	get_viewport().size_changed.connect(_update_resolution_scale)

func _update_resolution_scale() -> void:
	for viewport_container in get_tree().get_nodes_in_group("ViewportContainer"):
		current_resolution_scale = (get_viewport().get_window().size.length_squared() / development_resolution.length_squared())
		viewport_container.stretch_shrink = ((development_stetch_shrink - 1) + current_resolution_scale)
