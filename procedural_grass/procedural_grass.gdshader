shader_type spatial;
render_mode cull_disabled;

// Copyright (c) 2024 Julian Mueller (ChaoticByte)

global uniform float wind_strength;
global uniform float wind_turbulence;
global uniform vec2 wind_direction;
global uniform sampler2D wind_noise;
global uniform float wind_noise_scale;
global uniform float wind_noise_strength;

const float TRANSLUCENCY = 0.15;

void vertex() {
	// scale down grass where the camera is
	vec3 camera_pos_relative = (CAMERA_POSITION_WORLD - (NODE_POSITION_WORLD + VERTEX));
	VERTEX.y *= min(1.0, length(camera_pos_relative.xz));
	// waving according to wind direction, strength, noise, etc.
	ivec2 wind_noise_texsize = textureSize(wind_noise, 0);
	// calculate a substitute for the uv
	vec2 uv = (NODE_POSITION_WORLD.xz + VERTEX.xz)
	          / vec2(wind_noise_texsize)
	          * -wind_direction
	          * wind_noise_scale
	          + (TIME * 0.01 * wind_turbulence);
	// get the noise at this position
	float noise = (textureLod(wind_noise, uv, 0.0).g - 0.5) * wind_noise_strength;
	VERTEX.xz += pow(VERTEX.y, 1.2) * (
		(wind_strength * wind_direction)
		+ (noise * wind_direction)
	);
}

void fragment() {
	ALBEDO = COLOR.rgb;
}

void light() {
	// Adapted from https://godotshaders.com/shader/shoji-shader-translucency-sun-spot/
	// The normal between the object/fragment and the light source
	float nl = clamp(dot(NORMAL, LIGHT), -1.0, 1.0);
	if (nl <= 0.0) {
		// the normal is facing away from the light source
		float light_through = clamp(-nl, 0.0, 1.0) * TRANSLUCENCY;
		float attenuation = max(0.2, ATTENUATION); // softer shadows on this side
		DIFFUSE_LIGHT += clamp(light_through, 0.0, 1.0) * LIGHT_COLOR/PI * attenuation;
	}
	else {
		// The normal is facing toward the light source
		// -> Diffuse (Lambert)
		DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * LIGHT_COLOR/PI * ATTENUATION;
	}
}
