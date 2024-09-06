extends Node

# Copyright (c) 2024 Julian Müller (ChaoticByte)

var wind_strength: float:
	set(value):
		wind_strength = value
		_update_shader_param("wind_strength", value)

var wind_turbulence: float:
	set(value):
		wind_turbulence = value
		_update_shader_param("wind_turbulence", value)

var wind_direction: Vector2:
	set(value):
		value = value.normalized()
		wind_direction = value
		_update_shader_param("wind_direction", value)

var wind_noise_texture_size: int:
	set(value):
		wind_noise_texture_size = value
		_update_wind_noise()

var wind_noise: Noise:
	set(value):
		wind_noise = value
		_update_wind_noise()

func _update_wind_noise():
		var tex = ImageTexture.new()
		if wind_noise != null:
			var img = wind_noise.get_seamless_image(
				wind_noise_texture_size, wind_noise_texture_size)
			tex.set_image(img)
		_update_shader_param("wind_noise", tex)

var wind_noise_scale: float:
	set(value):
		wind_noise_scale = value
		_update_shader_param("wind_noise_scale", value)

var wind_noise_strength: float:
	set(value):
		wind_noise_strength = value
		_update_shader_param("wind_noise_strength", value)

# reset all params to default
func reset():
	wind_strength = 0.2
	wind_turbulence = 0.5
	wind_direction = Vector2(1, 1)
	wind_noise_texture_size = 2048
	wind_noise = FastNoiseLite.new()
	wind_noise_scale = 8.0
	wind_noise_strength = 1.0

# internal stuff

func _ready():
	reset() # init with defaults

func _update_shader_param(varname: String, value):
	RenderingServer.global_shader_parameter_set(varname, value)
