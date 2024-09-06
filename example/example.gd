extends Node3D

@export var wind_strength = 0.2;

@onready var fps_label: Label = $UI/FPS

func _ready() -> void:
	Wind.wind_strength = wind_strength;

func _process(_delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
