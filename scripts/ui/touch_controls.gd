class_name TouchControls
extends Control


func _ready() -> void:
	visible = OS.has_feature("mobile")
