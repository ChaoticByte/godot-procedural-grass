extends Camera3D

# Copyright (c) 2024 Julian Müller (ChaoticByte)

@export var movement_speed = 3.0
@export var mouse_sensitivity = 0.01
@export var mouse_x_min: float = -PI/2
@export var mouse_x_max: float = PI/2

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func toggle_mouse_mode():
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotation.x = clamp(
			rotation.x - event.relative.y * mouse_sensitivity,
			mouse_x_min, mouse_x_max
		)
	elif event is InputEventKey:
		if event.is_action_released("ui_cancel"):
			toggle_mouse_mode()

func _process(delta: float) -> void:
	var dir = Vector3()
	if Input.is_action_pressed("forward"):
		dir.z -= 1
	if Input.is_action_pressed("backward"):
		dir.z += 1
	if Input.is_action_pressed("left"):
		dir.x -= 1
	if Input.is_action_pressed("right"):
		dir.x += 1
	position += (
		dir.normalized() * delta * movement_speed
	).rotated(Vector3.UP, rotation.y)
